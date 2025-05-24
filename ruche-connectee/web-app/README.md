# BeeTrack - API Web Backend

API REST Spring Boot pour le système de ruches connectées BeeTrack. Cette API reproduit et étend les fonctionnalités de l'application mobile Flutter en fournissant un backend web complet.

## 🚀 Fonctionnalités

### 🔐 Gestion des Apiculteurs
- Création et gestion des comptes apiculteurs
- Authentification avec Firebase Auth
- Profils utilisateur complets
- Connexion par email ou identifiant

### 🐝 Gestion des Ruches
- CRUD complet des ruches
- Données de capteurs IoT en temps réel
- Historique des mesures
- Système d'alertes automatiques
- Seuils personnalisables

### 📍 Gestion des Ruchers
- Organisation des ruches par emplacement
- Géolocalisation des ruchers
- Comptage automatique des ruches

### 📊 Données IoT
- Réception des données ESP32
- Température et humidité
- État d'ouverture du couvercle
- Niveau de batterie
- Stockage historique

## 🛠️ Technologies

- **Spring Boot 3.1.3** - Framework principal
- **Firebase Admin SDK** - Authentification et Firestore
- **Google Cloud Firestore** - Base de données NoSQL
- **Lombok** - Réduction du code boilerplate
- **SpringDoc OpenAPI** - Documentation API automatique
- **Maven** - Gestion des dépendances

## 📋 Prérequis

- Java 17 ou supérieur
- Maven 3.6+
- Compte Firebase avec projet configuré
- Fichier de credentials Firebase

## ⚙️ Installation

### 1. Cloner le projet
```bash
git clone https://github.com/LMouhssine/BeeTrack-main.git
cd BeeTrack-main/ruche-connectee/web-app
```

### 2. Configuration Firebase

1. Créer un projet Firebase sur [Firebase Console](https://console.firebase.google.com)
2. Activer Firestore Database
3. Activer Firebase Authentication (Email/Password)
4. Générer une clé privée de compte de service :
   - Aller dans Paramètres du projet > Comptes de service
   - Cliquer sur "Générer une nouvelle clé privée"
   - Télécharger le fichier JSON

5. Placer le fichier JSON dans `src/main/resources/` et le renommer `firebase-service-account.json`

### 3. Configuration de l'application

Modifier `src/main/resources/application.properties` :
```properties
firebase.project-id=VOTRE_PROJECT_ID
firebase.credentials-path=firebase-service-account.json
```

### 4. Compilation et lancement
```bash
mvn clean install
mvn spring-boot:run
```

L'API sera accessible sur `http://localhost:8080`

## 📚 Documentation API

Une fois l'application lancée, la documentation Swagger est disponible sur :
- **Swagger UI** : http://localhost:8080/swagger-ui.html
- **OpenAPI JSON** : http://localhost:8080/api-docs

## 🔗 Endpoints Principaux

### Apiculteurs
```
GET    /api/apiculteurs              - Liste tous les apiculteurs
GET    /api/apiculteurs/{id}         - Récupère un apiculteur
POST   /api/apiculteurs              - Crée un apiculteur
PUT    /api/apiculteurs/{id}         - Met à jour un apiculteur
DELETE /api/apiculteurs/{id}         - Désactive un apiculteur

POST   /api/apiculteurs/auth/email   - Authentification par email
POST   /api/apiculteurs/auth/identifiant - Récupère email par identifiant
```

### Ruchers
```
GET    /api/ruchers/apiculteur/{id}  - Ruchers d'un apiculteur
GET    /api/ruchers/{id}             - Récupère un rucher
POST   /api/ruchers                  - Crée un rucher
PUT    /api/ruchers/{id}             - Met à jour un rucher
DELETE /api/ruchers/{id}             - Désactive un rucher
```

### Ruches
```
GET    /api/ruches/apiculteur/{id}   - Ruches d'un apiculteur
GET    /api/ruches/rucher/{id}       - Ruches d'un rucher
GET    /api/ruches/{id}              - Récupère une ruche
POST   /api/ruches                   - Crée une ruche
PUT    /api/ruches/{id}              - Met à jour une ruche
DELETE /api/ruches/{id}              - Désactive une ruche

POST   /api/ruches/{id}/donnees      - Données capteurs (ESP32)
GET    /api/ruches/{id}/historique   - Historique des données
GET    /api/ruches/{id}/alertes      - Vérification des alertes
```

## 📱 Intégration ESP32

L'ESP32 peut envoyer les données directement à l'API :

```cpp
// Exemple de payload JSON pour ESP32
{
  "temperature": 25.5,
  "humidity": 65.0,
  "couvercle_ouvert": false,
  "batterie": 85,
  "signal_qualite": 90
}
```

Endpoint : `POST /api/ruches/{rucheId}/donnees`

## 🔄 Synchronisation avec l'App Mobile

L'API partage la même base de données Firestore que l'application mobile Flutter, garantissant une synchronisation en temps réel des données.

## 🚨 Système d'Alertes

Le système vérifie automatiquement :
- Température hors seuils (défaut : 15-35°C)
- Humidité hors seuils (défaut : 40-70%)
- Batterie faible (< 20%)
- Ouverture prolongée du couvercle

## 🧪 Tests

```bash
# Tests unitaires
mvn test

# Tests d'intégration
mvn verify
```

## 📦 Déploiement

### Docker
```bash
# Construction de l'image
docker build -t ruche-connectee-api .

# Lancement du conteneur
docker run -p 8080:8080 ruche-connectee-api
```

### Production
1. Configurer les variables d'environnement
2. Utiliser un profil de production
3. Configurer HTTPS
4. Mettre en place la surveillance

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit les changements (`git commit -am 'Ajout nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Créer une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Consulter la documentation Swagger
- Vérifier les logs de l'application

---

**Note** : Cette API est conçue pour fonctionner en parfaite harmonie avec l'application mobile Flutter existante, partageant la même base de données et la même logique métier.