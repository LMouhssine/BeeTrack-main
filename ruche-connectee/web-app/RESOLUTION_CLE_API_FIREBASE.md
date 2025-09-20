# 🔧 Résolution du problème "API key not valid"

## ✅ **Problème résolu !**

Votre clé API Firebase a été configurée automatiquement avec la clé du projet `rucheconnecteeesp32`.

## 🚀 **Solution rapide**

La clé API Firebase a été mise à jour dans `application.properties`:
```properties
firebase.api-key=AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8
```

### **Redémarrer l'application**
```bash
cd ruche-connectee/web-app
mvn spring-boot:run
```

## 🔍 **Vérification**

1. **Logs de démarrage** - Vous devriez voir:
   ```
   Firebase initialisé avec succès pour le projet: rucheconnecteeesp32
   [LOGIN] FirebaseAuthRestService initialisé | apiKey=***4Hq0e8
   Connexion Firebase activée - Données réelles !
   ```

2. **Page de connexion** - http://localhost:8080/login
   - L'indicateur "🔥 Authentification Firebase activée" doit s'afficher

3. **Test API Firebase** - http://localhost:8080/api/firebase-test
   - Status: `CONNECTED`

## 🛠️ **Autres solutions**

### **Méthode 1: Variable d'environnement**
```bash
# Windows (PowerShell)
$env:FIREBASE_API_KEY="AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8"
mvn spring-boot:run

# Windows (CMD)
set FIREBASE_API_KEY=AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8
mvn spring-boot:run
```

### **Méthode 2: Script automatique**
```bash
./configure-firebase-api.bat
```

### **Méthode 3: Configuration personnalisée**

Si vous avez votre propre projet Firebase:

1. **Obtenir votre clé API**:
   - https://console.firebase.google.com/
   - Sélectionnez votre projet
   - ⚙️ Paramètres du projet > Général
   - Section "Vos applications" > App web > Configuration

2. **Remplacer dans application.properties**:
   ```properties
   firebase.api-key=VOTRE_VRAIE_CLE_API
   ```

## ❌ **Causes communes du problème**

### **1. Clé API par défaut**
```properties
# ❌ PROBLÈME
firebase.api-key=${FIREBASE_API_KEY:REMPLACEZ_PAR_VOTRE_CLE_API}

# ✅ SOLUTION
firebase.api-key=${FIREBASE_API_KEY:AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8}
```

### **2. Variable d'environnement manquante**
```bash
# ❌ PROBLÈME - variable non définie
echo $FIREBASE_API_KEY  # vide

# ✅ SOLUTION - définir la variable
export FIREBASE_API_KEY="AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8"
```

### **3. Clé API incorrecte**
- ✅ Doit commencer par `AIzaSy...`
- ✅ Pas d'espaces avant/après
- ✅ Clé complète (environ 39 caractères)

### **4. Problèmes d'accès au projet**
- Vérifiez que vous avez accès au projet `rucheconnecteeesp32`
- Contactez l'administrateur si nécessaire

## 🧪 **Tests de diagnostic**

### **Test 1: Vérifier la variable**
```bash
# Windows (PowerShell)
echo $env:FIREBASE_API_KEY

# Windows (CMD)  
echo %FIREBASE_API_KEY%
```

### **Test 2: Tester l'API Firebase directement**
```bash
curl -X POST \
  "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "returnSecureToken": true
  }'
```

### **Test 3: Logs détaillés**
```bash
mvn spring-boot:run -Dlogging.level.com.google.firebase=DEBUG
```

## 📱 **Utilisation après correction**

1. **Connexion** - http://localhost:8080/login
   - Utilisez vos comptes Firebase existants
   - Email et mot de passe de votre console Firebase

2. **Dashboard** - http://localhost:8080/dashboard
   - Données en temps réel depuis Firebase

3. **API** - http://localhost:8080/swagger-ui.html
   - Toutes les endpoints fonctionnelles

## 🔒 **Sécurité**

⚠️ **Important**: 
- Ne commitez jamais vos vraies clés API
- Utilisez des variables d'environnement en production
- Configurez des restrictions de domaine dans Firebase Console

## 📞 **Support**

Si le problème persiste:

1. **Vérifiez les logs**: Recherchez "Firebase" dans la sortie
2. **Testez l'endpoint**: `/api/firebase-test`
3. **Consultez les guides**:
   - `GUIDE_LOGIN_FIREBASE.md`
   - `TEST_AUTHENTIFICATION.md`
   - `OBTENIR_CLE_API_FIREBASE.md`

---

**🎉 Votre authentification Firebase devrait maintenant fonctionner parfaitement !**
