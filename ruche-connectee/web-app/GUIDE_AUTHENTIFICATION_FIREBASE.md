# Guide d'authentification Firebase pour BeeTrack

## 🎯 Problème résolu

L'application web BeeTrack utilisait uniquement Spring Security avec des utilisateurs en mémoire (admin/admin123). Maintenant, elle supporte l'authentification Firebase pour utiliser les comptes existants dans Firebase Authentication.

## 🔧 Configuration automatique

L'application détecte automatiquement si Firebase est configuré et active le bon système d'authentification :

- **Si Firebase est configuré** → Authentification Firebase (recommandé)
- **Si Firebase n'est pas configuré** → Spring Security classique

## 🚀 Démarrage rapide

### Option 1: Script de démarrage automatique
```bash
cd ruche-connectee/web-app
./start-firebase.bat
```

### Option 2: Démarrage manuel
```bash
cd ruche-connectee/web-app
set FIREBASE_API_KEY=AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8
mvn spring-boot:run
```

## 🌐 Pages d'accès

### Authentification Firebase (nouveau)
- **Page de connexion**: http://localhost:8080/firebase-login
- **Redirection automatique**: http://localhost:8080/ → firebase-login

### Authentification Spring Security (fallback)
- **Page de connexion**: http://localhost:8080/login
- **Utilisateurs de test**: 
  - admin / admin123 (rôle ADMIN)
  - user / user123 (rôle USER)

## 🔑 Comptes Firebase disponibles

Utilisez les comptes créés dans votre console Firebase Authentication :
- Allez sur https://console.firebase.google.com/
- Projet: `rucheconnecteeesp32`
- Section Authentication > Users
- Utilisez l'email et mot de passe des comptes existants

## 📱 Pages de l'application

Après connexion, vous avez accès à :
- **Dashboard**: http://localhost:8080/dashboard
- **Ruches**: http://localhost:8080/ruches
- **Ruchers**: http://localhost:8080/ruchers
- **Statistiques**: http://localhost:8080/statistiques
- **API Mobile**: http://localhost:8080/api/mobile/health

## 🔄 Basculer entre les modes

### Activer Firebase Authentication
Dans `application.properties`, configurez :
```properties
firebase.api-key=AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8
```

### Revenir à Spring Security
Dans `application.properties`, commentez ou supprimez :
```properties
# firebase.api-key=AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8
```

## 🛠️ Architecture technique

### Composants ajoutés

1. **FirebaseAuthController** - Gestion des connexions Firebase
2. **FirebaseSessionFilter** - Vérification des sessions Firebase  
3. **FirebaseSecurityConfig** - Configuration sécurité Firebase
4. **firebase-login.html** - Page de connexion Firebase moderne

### Flux d'authentification

1. L'utilisateur accède à `/firebase-login`
2. Saisie email/mot de passe Firebase
3. Appel API Firebase Authentication REST
4. Création session avec token Firebase
5. Redirection vers dashboard
6. Filtre vérifie la session sur chaque requête

## 🔒 Sécurité

- Tokens Firebase stockés en session
- Session invalidée à la déconnexion
- Filtre de sécurité sur toutes les routes protégées
- Clé API Firebase sécurisée par variables d'environnement

## 🐛 Dépannage

### Erreur "Nom d'utilisateur ou mot de passe incorrect"
- Vérifiez que le compte existe dans Firebase Authentication
- Vérifiez que le mot de passe est correct
- Consultez la console Firebase pour les logs

### Erreur "Firebase non configuré"
- Vérifiez que `firebase.api-key` est définie
- Vérifiez que le fichier `firebase-service-account.json` existe
- Redémarrez l'application après modification

### Page de connexion non accessible
- Vérifiez l'URL : http://localhost:8080/firebase-login
- Vérifiez les logs d'application pour les erreurs
- Essayez le mode Spring Security : http://localhost:8080/login

## 📞 Support

En cas de problème :
1. Consultez les logs de l'application
2. Vérifiez la console Firebase Authentication
3. Testez d'abord avec Spring Security pour valider le reste de l'app
4. Vérifiez les variables d'environnement Firebase
