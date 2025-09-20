# Structure du Projet BeeTrack

## 📁 Vue d'ensemble de l'organisation

Ce document décrit la structure organisée du projet BeeTrack après le nettoyage et la réorganisation.

```
BeeTrack-main/
├── 📁 config/                          # Configurations globales
│   ├── 📁 firebase/                     # Credentials Firebase (exclus du git)
│   │   └── 🔐 *.json                   # Clés de service Firebase
│   └── 📄 firestore.indexes.json       # Index Firestore
│
├── 📁 docs/                             # Documentation complète
│   ├── 📁 configuration/               # Guides de configuration
│   │   ├── 📄 AUTHENTIFICATION_RESOLUTION.md
│   │   └── 📄 FIREBASE_SETUP_INDEX.md
│   ├── 📁 developpement/               # Guides de développement
│   │   ├── 📄 GUIDE_SPRING_BOOT.md
│   │   └── 📄 MIGRATION_REACT_TO_SPRINGBOOT.md
│   ├── 📁 troubleshooting/             # Résolution de problèmes
│   │   ├── 📄 RESOLUTION_PROBLEME_TIMESTAMP.md
│   │   ├── 📄 TEST_CONNEXION.md
│   │   └── 📄 SOLUTION_CONNEXION.md
│   ├── 📁 utilisateur/                 # Documentation utilisateur
│   │   └── 📄 GUIDE_UTILISATEUR_WEB.md
│   ├── 📁 obsolete/                    # Archives
│   ├── 📄 README.md                    # Documentation principale
│   ├── 📄 DEMARRAGE_RAPIDE.md         # Guide de démarrage rapide
│   └── 📄 START.md                     # Instructions de démarrage
│
├── 📁 scripts/                          # Scripts utilitaires
│   └── 📄 test-app.bat                 # Script de test de l'application
│
├── 📁 public/                           # Ressources publiques
│   └── 🖼️ logo.svg                     # Logo du projet
│
├── 📁 ruche-connectee/                  # Code source principal
│   ├── 📁 web-app/                     # Application web Spring Boot
│   │   ├── 📁 src/main/java/com/rucheconnectee/
│   │   │   ├── 📁 controller/          # Contrôleurs MVC
│   │   │   ├── 📁 service/             # Services métier
│   │   │   ├── 📁 model/               # Modèles de données
│   │   │   └── 📁 config/              # Configuration Spring
│   │   ├── 📁 src/main/resources/
│   │   │   ├── 📁 templates/           # Templates Thymeleaf
│   │   │   ├── 📁 static/              # CSS, JS, images
│   │   │   └── 📄 application.properties
│   │   └── 📄 pom.xml                  # Configuration Maven
│   │
│   ├── 📁 mobile-app/                  # Application mobile Flutter
│   │   ├── 📁 lib/                     # Code source Dart
│   │   │   ├── 📁 blocs/               # Gestion d'état BLoC
│   │   │   ├── 📁 screens/             # Écrans de l'application
│   │   │   ├── 📁 services/            # Services API et Firebase
│   │   │   ├── 📁 models/              # Modèles de données
│   │   │   └── 📁 widgets/             # Composants réutilisables
│   │   ├── 📁 android/                 # Configuration Android
│   │   ├── 📁 ios/                     # Configuration iOS
│   │   └── 📄 pubspec.yaml            # Dépendances Flutter
│   │
│   ├── 📁 esp32-code/                  # Code microcontrôleur
│   │   ├── 📄 ruche_iot.ino           # Code Arduino ESP32
│   │   └── 📄 README.md               # Documentation ESP32
│   │
│   └── 📄 README.md                    # Documentation du composant
│
├── 📄 README.md                         # Documentation principale du projet
├── 📄 .gitignore                       # Exclusions Git
└── 📁 .github/                         # Workflows GitHub Actions
```

## 🎯 Organisation par composants

### 🌐 Application Web (Spring Boot)
- **Emplacement** : `ruche-connectee/web-app/`
- **Technologie** : Spring Boot 3.x + Thymeleaf
- **Port** : 8080
- **Base de données** : Firebase Firestore

### 📱 Application Mobile (Flutter)
- **Emplacement** : `ruche-connectee/mobile-app/`
- **Technologie** : Flutter + Dart
- **Plateformes** : Android, iOS, Web

### 🔌 Code IoT (ESP32)
- **Emplacement** : `ruche-connectee/esp32-code/`
- **Technologie** : Arduino IDE + ESP32
- **Capteurs** : Température, humidité, poids, détection couvercle

## 🔧 Configuration

### Firebase
- **Credentials** : Stockés dans `config/firebase/` (exclus du git)
- **Configuration** : `config/firestore.indexes.json`
- **Services utilisés** : Authentication, Firestore

### Sécurité
- Fichiers sensibles exclus via `.gitignore`
- Credentials Firebase isolés dans `config/firebase/`
- Variables d'environnement pour la production

## 🚀 Scripts de développement

### Test de l'application
```bash
# Windows
scripts/test-app.bat

# Linux/Mac
cd ruche-connectee/web-app
mvn spring-boot:run
```

### Build de production
```bash
cd ruche-connectee/web-app
mvn clean package
```

## 📚 Documentation

- **Configuration** : `docs/configuration/`
- **Développement** : `docs/developpement/`
- **Dépannage** : `docs/troubleshooting/`
- **Utilisateur** : `docs/utilisateur/`

## 🔄 Workflow de développement

1. **Setup initial** : Suivre `docs/DEMARRAGE_RAPIDE.md`
2. **Configuration Firebase** : `docs/configuration/FIREBASE_SETUP_INDEX.md`
3. **Tests** : Utiliser `scripts/test-app.bat`
4. **Dépannage** : Consulter `docs/troubleshooting/`

---

*Cette structure garantit une organisation claire, une sécurité renforcée et une maintenabilité optimale du projet BeeTrack.* 