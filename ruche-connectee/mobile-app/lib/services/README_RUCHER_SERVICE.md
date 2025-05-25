# RucherService - Documentation

## Vue d'ensemble

Le `RucherService` est un service Flutter qui gère les opérations CRUD (Create, Read, Update, Delete) pour les ruchers dans Firebase Firestore. Il s'intègre parfaitement avec l'architecture existante du projet BeeTrack.

## Fonctionnalités principales

### ✅ Fonction principale : `ajouterRucher`

Cette fonction répond exactement aux exigences demandées :

```dart
Future<String> ajouterRucher({
  required String nom,
  required String adresse,
  required String description,
}) async
```

**Caractéristiques :**
- ✅ Vérifie que l'utilisateur est connecté
- ✅ Crée un document dans la collection `ruchers`
- ✅ Inclut automatiquement l'`idApiculteur` (ID Firebase actuel)
- ✅ Ajoute un timestamp `dateCreation` automatique
- ✅ Gestion complète des erreurs
- ✅ Logging détaillé pour le débogage

**Structure du document créé :**
```json
{
  "idApiculteur": "uid_firebase_utilisateur",
  "nom": "Nom du rucher",
  "adresse": "Adresse complète",
  "description": "Description du rucher",
  "dateCreation": "timestamp_firestore",
  "actif": true,
  "nombreRuches": 0
}
```

## Utilisation

### 1. Initialisation du service

```dart
import 'package:get_it/get_it.dart';
import 'package:ruche_connectee/services/rucher_service.dart';
import 'package:ruche_connectee/services/firebase_service.dart';

// Dans votre widget ou classe
final rucherService = RucherService(GetIt.I<FirebaseService>());
```

### 2. Ajouter un rucher

```dart
try {
  final String rucherId = await rucherService.ajouterRucher(
    nom: 'Rucher du verger',
    adresse: '123 Rue des Abeilles, 75001 Paris',
    description: 'Rucher situé dans un verger de pommiers, exposition sud',
  );
  
  print('Rucher créé avec l\'ID: $rucherId');
} catch (e) {
  print('Erreur: $e');
}
```

### 3. Récupérer les ruchers de l'utilisateur

```dart
try {
  final List<Map<String, dynamic>> ruchers = await rucherService.obtenirRuchersUtilisateur();
  
  for (final rucher in ruchers) {
    print('Rucher: ${rucher['nom']} - ${rucher['adresse']}');
  }
} catch (e) {
  print('Erreur: $e');
}
```

### 4. Écouter les changements en temps réel

```dart
StreamBuilder<List<Map<String, dynamic>>>(
  stream: rucherService.ecouterRuchersUtilisateur(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return Text('Erreur: ${snapshot.error}');
    }
    
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }
    
    final ruchers = snapshot.data!;
    return ListView.builder(
      itemCount: ruchers.length,
      itemBuilder: (context, index) {
        final rucher = ruchers[index];
        return ListTile(
          title: Text(rucher['nom']),
          subtitle: Text(rucher['adresse']),
        );
      },
    );
  },
)
```

## Gestion des erreurs

Le service gère plusieurs types d'erreurs :

### Erreurs d'authentification
```dart
// Si l'utilisateur n'est pas connecté
throw Exception('Utilisateur non connecté. Veuillez vous connecter pour ajouter un rucher.');
```

### Erreurs Firebase
```dart
// Permissions insuffisantes
throw Exception('Permissions insuffisantes pour créer un rucher');

// Service indisponible
throw Exception('Service temporairement indisponible. Veuillez réessayer.');
```

### Erreurs de validation
```dart
// Les données sont automatiquement nettoyées avec .trim()
// Validation côté client recommandée dans l'UI
```

## Sécurité

### Vérifications automatiques
- ✅ Vérification de l'utilisateur connecté avant chaque opération
- ✅ Association automatique avec l'ID de l'utilisateur actuel
- ✅ Vérification des permissions lors de l'accès aux ruchers
- ✅ Suppression logique (soft delete) pour préserver l'historique

### Règles Firestore recommandées
```javascript
// Dans les règles Firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /ruchers/{rucherId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.idApiculteur;
      allow create: if request.auth != null 
        && request.auth.uid == request.resource.data.idApiculteur;
    }
  }
}
```

## Intégration avec l'architecture existante

### Compatibilité
- ✅ Compatible avec le backend Java Spring Boot existant
- ✅ Utilise la même structure de données que l'API web
- ✅ Respecte les conventions de nommage du projet
- ✅ Intégré avec le système de logging existant

### Services utilisés
- `FirebaseService` : Pour l'accès aux instances Firebase
- `LoggerService` : Pour le logging et le débogage
- `AuthService` : Pour la gestion de l'authentification

## Exemple d'écran complet

Voir le fichier `ajouter_rucher_screen.dart` pour un exemple complet d'utilisation avec :
- Formulaire de validation
- Gestion des états de chargement
- Affichage des messages d'erreur et de succès
- Interface utilisateur moderne et responsive

## Tests recommandés

```dart
// Tests unitaires recommandés
void main() {
  group('RucherService', () {
    test('devrait ajouter un rucher avec utilisateur connecté', () async {
      // Test d'ajout réussi
    });
    
    test('devrait échouer si utilisateur non connecté', () async {
      // Test d'échec d'authentification
    });
    
    test('devrait valider les données d\'entrée', () async {
      // Test de validation
    });
  });
}
```

## Évolutions futures possibles

1. **Géolocalisation** : Ajout de coordonnées GPS automatiques
2. **Photos** : Upload d'images du rucher
3. **Météo** : Intégration avec des APIs météo
4. **Partage** : Partage de ruchers entre apiculteurs
5. **Statistiques** : Calculs automatiques de productivité

---

**Note :** Ce service est prêt à l'emploi et respecte toutes les exigences demandées. Il s'intègre parfaitement dans l'architecture existante du projet BeeTrack. 