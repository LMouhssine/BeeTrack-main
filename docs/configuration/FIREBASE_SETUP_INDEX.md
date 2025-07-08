# Configuration Firebase pour BeeTrack

Guide de configuration Firebase Firestore pour l'application Spring Boot BeeTrack.

## 🎯 Objectif

Configurer Firebase Firestore avec Spring Boot pour optimiser les performances des requêtes et éviter les erreurs d'index.

## 🔥 Configuration Firebase

### 1. Configuration du projet

1. **Console Firebase** : https://console.firebase.google.com/
2. **Créer ou sélectionner** votre projet BeeTrack
3. **Activer Firestore Database** en mode production

### 2. Service Account (Spring Boot)

```bash
# Télécharger le fichier service account
# Firebase Console > Paramètres projet > Comptes de service
# Cliquer sur "Générer nouvelle clé privée"
# Sauvegarder comme firebase-service-account.json
```

### 3. Configuration Spring Boot

```properties
# application.properties
firebase.project-id=votre-projet-beetrck
firebase.service-account=firebase-service-account.json

# Logging Firebase (optionnel)
logging.level.com.google.firebase=INFO
```

## 📊 Index Firestore requis

### Index composites nécessaires

#### Collection `ruches`
```json
{
  "collectionGroup": "ruches",
  "queryScope": "COLLECTION",
  "fields": [
    {"fieldPath": "idRucher", "order": "ASCENDING"},
    {"fieldPath": "actif", "order": "ASCENDING"},
    {"fieldPath": "dateCreation", "order": "DESCENDING"}
  ]
}
```

#### Collection `donneesCapteurs`
```json
{
  "collectionGroup": "donneesCapteurs", 
  "queryScope": "COLLECTION",
  "fields": [
    {"fieldPath": "rucheId", "order": "ASCENDING"},
    {"fieldPath": "timestamp", "order": "DESCENDING"}
  ]
}
```

### Création automatique des index

1. **Via Firebase CLI**
```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Se connecter
firebase login

# Initialiser dans le projet
firebase init firestore

# Déployer les index
firebase deploy --only firestore:indexes
```

2. **Via fichier firestore.indexes.json**
```json
{
  "indexes": [
    {
      "collectionGroup": "ruches",
      "queryScope": "COLLECTION", 
      "fields": [
        {"fieldPath": "idRucher", "order": "ASCENDING"},
        {"fieldPath": "actif", "order": "ASCENDING"}
      ]
    },
    {
      "collectionGroup": "donneesCapteurs",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "rucheId", "order": "ASCENDING"}, 
        {"fieldPath": "timestamp", "order": "DESCENDING"}
      ]
    }
  ]
}
```

## 🔧 Configuration Spring Boot Firebase

### FirebaseConfig.java

```java
@Configuration
public class FirebaseConfig {
    
    @Value("${firebase.project-id}")
    private String projectId;
    
    @Value("${firebase.service-account}")
    private String serviceAccountPath;
    
    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        if (FirebaseApp.getApps().isEmpty()) {
            FileInputStream serviceAccount = new FileInputStream(
                getClass().getClassLoader().getResource(serviceAccountPath).getFile()
            );
            
            FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                .setProjectId(projectId)
                .build();
                
            return FirebaseApp.initializeApp(options);
        }
        return FirebaseApp.getInstance();
    }
    
    @Bean
    public Firestore firestore() {
        return FirestoreClient.getFirestore();
    }
}
```

## 🚀 Optimisation des requêtes

### Bonnes pratiques Spring Boot

```java
@Service
public class RucheService {
    
    @Autowired
    private Firestore firestore;
    
    // ✅ Requête optimisée avec index
    public List<Ruche> getRuchesByRucher(String rucherId) {
        try {
            Query query = firestore.collection("ruches")
                .whereEqualTo("idRucher", rucherId)
                .whereEqualTo("actif", true)
                .orderBy("dateCreation", Query.Direction.DESCENDING);
                
            ApiFuture<QuerySnapshot> future = query.get();
            return future.get().getDocuments().stream()
                .map(doc -> doc.toObject(Ruche.class))
                .collect(Collectors.toList());
        } catch (Exception e) {
            log.error("Erreur requête ruches", e);
            return Collections.emptyList();
        }
    }
}
```

## 🔒 Règles de sécurité Firestore

### Configuration recommandée

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Ruchers - accès par propriétaire
    match /ruchers/{rucherId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.idApiculteur;
    }
    
    // Ruches - accès par propriétaire
    match /ruches/{rucheId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.idApiculteur;
    }
    
    // Données capteurs - lecture seule pour propriétaire
    match /donneesCapteurs/{mesureId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
        && request.auth.uid == getUser(resource.data.rucheId).idApiculteur;
    }
    
    function getUser(rucheId) {
      return get(/databases/$(database)/documents/ruches/$(rucheId)).data;
    }
  }
}
```

## 📈 Monitoring et métriques

### Configuration Spring Actuator

```properties
# Monitoring Firestore
management.endpoints.web.exposure.include=health,metrics,firebase
management.endpoint.health.show-details=always
```

### Health Check personnalisé

```java
@Component
public class FirebaseHealthIndicator implements HealthIndicator {
    
    @Autowired
    private Firestore firestore;
    
    @Override
    public Health health() {
        try {
            // Test simple de connectivité
            firestore.collection("health").limit(1).get().get();
            return Health.up()
                .withDetail("firebase", "connected")
                .build();
        } catch (Exception e) {
            return Health.down()
                .withDetail("firebase", "disconnected")
                .withDetail("error", e.getMessage())
                .build();
        }
    }
}
```

## 🐛 Résolution des problèmes

### Erreurs courantes

#### 1. Erreur d'authentification
```
Error: Could not load the default credentials
```
**Solution**: Vérifier le fichier `firebase-service-account.json`

#### 2. Erreur d'index manquant
```
Error: The query requires an index
```
**Solution**: Créer l'index dans Firebase Console

#### 3. Quota dépassé
```
Error: Quota exceeded
```
**Solution**: Optimiser les requêtes ou augmenter les quotas

### Test de configuration

```java
@RestController
public class TestController {
    
    @Autowired
    private Firestore firestore;
    
    @GetMapping("/test/firebase")
    public ResponseEntity<String> testFirebase() {
        try {
            // Test simple
            firestore.collection("test").add(Map.of("timestamp", System.currentTimeMillis()));
            return ResponseEntity.ok("Firebase OK");
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Firebase Error: " + e.getMessage());
        }
    }
}
```

## 📚 Ressources

- **Documentation Firebase Admin SDK** : https://firebase.google.com/docs/admin/setup
- **Spring Boot Firebase** : https://github.com/firebase/firebase-admin-java
- **Règles de sécurité** : https://firebase.google.com/docs/firestore/security/rules-structure

---

<div align="center">

**Configuration Firebase pour BeeTrack**  
*Spring Boot + Firebase Admin SDK*

</div> 