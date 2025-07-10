# 🚀 Démarrage Rapide - BeeTrack

## Configuration Firebase ✅

Votre configuration Firebase est maintenant prête !

### ✅ Ce qui est configuré
- **Projet Firebase**: `rucheconnecteeesp32`
- **Fichier de configuration**: `config/firebase/service-account.json`
- **Application Spring Boot**: Configurée pour utiliser Firebase

## 🎯 Démarrage de l'application

### Option 1: Script de démarrage (Recommandé)
```bash
scripts/start-beetrck.bat
```

### Option 2: Commande manuelle
```bash
cd ruche-connectee/web-app
mvn spring-boot:run
```

### Option 3: Test complet
```bash
scripts/test-firebase-config.ps1
```

## 🌐 Accès à l'application

Une fois démarrée, l'application est accessible sur :
- **URL principale**: http://localhost:8080
- **Dashboard**: http://localhost:8080/dashboard
- **Ruchers**: http://localhost:8080/ruchers
- **Ruches**: http://localhost:8080/ruches

## 📊 Vérification

### Logs à surveiller
```
Firebase initialisé avec succès pour le projet: rucheconnecteeesp32
```

### Test de connexion
1. Ouvrir http://localhost:8080
2. Vérifier que les pages se chargent
3. Tester les fonctionnalités Firebase

## 🔧 Dépannage

### Problème: Application ne démarre pas
```bash
# Vérifier Java et Maven
java -version
mvn -version

# Nettoyer et redémarrer
mvn clean
mvn spring-boot:run
```

### Problème: Erreur Firebase
1. Vérifier `config/firebase/service-account.json`
2. Vérifier `application.properties`
3. Consulter les logs détaillés

### Problème: Port 8080 occupé
```bash
# Changer le port dans application.properties
server.port=8081
```

## 📚 Documentation complète

- **Configuration Firebase**: `docs/configuration/FIREBASE_CONFIGURATION.md`
- **Structure du projet**: `docs/STRUCTURE_PROJET.md`
- **Guide utilisateur**: `docs/utilisateur/GUIDE_UTILISATEUR_WEB.md`

## 🎉 Félicitations !

Votre application BeeTrack est maintenant configurée et prête à utiliser Firebase ! 