# Module IoT ESP32 - Ruche Connectée

## 🔌 Présentation

Le module IoT de Ruche Connectée est basé sur l'ESP32 et permet de collecter des données environnementales des ruches (température, humidité) ainsi que de détecter l'ouverture du couvercle. Ces données sont ensuite transmises à Firebase pour être accessibles via l'application mobile et le backend.

## ✨ Fonctionnalités

- 🌡️ **Mesure de la température** via capteur DHT11
- 💧 **Mesure de l'humidité** via capteur DHT11
- 🚪 **Détection d'ouverture** du couvercle via capteur magnétique
- 🔋 **Gestion d'énergie** optimisée (mode deep sleep)
- 📡 **Transmission des données** vers Firebase toutes les 30 minutes
- 🔄 **Mode de configuration** via WiFi pour paramétrage initial

## 🛠️ Matériel nécessaire

- ESP32 (recommandé : ESP32-WROOM-32)
- Capteur DHT11 (température et humidité)
- Capteur magnétique (reed switch) pour la détection d'ouverture
- Batterie LiPo 3.7V (recommandé : 2000mAh minimum)
- Panneau solaire 5V (optionnel pour l'autonomie)
- Boîtier étanche IP65 ou supérieur

## 📋 Schéma de connexion

```
ESP32           DHT11
-----           -----
3.3V    ------> VCC
GPIO4   ------> DATA
GND     ------> GND

ESP32           Reed Switch
-----           -----------
GPIO5   ------> Pin 1
GND     ------> Pin 2
```

## 🚀 Installation

### Prérequis

- Arduino IDE
- Bibliothèques ESP32 pour Arduino
- Compte Firebase avec Realtime Database configurée

### Configuration

1. Installez l'Arduino IDE et configurez-le pour l'ESP32 :
   - Ajoutez l'URL `https://dl.espressif.com/dl/package_esp32_index.json` dans les préférences
   - Installez la carte ESP32 via le gestionnaire de cartes

2. Installez les bibliothèques nécessaires :
   - DHT sensor library
   - Firebase ESP32 Client
   - ArduinoJson
   - WiFiManager

3. Créez un fichier `secrets.h` avec vos informations de connexion :
```cpp
#define WIFI_SSID "votre_ssid"
#define WIFI_PASSWORD "votre_mot_de_passe"
#define FIREBASE_HOST "votre-projet.firebaseio.com"
#define FIREBASE_AUTH "votre_cle_secrete"
```

4. Téléversez le code sur votre ESP32

## 📊 Format des données

Les données sont envoyées à Firebase au format JSON :

```json
{
  "ruche_id": "ruche123",
  "timestamp": 1630000000,
  "temperature": 25.5,
  "humidity": 65.0,
  "couvercle_ouvert": false,
  "batterie": 85
}
```

## ⚡ Consommation d'énergie

Le module est optimisé pour une faible consommation :
- Mode actif : ~80mA
- Mode deep sleep : ~10µA
- Cycle de réveil toutes les 30 minutes
- Autonomie estimée : 3-6 mois avec batterie 2000mAh (selon conditions)
- Autonomie illimitée avec panneau solaire adapté

## 🔧 Dépannage

### Problèmes courants

- **Pas de connexion WiFi** : Vérifiez les identifiants dans `secrets.h`
- **Erreurs de lecture DHT11** : Vérifiez le câblage et la résistance pull-up
- **Pas de données dans Firebase** : Vérifiez les règles de sécurité Firebase

### Diagnostic

Le module dispose d'une LED de diagnostic :
- Clignotement rapide : Connexion WiFi en cours
- Double clignotement : Envoi de données en cours
- Triple clignotement : Erreur de connexion
- Clignotement lent : Mode configuration actif

## 🛠️ Technologies utilisées

- **ESP32** : Microcontrôleur
- **Arduino** : Environnement de développement
- **Firebase RTDB** : Stockage des données
- **DHT11** : Capteur de température et d'humidité
- **WiFiManager** : Configuration WiFi simplifiée