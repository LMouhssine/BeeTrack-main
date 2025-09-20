# Actions Finales pour Finaliser la Migration

## 🎯 Actions requises

### 1. Activation de Realtime Database dans Firebase Console

1. **Accéder à la console Firebase :** https://console.firebase.google.com/
2. **Sélectionner le projet :** `rucheconnecteeesp32`
3. **Aller dans Realtime Database :** Menu → Realtime Database
4. **Créer la base de données :** Cliquer sur "Créer une base de données"
5. **Choisir l'emplacement :** `europe-west1` (pour correspondre à l'URL configurée)
6. **Règles de sécurité :** Choisir "Mode test" temporairement

### 2. Déploiement des règles de sécurité

```bash
# Dans le répertoire racine du projet
firebase deploy --only database
```

### 3. Vérification du fichier de service account

**Emplacement :** `ruche-connectee/web-app/src/main/resources/firebase-service-account.json`

**Vérifier que le fichier contient :**
- `project_id`: "rucheconnecteeesp32"
- `client_email`: "firebase-adminsdk-fbsvc@rucheconnecteeesp32.iam.gserviceaccount.com"
- `private_key`: Votre clé privée

### 4. Test de l'application

```bash
# Exécuter le script de test
scripts/test-realtime-database.bat

# Démarrer l'application
scripts/start-beetrack-realtime.bat
```

### 5. Vérifications dans les logs

**Logs attendus au démarrage :**
```
Firebase initialisé avec succès pour le projet: rucheconnecteeesp32
```

**Logs à éviter :**
```
PERMISSION_DENIED: Cloud Firestore API has not been used...
```

## 🔧 Configuration Firebase Console

### Règles de sécurité Realtime Database

Dans la console Firebase → Realtime Database → Règles :

```json
{
  "rules": {
    "apiculteurs": {
      "$apiculteurId": {
        ".read": "auth != null && auth.uid == $apiculteurId",
        ".write": "auth != null && auth.uid == $apiculteurId"
      }
    },
    "ruchers": {
      "$rucherId": {
        ".read": "auth != null && (data.child('idApiculteur').val() == auth.uid || auth.token.email == 'admin@beetrackdemo.com')",
        ".write": "auth != null && (data.child('idApiculteur').val() == auth.uid || auth.token.email == 'admin@beetrackdemo.com')"
      }
    },
    "ruches": {
      "$rucheId": {
        ".read": "auth != null && (data.child('idApiculteur').val() == auth.uid || auth.token.email == 'admin@beetrackdemo.com')",
        ".write": "auth != null && (data.child('idApiculteur').val() == auth.uid || auth.token.email == 'admin@beetrackdemo.com')"
      }
    },
    "donnees_capteurs": {
      "$donneeId": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    },
    "donneesCapteurs": {
      "$donneeId": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    }
  }
}
```

## 🧪 Tests de validation

### Test 1 : Connexion de base
```bash
curl -X GET "https://rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app/.json"
```

### Test 2 : Écriture de test
```bash
curl -X PUT "https://rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app/test.json" \
  -H "Content-Type: application/json" \
  -d '{"message":"Test Realtime Database","timestamp":1234567890}'
```

### Test 3 : Lecture de test
```bash
curl -X GET "https://rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app/test.json"
```

### Test 4 : Application web
1. Démarrer l'application : `scripts/start-beetrack-realtime.bat`
2. Ouvrir : http://localhost:8080
3. Tester la connexion et les opérations CRUD

## ⚠️ Points d'attention

### 1. Structure des données
- Les données sont maintenant stockées en JSON dans Realtime Database
- Les timestamps utilisent `System.currentTimeMillis()` au lieu de `Timestamp`
- Les requêtes complexes sont gérées côté client

### 2. Performance
- Les requêtes sont plus simples mais peuvent être moins efficaces pour de gros volumes
- Le tri et le filtrage se font côté client
- Pas d'index composites comme Firestore

### 3. Sécurité
- Les règles de sécurité sont différentes de Firestore
- Vérifier que les règles sont correctement déployées
- Tester les permissions d'accès

## 🔍 Résolution des problèmes courants

### Erreur : "Firebase Database not found"
```bash
# Vérifier l'URL dans application.properties
firebase.database-url=https://rucheconnecteeesp32-default-rtdb.europe-west1.firebasedatabase.app
```

### Erreur : "Permission denied"
```bash
# Déployer les règles
firebase deploy --only database
```

### Erreur : "Timeout"
- Augmenter le timeout dans `FirebaseService.java` (ligne avec `latch.await(30, TimeUnit.SECONDS)`)
- Vérifier la connectivité réseau

### Erreur : "Service account not found"
- Vérifier que `firebase-service-account.json` est dans `src/main/resources/`
- Vérifier que le fichier contient les bonnes informations

## ✅ Checklist finale

- [ ] Realtime Database activé dans Firebase Console
- [ ] Règles de sécurité déployées
- [ ] Fichier service account en place
- [ ] Tests de connexion réussis
- [ ] Application démarre sans erreur
- [ ] Interface web fonctionnelle
- [ ] Opérations CRUD testées
- [ ] Logs sans erreur Firestore

## 🎉 Résultat attendu

Après ces actions, votre application :
- ✅ Utilise uniquement Firebase Realtime Database
- ✅ Ne génère plus l'erreur `PERMISSION_DENIED: Cloud Firestore API has not been used...`
- ✅ Fonctionne correctement avec toutes les fonctionnalités
- ✅ Est prête pour la production

## 📞 Support

Si vous rencontrez des problèmes :
1. Vérifier les logs de l'application
2. Tester la connexion avec les scripts fournis
3. Vérifier la configuration Firebase Console
4. Consulter la documentation de migration : `docs/MIGRATION_FIRESTORE_TO_REALTIME_DATABASE.md` 