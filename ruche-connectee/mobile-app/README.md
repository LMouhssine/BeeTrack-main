# Application Mobile - Ruche Connectée

## 📱 Présentation

L'application mobile Ruche Connectée permet aux apiculteurs de surveiller leurs ruches à distance. Elle offre une interface intuitive pour visualiser les données en temps réel, gérer les alertes et suivre l'historique des mesures.

## ✨ Fonctionnalités

- 🔐 **Authentification** via Firebase
- 👥 **Gestion des profils** d'apiculteurs
- 📍 **Organisation** des ruchers et ruches
- 📊 **Visualisation des données** :
  - Température
  - Humidité
  - État du couvercle (ouvert/fermé)
- 📈 **Historique** des données sur 7 jours
- 🔔 **Gestion des alertes** avec possibilité de désactivation temporaire

## 🏗️ Architecture

L'application est construite avec Flutter et suit l'architecture BLoC (Business Logic Component) pour une séparation claire des responsabilités :

- **Présentation** : Widgets et écrans
- **Logique métier** : BLoCs et Cubits
- **Données** : Repositories et Services
- **Modèles** : Entités et DTOs

## 🚀 Installation

### Prérequis

- Flutter SDK (dernière version stable)
- Compte Firebase
- Android Studio / VS Code avec plugins Flutter

### Configuration

1. Clonez le dépôt et accédez au dossier de l'application :
```bash
git clone https://github.com/votre-utilisateur/ruche-connectee.git
cd ruche-connectee/mobile-app
```

2. Installez les dépendances :
```bash
flutter pub get
```

3. Configurez Firebase :
   - Créez un projet dans la console Firebase
   - Ajoutez une application Android et iOS
   - Téléchargez les fichiers de configuration (`google-services.json` et `GoogleService-Info.plist`)
   - Placez-les dans les dossiers appropriés

4. Lancez l'application :
```bash
flutter run
```

## 📁 Structure du projet

```
lib/
├── blocs/           # Business Logic Components
├── models/          # Modèles de données
├── repositories/    # Accès aux données
├── screens/         # Écrans de l'application
├── services/        # Services (Firebase, etc.)
├── utils/           # Utilitaires et helpers
├── widgets/         # Widgets réutilisables
└── main.dart        # Point d'entrée de l'application
```

## 🧪 Tests

Pour exécuter les tests :
```bash
flutter test
```

## 📦 Publication

### Android
```bash
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

## 🛠️ Technologies utilisées

- **Flutter** : Framework UI
- **Firebase Auth** : Authentification
- **Cloud Firestore** : Base de données
- **Firebase Messaging** : Notifications push
- **fl_chart** : Visualisation de graphiques
- **provider** : Gestion d'état
- **get_it** : Injection de dépendances

## 📝 Notes de développement

- L'application utilise le thème Material Design avec une palette de couleurs personnalisée
- Les données sont mises en cache pour une utilisation hors ligne
- Les notifications sont configurées pour alerter l'utilisateur en cas d'ouverture non autorisée