# Migration de Firestore vers Realtime Database

## 🎯 Objectif

Ce document décrit la migration complète de Firebase Firestore vers Firebase Realtime Database pour résoudre l'erreur `PERMISSION_DENIED: Cloud Firestore API has not been used...`.

## 🔄 Changements effectués

### 1. Dépendances Maven (`pom.xml`)

**Avant (Firestore) :**
```xml
<dependency>
    <groupId>com.google.cloud</groupId>
    <artifactId>google-cloud-firestore</artifactId>
    <version>3.14.0</version>
</dependency>
```

**Après (Realtime Database) :**
```xml
<!-- Firebase Realtime Database -->
<dependency>
    <groupId>com.google.firebase</groupId>
    <artifactId>firebase-admin</artifactId>
    <version>9.2.0</version>
</dependency>
```

### 2. Configuration Firebase (`FirebaseConfig.java`)

**Avant (Firestore) :**
```java
@Bean
public Firestore firestore() {
    // Configuration Firestore
    FirestoreOptions firestoreOptions = FirestoreOptions.newBuilder()
            .setCredentials(credentials)
            .setProjectId(projectId)
            .build();
    return firestoreOptions.getService();
}
```

**Après (Realtime Database) :**
```java
@Bean
public FirebaseDatabase firebaseDatabase() {
    return FirebaseDatabase.getInstance();
}
```

### 3. Service Firebase (`FirebaseService.java`)

**Avant (Firestore) :**
```java
// Utilisation de Firestore
@Autowired
private Firestore firestore;

public DocumentSnapshot getDocument(String collection, String documentId) {
    DocumentReference docRef = firestore.collection(collection).document(documentId);
    ApiFuture<DocumentSnapshot> future = docRef.get();
    return future.get();
}
```

**Après (Realtime Database) :**
```java
// Utilisation de Realtime Database
@Autowired
private FirebaseDatabase firebaseDatabase;

public Map<String, Object> getDocument(String collection, String documentId) {
    DatabaseReference ref = firebaseDatabase.getReference(collection).child(documentId);
    // Utilisation de CountDownLatch pour la synchronisation
    // ...
}
```

### 4. Configuration application (`application.properties`)

**Ajouté :**
```properties
firebase.database-url=https://rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app
```

### 5. Règles de sécurité

**Avant (Firestore) :** `config/firestore.rules`
**Après (Realtime Database) :** `config/database.rules.json`

### 6. Configuration Firebase (`firebase.json`)

**Avant :**
```json
{
  "firestore": {
    "rules": "config/firestore.rules",
    "indexes": "config/firestore.indexes.json"
  }
}
```

**Après :**
```json
{
  "database": {
    "rules": "config/database.rules.json"
  }
}
```

## 🔧 Différences techniques

### Structure des données

**Firestore :**
```
collections/
  ├── apiculteurs/
  │   └── {userId}/
  │       ├── email: string
  │       └── nom: string
  └── ruches/
      └── {rucheId}/
          ├── nom: string
          └── idApiculteur: string
```

**Realtime Database :**
```
{
  "apiculteurs": {
    "{userId}": {
      "email": "string",
      "nom": "string"
    }
  },
  "ruches": {
    "{rucheId}": {
      "nom": "string",
      "idApiculteur": "string"
    }
  }
}
```

### Requêtes

**Firestore :**
```java
// Requêtes complexes avec filtres multiples
Query query = firestore.collection("ruches")
    .whereEqualTo("idApiculteur", apiculteurId)
    .whereEqualTo("actif", true)
    .orderBy("dateCreation", Query.Direction.DESCENDING);
```

**Realtime Database :**
```java
// Requêtes simples, filtrage côté client
List<Map<String, Object>> documents = firebaseService.getDocuments("ruches", "idApiculteur", apiculteurId);
documents.stream()
    .filter(doc -> (Boolean) doc.getOrDefault("actif", true))
    .sorted((a, b) -> Long.compare((Long) b.get("dateCreation"), (Long) a.get("dateCreation")))
    .collect(Collectors.toList());
```

## 🚀 Avantages de Realtime Database

1. **Pas d'erreur Firestore API** : Plus besoin d'activer l'API Firestore
2. **Simplicité** : Structure JSON simple et intuitive
3. **Temps réel** : Synchronisation automatique des données
4. **Performance** : Requêtes plus rapides pour les données simples
5. **Coût** : Généralement moins cher pour les petits projets

## ⚠️ Limitations

1. **Requêtes complexes** : Pas de requêtes avec filtres multiples côté serveur
2. **Index** : Pas d'index composites comme Firestore
3. **Tri** : Tri principalement côté client
4. **Limite de profondeur** : Maximum 32 niveaux de profondeur

## 🧪 Tests

### Script de test
```bash
# Exécuter le script de test
scripts/test-realtime-database.bat
```

### Vérifications manuelles
1. Démarrer l'application Spring Boot
2. Vérifier les logs : `Firebase initialisé avec succès`
3. Tester les opérations CRUD via l'interface web
4. Vérifier l'absence d'erreurs Firestore dans les logs

## 🔍 Résolution des problèmes

### Erreur : "Firebase Database not found"
- Vérifier que Realtime Database est activé dans la console Firebase
- Vérifier l'URL de la base de données dans `application.properties`

### Erreur : "Permission denied"
- Vérifier les règles de sécurité dans `config/database.rules.json`
- Déployer les règles : `firebase deploy --only database`

### Erreur : "Timeout"
- Augmenter le timeout dans `FirebaseService.java` (actuellement 30 secondes)
- Vérifier la connectivité réseau

## 📊 Migration des données

Si vous avez des données existantes dans Firestore :

1. **Export Firestore :**
```bash
gcloud firestore export gs://your-bucket/firestore-export
```

2. **Conversion des données :**
```javascript
// Script de conversion Firestore → Realtime Database
const admin = require('firebase-admin');
const serviceAccount = require('./firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app"
});

// Conversion des collections
// ...
```

3. **Import Realtime Database :**
```bash
firebase database:set /apiculteurs converted-data.json
```

## ✅ Checklist de migration

- [x] Mise à jour des dépendances Maven
- [x] Modification de `FirebaseConfig.java`
- [x] Refactorisation de `FirebaseService.java`
- [x] Adaptation des services métier
- [x] Mise à jour de `application.properties`
- [x] Création des règles de sécurité
- [x] Mise à jour de `firebase.json`
- [x] Tests de fonctionnement
- [x] Documentation des changements

## 🎉 Résultat

L'application utilise maintenant **uniquement Firebase Realtime Database** et ne génère plus l'erreur `PERMISSION_DENIED: Cloud Firestore API has not been used...`.

La migration est **complète** et **fonctionnelle**. 