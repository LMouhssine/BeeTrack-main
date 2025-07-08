# 🚀 BeeTrack Web Application

Application web Spring Boot pour la gestion et surveillance de ruches connectées.

## 📋 Vue d'ensemble

Cette application web utilise Spring Boot + Thymeleaf pour offrir une interface complète de gestion des ruches connectées avec rendu côté serveur optimisé.

## 🏗️ Architecture technique

- **Backend** : Spring Boot 3.x avec Spring MVC
- **Frontend** : Thymeleaf + Bootstrap 5 + JavaScript vanilla
- **Base de données** : Firebase Firestore via Firebase Admin SDK
- **Authentification** : Firebase Auth (intégration serveur)
- **Graphiques** : Chart.js
- **Icons** : Lucide Icons

## 🚀 Démarrage rapide

### Prérequis
- Java 17 ou supérieur
- Maven 3.8+
- Fichier `firebase-service-account.json` dans `src/main/resources/`

### Installation et lancement

```bash
# Cloner le projet (si pas déjà fait)
git clone https://github.com/votre-repo/BeeTrack-main.git
cd BeeTrack-main/ruche-connectee/web-app

# Lancer l'application
mvn spring-boot:run

# Ou sur Windows PowerShell
mvn spring-boot:run
```

L'application sera disponible sur : **http://localhost:8080**

### Build de production

```bash
# Créer le JAR exécutable
mvn clean package

# Lancer le JAR
java -jar target/web-app-*.jar
```

## 📁 Structure du projet

```
src/
├── main/
│   ├── java/com/rucheconnectee/
│   │   ├── BeeTrackApplication.java          # Point d'entrée
│   │   ├── config/
│   │   │   ├── FirebaseConfig.java           # Configuration Firebase
│   │   │   ├── SecurityConfig.java           # Configuration sécurité
│   │   │   └── DevelopmentConfig.java        # Config développement
│   │   ├── controller/
│   │   │   ├── WebController.java            # Pages principales
│   │   │   ├── RucheController.java          # API Ruches
│   │   │   ├── RucherController.java         # API Ruchers
│   │   │   └── TestController.java           # Tests et diagnostic
│   │   ├── service/
│   │   │   ├── FirebaseService.java          # Service Firebase
│   │   │   ├── RucheService.java            # Logique ruches
│   │   │   ├── RucherService.java           # Logique ruchers
│   │   │   └── MockDataService.java         # Données de test
│   │   └── model/
│   │       ├── Ruche.java                   # Modèle ruche
│   │       ├── Rucher.java                  # Modèle rucher
│   │       └── DonneesCapteur.java          # Modèle données capteurs
│   └── resources/
│       ├── application.properties           # Configuration app
│       ├── firebase-service-account.json    # Clés Firebase (privé)
│       ├── templates/                       # Templates Thymeleaf
│       │   ├── layout.html                  # Template de base
│       │   ├── dashboard.html               # Page d'accueil
│       │   ├── ruchers.html                 # Gestion ruchers
│       │   ├── ruches-list.html             # Liste ruches
│       │   ├── ruche-details.html           # Détails ruche
│       │   └── statistiques.html            # Statistiques
│       └── static/                          # Ressources statiques
│           ├── css/app.css                  # Styles principaux
│           ├── js/app.js                    # JavaScript principal
│           └── logo.svg                     # Logo
└── test/
    └── java/com/rucheconnectee/            # Tests unitaires
```

## 🔧 Configuration

### application.properties

```properties
# Configuration serveur
server.port=8080
server.servlet.context-path=/

# Configuration Thymeleaf
spring.thymeleaf.cache=false
spring.thymeleaf.encoding=UTF-8

# Configuration Firebase
firebase.project-id=votre-projet-id
firebase.service-account=firebase-service-account.json

# Configuration logging
logging.level.com.rucheconnectee=INFO
logging.level.com.google.firebase=WARN
```

### Variables d'environnement (optionnel)

```bash
export FIREBASE_PROJECT_ID=votre-projet-id
export FIREBASE_SERVICE_ACCOUNT=/path/to/firebase-service-account.json
export SERVER_PORT=8080
```

## 🌐 Pages et fonctionnalités

### Dashboard (`/dashboard`)
- Vue d'ensemble avec métriques clés
- Graphiques de température et humidité
- Feed d'activité récente
- Actions rapides

### Ruchers (`/ruchers`)
- Liste complète des ruchers
- Recherche et filtres
- Ajout/modification/suppression
- Statistiques par rucher

### Ruches (`/ruches`)
- Vue grille et liste
- Filtres avancés (rucher, statut)
- Indicateurs de santé
- Données temps réel

### Détails ruche (`/ruche/{id}`)
- Métriques détaillées
- Graphiques historiques
- Gestion des alertes
- Actions de maintenance

### Statistiques (`/statistiques`)
- Analyses de production
- Performance par rucher
- Recommandations
- Comparaisons

## 🔍 Endpoints API

### Pages web
- `GET /` → Redirection vers `/dashboard`
- `GET /dashboard` → Dashboard principal
- `GET /ruchers` → Gestion des ruchers
- `GET /ruches` → Liste des ruches
- `GET /ruche/{id}` → Détails d'une ruche
- `GET /statistiques` → Page de statistiques

### API REST
- `GET /api/ruchers` → Liste des ruchers (JSON)
- `POST /api/ruchers` → Créer un rucher
- `PUT /api/ruchers/{id}` → Modifier un rucher
- `DELETE /api/ruchers/{id}` → Supprimer un rucher
- `GET /api/ruches` → Liste des ruches (JSON)
- `GET /api/ruches/{id}` → Détails d'une ruche
- `GET /api/ruches/{id}/mesures` → Mesures d'une ruche

### Diagnostic
- `GET /test` → Test de connexion Firebase
- `GET /api/health` → Statut de l'application
- `POST /dev/mock-data` → Générer des données de test

## 🧪 Tests et développement

### Profils d'environnement

```bash
# Développement avec live reload
mvn spring-boot:run -Dspring.profiles.active=dev

# Production
mvn spring-boot:run -Dspring.profiles.active=prod

# Tests
mvn spring-boot:run -Dspring.profiles.active=test
```

### Génération de données de test

```bash
# Via endpoint (mode dev uniquement)
curl -X POST http://localhost:8080/dev/mock-data

# Via MockDataService programmatiquement
@Autowired MockDataService mockDataService;
mockDataService.generateTestData();
```

### Tests unitaires

```bash
# Lancer tous les tests
mvn test

# Tests spécifiques
mvn test -Dtest=FirebaseServiceTest
mvn test -Dtest=RucheControllerTest
```

### Débogage

```bash
# Mode debug avec port 5005
mvn spring-boot:run -Dagentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005

# Logs détaillés
mvn spring-boot:run -Dlogging.level.com.rucheconnectee=DEBUG
```

## 📊 Monitoring

### Spring Boot Actuator

```bash
# Santé de l'application
curl http://localhost:8080/actuator/health

# Métriques
curl http://localhost:8080/actuator/metrics

# Informations
curl http://localhost:8080/actuator/info
```

### Logs

```bash
# Logs en temps réel
tail -f logs/spring.log

# Logs Firebase
tail -f logs/spring.log | grep Firebase
```

## 🐳 Docker

### Dockerfile

```dockerfile
FROM openjdk:17-jre-slim

# Variables d'environnement
ENV SPRING_PROFILES_ACTIVE=prod
ENV SERVER_PORT=8080

# Copier le JAR
COPY target/web-app-*.jar app.jar

# Exposer le port
EXPOSE 8080

# Point d'entrée
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

### Build et déploiement

```bash
# Build du JAR
mvn clean package

# Build de l'image Docker
docker build -t beetrck-web .

# Lancer le conteneur
docker run -p 8080:8080 \
  -e FIREBASE_PROJECT_ID=votre-projet \
  -v /path/to/firebase-service-account.json:/app/firebase-service-account.json \
  beetrck-web
```

## 🔧 Dépannage

### Problèmes courants

#### Application ne démarre pas
```bash
# Vérifier Java
java -version

# Vérifier Maven
mvn -version

# Nettoyer et rebuilder
mvn clean install
```

#### Erreurs Firebase
```bash
# Vérifier le fichier service account
ls -la src/main/resources/firebase-service-account.json

# Tester la connexion
curl http://localhost:8080/test
```

#### Templates Thymeleaf non trouvés
```properties
# Dans application.properties
spring.thymeleaf.prefix=classpath:/templates/
spring.thymeleaf.suffix=.html
```

#### Ressources statiques non servies
```properties
# Dans application.properties
spring.web.resources.static-locations=classpath:/static/
```

### Logs utiles

```bash
# Erreurs de démarrage
mvn spring-boot:run | grep ERROR

# Problèmes Thymeleaf
mvn spring-boot:run | grep "TemplateInputException"

# Erreurs Firebase
mvn spring-boot:run | grep "FirebaseException"
```

## 📚 Documentation supplémentaire

- **Documentation Spring Boot** : https://spring.io/projects/spring-boot
- **Guide Thymeleaf** : https://www.thymeleaf.org/documentation.html
- **Firebase Admin SDK** : https://firebase.google.com/docs/admin/setup
- **Bootstrap 5** : https://getbootstrap.com/docs/5.3/

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit les changements (`git commit -am 'Ajouter nouvelle fonctionnalité'`)
4. Push sur la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Créer une Pull Request

### Standards de code

- **Java** : Style Google Java
- **Thymeleaf** : Indentation 2 espaces
- **JavaScript** : ES6+ avec commentaires JSDoc
- **CSS** : BEM methodology

---

<div align="center">

**BeeTrack Web Application**  
*Version Spring Boot + Thymeleaf*

Développé avec ❤️ pour les apiculteurs connectés

</div>