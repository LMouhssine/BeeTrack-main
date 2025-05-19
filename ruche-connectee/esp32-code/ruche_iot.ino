/**
 * Ruche Connectée - Module IoT ESP32
 * 
 * Ce programme permet de collecter des données de température, d'humidité
 * et de détection d'ouverture d'une ruche, puis de les envoyer à Firebase.
 * 
 * Matériel :
 * - ESP32
 * - Capteur DHT11 (température et humidité)
 * - Capteur magnétique (reed switch) pour détection d'ouverture
 * 
 * Connexions :
 * - DHT11 : GPIO4
 * - Reed switch : GPIO5
 * 
 * Auteur : Ruche Connectée Team
 * Date : 2023
 */

#include <WiFi.h>
#include <DHT.h>
#include <FirebaseESP32.h>
#include <ArduinoJson.h>
#include <time.h>
#include "secrets.h" // Contient les identifiants WiFi et Firebase

// Définition des pins
#define DHT_PIN 4
#define REED_PIN 5
#define LED_PIN 2

// Configuration du capteur DHT
#define DHT_TYPE DHT11
DHT dht(DHT_PIN, DHT_TYPE);

// Configuration Firebase
FirebaseData firebaseData;
FirebaseAuth auth;
FirebaseConfig config;

// Identifiant unique de la ruche (à configurer)
String rucheId = "ruche001";

// Intervalle entre les mesures (30 minutes = 1800000 ms)
const unsigned long INTERVAL_MS = 1800000;

// Variables pour le deep sleep
#define uS_TO_S_FACTOR 1000000  // Conversion de µs à s
RTC_DATA_ATTR int bootCount = 0;
RTC_DATA_ATTR bool lastLidState = false;

// Variables pour la détection d'ouverture
bool lidOpen = false;
unsigned long lastDebounceTime = 0;
unsigned long debounceDelay = 50;
int lastLidReading = HIGH;

void setup() {
  // Initialisation de la communication série
  Serial.begin(115200);
  Serial.println("\n=== Ruche Connectée - Module IoT ===");
  
  // Initialisation des pins
  pinMode(REED_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
  
  // Incrémentation du compteur de démarrage
  bootCount++;
  Serial.println("Démarrage #" + String(bootCount));
  
  // Initialisation du capteur DHT
  dht.begin();
  
  // Connexion au WiFi
  connectToWiFi();
  
  // Configuration de l'heure
  configTime(0, 0, "pool.ntp.org");
  
  // Initialisation de Firebase
  initFirebase();
  
  // Lecture des capteurs et envoi des données
  readAndSendData();
  
  // Préparation pour le deep sleep
  prepareForSleep();
}

void loop() {
  // Le programme n'atteint jamais cette boucle en raison du deep sleep
}

void connectToWiFi() {
  Serial.print("Connexion au WiFi");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  // Animation pendant la connexion
  int dots = 0;
  while (WiFi.status() != WL_CONNECTED) {
    digitalWrite(LED_PIN, dots % 2);
    delay(300);
    Serial.print(".");
    dots++;
    if (dots > 20) {
      Serial.println("\nÉchec de connexion WiFi. Redémarrage...");
      ESP.restart();
    }
  }
  
  digitalWrite(LED_PIN, HIGH);
  Serial.println("\nConnecté au WiFi!");
  Serial.print("Adresse IP: ");
  Serial.println(WiFi.localIP());
}

void initFirebase() {
  Serial.println("Initialisation de Firebase...");
  
  // Configuration de Firebase
  config.database_url = FIREBASE_HOST;
  config.api_key = FIREBASE_AUTH;
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  
  // Paramètres de timeout
  Firebase.setReadTimeout(firebaseData, 1000 * 60);
  Firebase.setwriteSizeLimit(firebaseData, "tiny");
  
  Serial.println("Firebase initialisé!");
}

void readAndSendData() {
  Serial.println("Lecture des capteurs...");
  
  // Lecture de la température et de l'humidité
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();
  
  // Vérification des valeurs
  if (isnan(humidity) || isnan(temperature)) {
    Serial.println("Échec de lecture du capteur DHT!");
    humidity = -1;
    temperature = -1;
  } else {
    Serial.println("Température: " + String(temperature) + "°C");
    Serial.println("Humidité: " + String(humidity) + "%");
  }
  
  // Lecture de l'état du couvercle
  lidOpen = digitalRead(REED_PIN) == HIGH;
  Serial.println("État du couvercle: " + String(lidOpen ? "Ouvert" : "Fermé"));
  
  // Lecture du niveau de batterie (simulation)
  int batteryLevel = getBatteryLevel();
  Serial.println("Niveau de batterie: " + String(batteryLevel) + "%");
  
  // Obtention du timestamp
  time_t now;
  time(&now);
  
  // Préparation des données JSON
  DynamicJsonDocument doc(256);
  doc["ruche_id"] = rucheId;
  doc["timestamp"] = now;
  doc["temperature"] = temperature;
  doc["humidity"] = humidity;
  doc["couvercle_ouvert"] = lidOpen;
  doc["batterie"] = batteryLevel;
  
  // Conversion en chaîne JSON
  String jsonData;
  serializeJson(doc, jsonData);
  Serial.println("Données JSON: " + jsonData);
  
  // Envoi des données à Firebase
  sendToFirebase(jsonData);
  
  // Vérification de l'ouverture du couvercle
  checkLidState();
}

void sendToFirebase(String jsonData) {
  Serial.println("Envoi des données à Firebase...");
  
  // Clignotement de la LED pour indiquer l'envoi
  for (int i = 0; i < 2; i++) {
    digitalWrite(LED_PIN, HIGH);
    delay(100);
    digitalWrite(LED_PIN, LOW);
    delay(100);
  }
  
  // Chemin dans la base de données
  String path = "/ruches/" + rucheId + "/donnees/" + String(time(NULL));
  
  // Envoi des données
  if (Firebase.setJSON(firebaseData, path, jsonData)) {
    Serial.println("Données envoyées avec succès!");
  } else {
    Serial.println("Échec de l'envoi des données:");
    Serial.println(firebaseData.errorReason());
  }
}

void checkLidState() {
  // Si le couvercle vient d'être ouvert, envoyer une alerte
  if (lidOpen && !lastLidState) {
    Serial.println("Alerte! Couvercle ouvert!");
    
    // Préparation des données d'alerte
    DynamicJsonDocument alertDoc(128);
    alertDoc["ruche_id"] = rucheId;
    alertDoc["timestamp"] = time(NULL);
    alertDoc["type"] = "ouverture_couvercle";
    
    String alertJson;
    serializeJson(alertDoc, alertJson);
    
    // Envoi de l'alerte
    String alertPath = "/alertes/" + String(time(NULL));
    if (Firebase.setJSON(firebaseData, alertPath, alertJson)) {
      Serial.println("Alerte envoyée avec succès!");
    } else {
      Serial.println("Échec de l'envoi de l'alerte:");
      Serial.println(firebaseData.errorReason());
    }
  }
  
  // Mise à jour de l'état précédent
  lastLidState = lidOpen;
}

int getBatteryLevel() {
  // Simulation du niveau de batterie
  // Dans une implémentation réelle, lire la tension de la batterie via un diviseur de tension
  return random(60, 100);
}

void prepareForSleep() {
  Serial.println("Préparation pour le deep sleep...");
  
  // Déconnexion du WiFi pour économiser l'énergie
  WiFi.disconnect(true);
  WiFi.mode(WIFI_OFF);
  
  // Configuration du réveil
  esp_sleep_enable_timer_wakeup(INTERVAL_MS * uS_TO_S_FACTOR);
  
  // Configuration du réveil sur changement d'état du couvercle
  esp_sleep_enable_ext0_wakeup(GPIO_NUM_5, !lidOpen);
  
  Serial.println("Entrée en deep sleep pour " + String(INTERVAL_MS / 1000) + " secondes");
  Serial.println("ou jusqu'à changement d'état du couvercle");
  
  // Clignotement final de la LED
  for (int i = 0; i < 3; i++) {
    digitalWrite(LED_PIN, HIGH);
    delay(100);
    digitalWrite(LED_PIN, LOW);
    delay(100);
  }
  
  // Entrée en deep sleep
  Serial.flush();
  esp_deep_sleep_start();
}