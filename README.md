<div align="center">

<img src="public/logo.svg" alt="BeeTrack Logo" width="120" height="120">

# BEETRCK

**Plateforme de Surveillance Intelligente pour Ruches Connectées**

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-green.svg)](https://spring.io/projects/spring-boot)
[![Thymeleaf](https://img.shields.io/badge/Thymeleaf-3.x-blue.svg)](https://www.thymeleaf.org/)
[![Firebase](https://img.shields.io/badge/Firebase-11.7.3-orange.svg)](https://firebase.google.com/)
[![Java](https://img.shields.io/badge/Java-17+-red.svg)](https://openjdk.java.net/)

*Application web professionnelle pour la surveillance et la gestion de ruches connectées*

</div>

## 📋 Vue d'ensemble

BeeTrack est une plateforme complète permettant aux apiculteurs de surveiller leurs ruches connectées en temps réel. L'application offre une interface web moderne basée sur Spring Boot pour suivre les paramètres vitaux des ruches, gérer les alertes et analyser les données historiques.

### ✨ Fonctionnalités principales

- 🔐 **Authentification sécurisée** avec Firebase Auth (intégration serveur)
- 📦 **Gestion des ruchers et ruches** avec organisation hiérarchique
- 📊 **Surveillance en temps réel** des données de capteurs IoT
- 🚨 **Système d'alertes intelligent** (couvercle ouvert, anomalies température/humidité)
- 📈 **Tableaux de bord et statistiques** avec graphiques interactifs
- 📱 **Interface responsive** adaptée à tous les appareils
- 🔄 **Synchronisation temps réel** avec Firebase Firestore

## 🚀 Démarrage rapide

### Prérequis

- Java 17 ou supérieur
- Maven 3.8+
- Compte Firebase configuré
- IDE Java (IntelliJ IDEA recommandé)

### Installation

```bash
# Cloner le projet
git clone https://github.com/votre-username/BeeTrack-main.git
cd BeeTrack-main

# Naviguer vers l'application web
cd ruche-connectee/web-app

# Configurer Firebase (voir section Configuration)
# Copier firebase-service-account.json dans src/main/resources/

# Lancer l'application
mvn spring-boot:run
```

L'application sera accessible sur `http://localhost:8080`

### Build de production

```bash
mvn clean package
java -jar target/web-app-*.jar
```

## 🏗️ Architecture

### Stack technique

- **Backend** : Spring Boot 3.x + Spring MVC
- **Frontend** : Thymeleaf + HTML5 + CSS3 + JavaScript ES6
- **Base de données** : Firebase Firestore
- **Authentification** : Firebase Auth (intégration côté serveur)
- **Charts** : Chart.js
- **Icons** : Lucide Icons
- **CSS Framework** : Bootstrap 5 + CSS personnalisé

### Structure du projet

```
ruche-connectee/web-app/
├── src/main/java/com/rucheconnectee/
│   ├── controller/          # Contrôleurs Spring MVC
│   │   ├── WebController.java
│   │   ├── RucheController.java
│   │   └── ...
│   ├── service/            # Services métier
│   │   ├── RucheService.java
│   │   ├── RucherService.java
│   │   ├── FirebaseService.java
│   │   └── ...
│   ├── model/              # Modèles de données
│   │   ├── Ruche.java
│   │   ├── Rucher.java
│   │   └── ...
│   └── config/             # Configuration Spring
│       ├── FirebaseConfig.java
│       └── SecurityConfig.java
├── src/main/resources/
│   ├── templates/          # Templates Thymeleaf
│   │   ├── layout.html     # Template de base
│   │   ├── dashboard.html
│   │   ├── ruchers.html
│   │   ├── ruches-list.html
│   │   ├── ruche-details.html
│   │   └── statistiques.html
│   ├── static/            # Ressources statiques
│   │   ├── css/app.css    # Styles personnalisés
│   │   ├── js/app.js      # JavaScript
│   │   └── logo.svg
│   └── application.properties
└── pom.xml                # Configuration Maven
```

## 🔧 Configuration

### Firebase

1. Créer un projet Firebase
2. Activer Authentication (Email/Password)
3. Configurer Firestore Database
4. Télécharger le fichier `firebase-service-account.json`
5. Placer le fichier dans `src/main/resources/`
6. Configurer `application.properties`

```properties
# application.properties
firebase.project-id=votre-projet-id
firebase.service-account=firebase-service-account.json

# Configuration serveur
server.port=8080
spring.thymeleaf.cache=false
```

### Variables d'environnement (optionnel)

```bash
export FIREBASE_PROJECT_ID=votre-projet-id
export FIREBASE_SERVICE_ACCOUNT=chemin/vers/firebase-service-account.json
```

### Structure Firestore

```
apiculteurs/           # Collection des utilisateurs
  {userId}/
    - email: string
    - nom: string
    - prenom: string
    - role: string

ruchers/              # Collection des ruchers
  {rucherId}/
    - nom: string
    - adresse: string
    - idApiculteur: string
    - superficie: number
    - actif: boolean
    - dateCreation: Timestamp

ruches/               # Collection des ruches
  {rucheId}/
    - nom: string
    - type: string
    - idRucher: string
    - idApiculteur: string
    - actif: boolean
    - numeroSerie: string
    - dateCreation: Timestamp

donneesCapteurs/      # Collection des mesures
  {mesureId}/
    - rucheId: string
    - timestamp: Timestamp
    - temperature: number
    - humidite: number
    - poids: number
    - activite: string
    - couvercleOuvert: boolean
    - niveauBatterie: number
```

## 🎯 Fonctionnalités détaillées

### Interface web complète

#### Dashboard principal
- Vue d'ensemble avec KPIs temps réel
- Graphiques de température et humidité
- Actions rapides (ajouter ruche, voir statistiques)
- Feed d'activité récente

#### Gestion des ruchers
- Liste complète avec recherche et filtres
- Modal d'ajout/modification de ruchers
- Statistiques par rucher (nombre de ruches, superficie)
- Actions de suppression sécurisées

#### Gestion des ruches
- Vue grille et liste commutable
- Filtres avancés (rucher, statut, recherche)
- Indicateurs visuels de statut
- Données en temps réel (température, humidité, poids)

#### Détails des ruches
- Métriques temps réel avec indicateurs de tendance
- Graphiques historiques interactifs (Chart.js)
- Gestion des alertes actives
- Actions de maintenance (calibrage, redémarrage)

#### Statistiques et analyses
- Production de miel estimée
- Performance par rucher
- Top ruches performantes
- Recommandations automatiques
- Comparaisons régionales

### Système d'alertes intelligent
- Détection automatique d'anomalies
- Alertes configurables (température, humidité, batterie)
- Notifications visuelles en temps réel
- Historique des alertes avec résolution

## 🧪 Tests et développement

### Outils de diagnostic intégrés

L'application inclut des endpoints de diagnostic :
- `/test` : Test de connectivité Firebase
- `/api/health` : Statut de l'application
- Génération de données de test pour développement

### Commandes Maven

```bash
mvn spring-boot:run     # Serveur de développement
mvn clean package       # Build de production
mvn test               # Tests unitaires
mvn spring-boot:build-image  # Image Docker
```

### Modes de développement

```bash
# Mode développement avec rechargement automatique
mvn spring-boot:run -Dspring.profiles.active=dev

# Mode production
mvn spring-boot:run -Dspring.profiles.active=prod
```

## 🐳 Déploiement Docker

```dockerfile
# Dockerfile
FROM openjdk:17-jre-slim
COPY target/web-app-*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

```bash
# Build et déploiement
mvn clean package
docker build -t beetrck-web .
docker run -p 8080:8080 beetrck-web
```

## 📱 URLs de l'application

Une fois l'application démarrée :

- **Dashboard** : http://localhost:8080/dashboard
- **Ruchers** : http://localhost:8080/ruchers
- **Ruches** : http://localhost:8080/ruches
- **Statistiques** : http://localhost:8080/statistiques
- **Test Firebase** : http://localhost:8080/test

## 🔄 Architecture Spring Boot + Thymeleaf

Cette application utilise une architecture moderne avec rendu côté serveur :

### Avantages de l'architecture
- **Performance** : Rendu côté serveur, moins de JavaScript
- **SEO** : Pages indexables par défaut
- **Sécurité** : Logique métier protégée côté serveur
- **Simplicité** : Un seul langage (Java), pas de build frontend
- **Maintenance** : Architecture unifiée
- **Déploiement** : Un seul JAR à déployer

### Composants clés
- **Spring Boot 3.x** : Framework backend
- **Thymeleaf** : Moteur de templates
- **Firebase Admin SDK** : Intégration Firebase côté serveur
- **Bootstrap 5** : Framework CSS responsive
- **Chart.js** : Graphiques interactifs
- **Lucide Icons** : Icônes modernes

## 📚 Documentation

La documentation détaillée est disponible dans le dossier `/docs` :

- **Configuration** : Guides d'installation et configuration Firebase
- **Développement** : Architecture Spring Boot et guides de développement  
- **Utilisateur** : Guides d'utilisation des fonctionnalités web

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez :

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit les changements (`git commit -am 'Ajouter nouvelle fonctionnalité'`)
4. Push sur la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Créer une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🆘 Support

- **Issues** : Reportez les bugs sur GitHub Issues
- **Documentation** : Consultez le dossier `/docs`
- **Firebase** : Vérifiez la configuration dans `application.properties`

---

<div align="center">

**Développé avec ❤️ pour les apiculteurs connectés**

*BeeTrack - Surveillez vos ruches, optimisez votre production*

</div> 