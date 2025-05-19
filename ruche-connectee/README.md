# Ruche Connectée - Système de Surveillance pour Apiculteurs

## 📋 Vue d'ensemble

Ce projet propose une solution complète de surveillance de ruches pour les apiculteurs, combinant une application mobile, un backend et des capteurs IoT pour suivre en temps réel l'état des ruches.

### Fonctionnalités principales

- 📱 **Application mobile** pour visualiser les données des ruches
- 🌐 **Backend** pour gérer les données et envoyer des alertes
- 🔌 **Module IoT** pour collecter les données environnementales
- 📊 **Visualisation des données** : température, humidité, état du couvercle
- ⏰ **Alertes** en cas d'ouverture non autorisée
- 📈 **Historique** des données sur 7 jours

## 🏗️ Architecture du système

![Architecture du système](docs/ruche-architecture.png)

## 🧩 Composants du projet

### 📱 Application Mobile (Flutter)
- Interface utilisateur intuitive pour les apiculteurs
- Authentification via Firebase
- Visualisation des données en temps réel et historiques
- Gestion des alertes

### 🖥️ Backend (Spring Boot)
- API REST pour la gestion des données
- Intégration avec Firebase
- Système d'alertes par email
- Documentation API via Swagger

### 🔌 Module IoT (ESP32)
- Capteurs de température et d'humidité (DHT11)
- Détection d'ouverture du couvercle
- Transmission des données via WiFi

## 🚀 Démarrage rapide

### Prérequis
- Flutter SDK
- Java JDK 17+
- Arduino IDE
- Compte Firebase
- ESP32 avec capteurs DHT11 et détecteur d'ouverture

### Installation

1. Clonez le dépôt :
```bash
git clone https://github.com/votre-utilisateur/ruche-connectee.git
cd ruche-connectee
```

2. Configurez l'application mobile :
```bash
cd mobile-app
flutter pub get
```

3. Configurez le backend :
```bash
cd ../web-app
./mvnw clean install
```

4. Téléversez le code sur l'ESP32 via l'Arduino IDE

## 📚 Documentation

Pour plus de détails sur chaque composant, consultez les README spécifiques :
- [Application Mobile](mobile-app/README.md)
- [Backend](web-app/README.md)
- [Module IoT](esp32-code/README.md)

## 🤝 Contribution

Les contributions sont les bienvenues ! Consultez notre [guide de contribution](CONTRIBUTING.md) pour plus d'informations.

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.