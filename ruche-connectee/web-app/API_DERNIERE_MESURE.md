# API Dernière Mesure - Documentation

## 🎯 Objectif

Cette API permet de récupérer la **dernière mesure** d'une ruche spécifique depuis la collection Firestore `donneesCapteurs`. Elle est optimisée pour les clients mobiles qui ont besoin de suivre l'état en temps réel des ruches.

## 🚀 Endpoints

### 1. Récupérer la dernière mesure (API Mobile)

```http
GET /api/mobile/ruches/{rucheId}/derniere-mesure
```

**Headers requis :**
```
X-Apiculteur-ID: {apiculteurId}
```

**Réponse de succès (200) :**
```json
{
  "id": "doc_id_firestore",
  "rucheId": "ruche123",
  "timestamp": "2024-01-15T14:30:00",
  "temperature": 25.5,
  "humidity": 65.2,
  "couvercleOuvert": false,
  "batterie": 85,
  "signalQualite": 92,
  "erreur": null
}
```

**Réponses d'erreur :**
- `404` : Ruche non trouvée ou aucune mesure disponible
- `403` : Accès non autorisé à cette ruche
- `500` : Erreur interne du serveur

### 2. Endpoint de test (sans authentification)

```http
GET /test/derniere-mesure/{rucheId}
```

**Réponse :**
```json
{
  "status": "OK",
  "rucheId": "ruche123",
  "derniereMesure": { /* objet mesure */ },
  "message": "Dernière mesure trouvée"
}
```

## 🔧 Implémentation technique

### Requête Firestore

L'API utilise une requête optimisée :

```java
// Récupère 1 document de la collection "donneesCapteurs"
// Filtré par rucheId
// Trié par timestamp décroissant (plus récent en premier)
// Limité à 1 résultat
firebaseService.getDocumentsWithFilter(
    "donneesCapteurs",  // collection
    "rucheId",          // filterField
    rucheId,            // filterValue
    "timestamp",        // orderByField
    false,              // ascending = false (décroissant)
    1                   // limit = 1
);
```

### Structure des données Firestore

**Collection :** `donneesCapteurs`

**Document type :**
```json
{
  "rucheId": "string",
  "timestamp": "Timestamp",
  "temperature": "number",
  "humidity": "number", 
  "couvercleOuvert": "boolean",
  "batterie": "number",
  "signalQualite": "number",
  "erreur": "string|null"
}
```

## 📱 Utilisation côté client

### React/TypeScript

```typescript
const API_BASE_URL = 'http://localhost:8080';

async function getDerniereMesure(rucheId: string, apiculteurId: string) {
  const response = await fetch(
    `${API_BASE_URL}/api/mobile/ruches/${rucheId}/derniere-mesure`,
    {
      headers: {
        'X-Apiculteur-ID': apiculteurId
      }
    }
  );
  
  if (response.ok) {
    return await response.json();
  } else {
    throw new Error(`Erreur ${response.status}: ${response.statusText}`);
  }
}
```

### Flutter/Dart

```dart
Future<Map<String, dynamic>?> getDerniereMesure(String rucheId, String apiculteurId) async {
  final response = await http.get(
    Uri.parse('$apiBaseUrl/api/mobile/ruches/$rucheId/derniere-mesure'),
    headers: {
      'X-Apiculteur-ID': apiculteurId,
    },
  );
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else if (response.statusCode == 404) {
    return null; // Aucune mesure trouvée
  } else {
    throw Exception('Erreur lors de la récupération: ${response.statusCode}');
  }
}
```

## 🔄 Actualisation en temps réel

Pour un suivi en temps réel, le client peut :

1. **Polling périodique** (recommandé) :
   ```javascript
   setInterval(() => {
     getDerniereMesure(rucheId, apiculteurId)
       .then(mesure => updateUI(mesure))
       .catch(error => console.error(error));
   }, 30000); // Toutes les 30 secondes
   ```

2. **Pull-to-refresh** sur mobile
3. **Actualisation manuelle** via bouton

## 🧪 Tests

### Test avec données existantes

```bash
# Test endpoint public (sans auth)
curl http://localhost:8080/test/derniere-mesure/RUCHE_ID

# Test endpoint mobile (avec auth)
curl -H "X-Apiculteur-ID: USER_ID" \
     http://localhost:8080/api/mobile/ruches/RUCHE_ID/derniere-mesure
```

### Créer des données de test

```bash
# Créer des données de test pour une ruche
curl -X POST http://localhost:8080/dev/create-test-data/RUCHE_ID?nombreJours=7&mesuresParJour=8
```

## 🔍 Monitoring et logs

L'API génère des logs pour :
- Requêtes reçues
- Erreurs d'accès (403)
- Ruches non trouvées (404)
- Erreurs Firestore (500)

## 🚨 Limitations

1. **Index Firestore requis** : La requête nécessite un index composite sur `(rucheId, timestamp)`
2. **Authentification** : L'endpoint mobile nécessite l'header `X-Apiculteur-ID`
3. **Permissions** : Seul le propriétaire de la ruche peut accéder aux données

## 📈 Performance

- **Latence** : ~100-200ms (selon la distance Firestore)
- **Coût** : 1 lecture Firestore par requête
- **Cache** : Pas de cache côté serveur (données temps réel) 