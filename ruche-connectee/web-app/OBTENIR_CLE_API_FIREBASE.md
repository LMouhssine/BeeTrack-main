# 🔑 Comment obtenir votre clé API Firebase

## 📍 **Méthode 1: Console Firebase (Recommandé)**

### Étapes détaillées :

1. **Ouvrir la console Firebase**
   ```
   https://console.firebase.google.com/
   ```

2. **Sélectionner votre projet**
   - Cliquez sur **"rucheconnecteeesp32"**

3. **Accéder aux paramètres**
   - Cliquez sur l'icône ⚙️ **"Paramètres du projet"** (en haut à gauche)

4. **Trouver la configuration web**
   - Dans l'onglet **"Général"**
   - Descendez à la section **"Vos applications"**
   - Trouvez votre application web (icône </> )
   - Cliquez sur **"Configuration"**

5. **Copier la clé API**
   ```javascript
   const firebaseConfig = {
     apiKey: "AIzaSy......"  // ← COPIEZ CETTE VALEUR
     // ...
   };
   ```

## 📍 **Méthode 2: Script automatique**

1. **Exécuter le script de configuration**
   ```bash
   cd ruche-connectee/web-app
   ./configure-firebase.bat
   ```

2. **Suivre les instructions**
   - Le script vous guidera étape par étape
   - Collez votre clé API quand demandée
   - L'application démarrera automatiquement

## 📍 **Méthode 3: Configuration manuelle**

### Modifier application.properties
```properties
firebase.api-key=VOTRE_VRAIE_CLE_API_ICI
```

### Ou variable d'environnement
```bash
$env:FIREBASE_API_KEY="VOTRE_VRAIE_CLE_API_ICI"
mvn spring-boot:run
```

## ⚠️ **Erreurs courantes**

### "API key not valid"
- ✅ Vérifiez que vous avez copié la clé complète
- ✅ Pas d'espaces avant/après la clé
- ✅ La clé commence par "AIzaSy..."

### "Project not found"
- ✅ Vérifiez le nom du projet : "rucheconnecteeesp32"
- ✅ Vous avez accès au projet Firebase

### "Configuration not found"
- ✅ Créez une app web dans Firebase si pas encore fait
- ✅ Section "Paramètres du projet" > "Vos applications"

## 🔒 **Sécurité**

- ⚠️ Ne commitez jamais votre vraie clé API
- ✅ Utilisez des variables d'environnement
- ✅ Ajoutez des restrictions de domaine dans Firebase

## 📞 **Test rapide**

Une fois configuré :
1. Redémarrez l'application
2. Allez sur http://localhost:8080/login
3. Vérifiez que "🔥 Authentification Firebase activée" s'affiche
4. Testez avec un compte Firebase existant

---

**💡 Besoin d'aide ?** Vérifiez que votre compte a bien accès au projet Firebase "rucheconnecteeesp32"
