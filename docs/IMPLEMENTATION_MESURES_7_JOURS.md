# 📊 Implémentation - Mesures des 7 derniers jours

## 📋 Vue d'ensemble

Cette documentation décrit l'implémentation de la fonctionnalité de récupération des mesures des 7 derniers jours d'une ruche dans l'application Spring Boot.

## 🎯 Objectif

Développer une fonction pour récupérer les mesures des capteurs d'une ruche sur les 7 derniers jours, avec :
- Filtrage par date (données postérieures à maintenant - 7 jours)
- Tri croissant par timestamp
- Gestion correcte des fuseaux horaires
- Sécurité et validation des accès

## 🏗️ Architecture

### Composants modifiés

#### **Service Layer**
- `FirebaseService.java` : Ajout d'une méthode pour requêtes complexes
- `RucheService.java` : Logique métier pour la récupération des mesures

#### **Controller Layer**
- `RucheController.java` : Endpoint public pour les mesures
- `RucheMobileController.java` : Endpoint sécurisé pour mobile/React
- `TestController.java` : Endpoints de test et utilitaires

## 🔧 Implémentation Détaillée

### 1. Service Firebase - Méthode de requête complexe

```java
/**
 * Exécute une requête complexe avec filtres de date et tri
 */
public List<QueryDocumentSnapshot> getDocumentsWithDateFilter(
        String collection, 
        String filterField, 
        Object filterValue,
        String dateField,
        com.google.cloud.Timestamp dateLimit,
        String orderByField,
        boolean ascending) throws ExecutionException, InterruptedException {
    
    CollectionReference colRef = firestore.collection(collection);
    Query query = colRef
        .whereEqualTo(filterField, filterValue)
        .whereGreaterThan(dateField, dateLimit)
        .orderBy(dateField, ascending ? Query.Direction.ASCENDING : Query.Direction.DESCENDING);
    
    ApiFuture<QuerySnapshot> future = query.get();
    QuerySnapshot querySnapshot = future.get();
    return querySnapshot.getDocuments();
}
```

### 2. Service Ruche - Logique métier

```java
/**
 * Récupère les mesures des 7 derniers jours d'une ruche
 * @param rucheId ID de la ruche
 * @return Liste des mesures triées par date croissante
 */
public List<DonneesCapteur> getMesures7DerniersJours(String rucheId) 
        throws ExecutionException, InterruptedException {
    // Calculer la date limite (maintenant - 7 jours)
    LocalDateTime dateLimite = LocalDateTime.now().minusDays(7);
    
    // Convertir en Timestamp Firebase pour la comparaison
    com.google.cloud.Timestamp timestampLimite = com.google.cloud.Timestamp.of(
        java.util.Date.from(dateLimite.atZone(java.time.ZoneId.systemDefault()).toInstant())
    );
    
    // Utiliser le FirebaseService pour exécuter la requête complexe
    List<QueryDocumentSnapshot> documents = firebaseService.getDocumentsWithDateFilter(
        COLLECTION_DONNEES,   // collection
        "ruche_id",           // filterField
        rucheId,              // filterValue
        "timestamp",          // dateField
        timestampLimite,      // dateLimit
        "timestamp",          // orderByField
        true                  // ascending = true pour tri croissant
    );
    
    // Convertir les résultats en objets DonneesCapteur
    return documents.stream()
            .map(doc -> documentToDonnees(doc.getId(), doc.getData()))
            .collect(Collectors.toList());
}
```

### 3. Contrôleurs - Endpoints REST

#### Endpoint public (RucheController)
```java
/**
 * Récupère les mesures des 7 derniers jours d'une ruche
 */
@GetMapping("/{rucheId}/mesures-7-jours")
public ResponseEntity<List<DonneesCapteur>> getMesures7DerniersJours(@PathVariable String rucheId) {
    try {
        List<DonneesCapteur> mesures = rucheService.getMesures7DerniersJours(rucheId);
        return ResponseEntity.ok(mesures);
    } catch (ExecutionException | InterruptedException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
    }
}
```

#### Endpoint sécurisé (RucheMobileController)
```java
/**
 * Récupère les mesures des 7 derniers jours d'une ruche avec validation de sécurité
 */
@GetMapping("/{rucheId}/mesures-7-jours")
public ResponseEntity<?> getMesures7DerniersJours(
        @PathVariable String rucheId,
        @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
    try {
        // Vérifier que la ruche existe et appartient à l'utilisateur
        var ruche = rucheService.getRucheById(rucheId);
        if (ruche == null) {
            return ResponseEntity.notFound().build();
        }
        if (!ruche.getApiculteurId().equals(apiculteurId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(new ErrorResponse("ACCESS_DENIED", "Accès non autorisé à cette ruche"));
        }

        // Récupérer les mesures
        var mesures = rucheService.getMesures7DerniersJours(rucheId);
        return ResponseEntity.ok(mesures);
    } catch (ExecutionException | InterruptedException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse("SERVER_ERROR", "Erreur lors de la récupération des mesures"));
    }
}
```

## 📡 API Endpoints

### Endpoints disponibles

| Méthode | Endpoint | Description | Sécurité |
|---------|----------|-------------|----------|
| `GET` | `/api/ruches/{rucheId}/mesures-7-jours` | Mesures 7 derniers jours (public) | Aucune |
| `GET` | `/api/mobile/ruches/{rucheId}/mesures-7-jours` | Mesures 7 derniers jours (sécurisé) | Header `X-Apiculteur-ID` |
| `GET` | `/api/test/ruche/{rucheId}/mesures-7-jours` | Test avec statistiques | Aucune (dev only) |
| `POST` | `/api/test/ruche/{rucheId}/creer-donnees-test` | Créer données de test | Aucune (dev only) |

### Format des réponses

#### Succès - Endpoint standard
```json
[
  {
    "id": "measure_001",
    "rucheId": "ruche001",
    "timestamp": "2024-01-15T10:30:00",
    "temperature": 25.4,
    "humidity": 65.2,
    "couvercleOuvert": false,
    "batterie": 85,
    "signalQualite": 92,
    "erreur": null
  },
  // ... autres mesures triées par timestamp croissant
]
```

#### Succès - Endpoint de test
```json
{
  "rucheId": "ruche001",
  "dateLimite": "2024-01-08T10:30:00",
  "nombreMesures": 56,
  "mesures": [...],
  "statistiques": {
    "premiereMesure": "2024-01-08T12:00:00",
    "derniereMesure": "2024-01-15T09:45:00",
    "temperatureMin": 18.2,
    "temperatureMax": 32.1,
    "temperatureMoyenne": 24.7
  }
}
```

#### Erreur
```json
{
  "code": "ACCESS_DENIED",
  "message": "Accès non autorisé à cette ruche",
  "timestamp": 1705318200000
}
```

## 🔐 Sécurité

### Contrôles d'accès
- **Endpoint public** : Aucune restriction (à utiliser avec prudence)
- **Endpoint mobile** : Vérification que la ruche appartient à l'apiculteur
- **Header requis** : `X-Apiculteur-ID` pour les endpoints sécurisés

### Validation
- Vérification de l'existence de la ruche
- Contrôle de propriété (apiculteur)
- Gestion des erreurs d'accès

## 🕐 Gestion des Dates

### Fuseau horaire
- Utilisation du fuseau horaire système : `ZoneId.systemDefault()`
- Conversion correcte LocalDateTime ↔ Timestamp Firebase
- Calcul précis : `LocalDateTime.now().minusDays(7)`

### Format des dates
- **Base de données** : `com.google.cloud.Timestamp`
- **Java** : `LocalDateTime`
- **JSON** : ISO 8601 format

## 🧪 Tests et Développement

### Création de données de test
```bash
# Créer 10 jours de données avec 8 mesures par jour
POST /api/test/ruche/{rucheId}/creer-donnees-test?nombreJours=10&mesuresParJour=8
```

### Test de la fonctionnalité
```bash
# Test avec statistiques détaillées
GET /api/test/ruche/{rucheId}/mesures-7-jours

# Test de l'endpoint de production
GET /api/ruches/{rucheId}/mesures-7-jours
```

## 📊 Données retournées

### Structure DonneesCapteur
- **id** : Identifiant unique de la mesure
- **rucheId** : ID de la ruche concernée
- **timestamp** : Horodatage de la mesure
- **temperature** : Température en °C
- **humidity** : Humidité relative en %
- **couvercleOuvert** : État du couvercle (boolean)
- **batterie** : Niveau de batterie en %
- **signalQualite** : Qualité du signal en %
- **erreur** : Message d'erreur éventuel

### Tri et filtrage
- **Filtre temporel** : `timestamp > (maintenant - 7 jours)`
- **Filtre ruche** : `ruche_id = {rucheId}`
- **Tri** : Par `timestamp` croissant (du plus ancien au plus récent)

## 🚀 Utilisation

### Intégration frontend

#### JavaScript/React
```javascript
// Récupération des mesures (avec authentification)
const response = await fetch(`/api/mobile/ruches/${rucheId}/mesures-7-jours`, {
  headers: {
    'X-Apiculteur-ID': currentUser.uid,
    'Content-Type': 'application/json'
  }
});
const mesures = await response.json();
```

#### Flutter/Dart
```dart
// Service API
Future<List<DonneesCapteur>> getMesures7DerniersJours(String rucheId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/mobile/ruches/$rucheId/mesures-7-jours'),
    headers: {
      'X-Apiculteur-ID': currentUser.uid,
      'Content-Type': 'application/json',
    },
  );
  // ... traitement de la réponse
}
```

## ⚠️ Points d'attention

### Performance
- Indexation recommandée sur `ruche_id` et `timestamp` dans Firestore
- Limitation naturelle à 7 jours de données
- Pagination possible si nécessaire pour de gros volumes

### Maintenance
- Le contrôleur de test doit être retiré en production
- Surveillance des performances des requêtes
- Logs des erreurs d'accès

### Évolutions futures
- Paramétrage de la période (7 jours configurable)
- Agrégation des données (moyennes horaires/journalières)
- Cache des résultats pour optimiser les performances 