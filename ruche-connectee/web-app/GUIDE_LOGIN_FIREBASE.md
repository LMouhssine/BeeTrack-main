# Guide de connexion Firebase - BeeTrack

## ✅ Problème résolu !

Votre page de connexion `/login` utilise maintenant l'authentification Firebase tout en gardant la même interface.

## 🔑 Comment ça marche

### Détection automatique
- **Si Firebase est configuré** → Authentification Firebase
- **Si Firebase n'est pas configuré** → Spring Security classique (fallback)

### Page de connexion unique
- **URL**: http://localhost:8080/login
- **Interface**: Même design que before
- **Backend**: Firebase Authentication quand activé

## 🚀 Utilisation

1. **Démarrer avec Firebase** :
```bash
cd ruche-connectee/web-app
$env:FIREBASE_API_KEY="AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8"
mvn spring-boot:run
```

2. **Accéder à la page de connexion** :
```
http://localhost:8080/login
```

3. **Se connecter avec Firebase** :
   - Utilisez vos comptes Firebase existants
   - Email et mot de passe de votre console Firebase
   - L'indicateur "🔥 Authentification Firebase activée" confirme le mode

## 🎯 Fonctionnalités

### Interface utilisateur
- ✅ Design original conservé
- ✅ Messages d'erreur en temps réel
- ✅ Indicateur de chargement
- ✅ Redirection automatique après connexion

### Sécurité
- ✅ Sessions Firebase sécurisées
- ✅ Vérification d'authentification sur les pages protégées
- ✅ Déconnexion propre
- ✅ Redirection automatique si non connecté

### Fallback Spring Security
- ✅ Comptes admin/admin123 et user/user123 si Firebase désactivé
- ✅ Basculement transparent selon la configuration

## 📱 Pages accessibles après connexion

- **Dashboard**: http://localhost:8080/dashboard
- **Ruches**: http://localhost:8080/ruches  
- **Ruchers**: http://localhost:8080/ruchers
- **API**: http://localhost:8080/swagger-ui.html

## 🔧 Configuration

### Activer Firebase
Dans `application.properties` ou variable d'environnement :
```properties
firebase.api-key=AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8
```

### Désactiver Firebase
Supprimer ou commenter la ligne :
```properties
# firebase.api-key=AIzaSyBOo8k8r1m3a6N-eGOQ1C-2KOdOEn4Hq0e8
```

## 🐛 Dépannage

### Page ne répond pas
- Vérifiez que l'application est démarrée
- Consultez les logs pour les erreurs
- Vérifiez le port 8080

### Erreur "Firebase non configuré"
- Vérifiez la variable `FIREBASE_API_KEY`
- Redémarrez l'application après modification
- Vérifiez les logs de démarrage

### Comptes Firebase ne fonctionnent pas
- Vérifiez dans la console Firebase Authentication
- Assurez-vous que les comptes existent et sont activés
- Vérifiez que les mots de passe sont corrects

### Redirection en boucle
- Videz le cache du navigateur
- Vérifiez les sessions (F12 > Application > Storage)
- Redémarrez l'application

## 📞 Test rapide

1. ✅ Accès à http://localhost:8080/login
2. ✅ Indicateur Firebase visible
3. ✅ Saisie email/mot de passe Firebase
4. ✅ Message "Connexion réussie"
5. ✅ Redirection vers dashboard
6. ✅ Informations utilisateur affichées

**🎉 Votre authentification Firebase est maintenant intégrée dans votre page de connexion existante !**
