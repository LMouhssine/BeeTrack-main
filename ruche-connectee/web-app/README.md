# Backend Spring Boot - Ruche Connectée

## 🖥️ Présentation

Le backend de Ruche Connectée est une API REST développée avec Spring Boot qui gère les données des ruches connectées, l'authentification des utilisateurs et le système d'alertes.

## ✨ Fonctionnalités

- 🔐 **Authentification** via Firebase
- 📊 **API REST complète** pour :
  - Gestion des apiculteurs
  - Gestion des ruchers
  - Gestion des ruches
  - Accès aux données des capteurs
- 📈 **Historisation** des données
- 📧 **Système d'alertes** par email
- 📝 **Documentation API** avec Swagger

## 🏗️ Architecture

Le backend suit une architecture en couches :

- **Controller** : Points d'entrée de l'API REST
- **Service** : Logique métier
- **Repository** : Accès aux données
- **Model** : Entités et DTOs
- **Config** : Configuration de l'application
- **Security** : Gestion de l'authentification

## 🚀 Installation

### Prérequis

- Java JDK 17+
- Maven
- Compte Firebase
- Serveur SMTP pour les emails

### Configuration

1. Clonez le dépôt et accédez au dossier du backend :
```bash
git clone https://github.com/votre-utilisateur/ruche-connectee.git
cd ruche-connectee/web-app
```

2. Configurez les propriétés de l'application dans `src/main/resources/application.properties` :
```properties
# Configuration du serveur
server.port=8080

# Configuration Firebase
firebase.database-url=https://votre-projet.firebaseio.com
firebase.storage-bucket=votre-projet.appspot.com
firebase.credentials-file-path=classpath:firebase-service-account.json

# Configuration email
spring.mail.host=smtp.example.com
spring.mail.port=587
spring.mail.username=your-email@example.com
spring.mail.password=your-password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
```

3. Placez votre fichier de configuration Firebase (`firebase-service-account.json`) dans `src/main/resources/`

4. Lancez l'application :
```bash
./mvnw spring-boot:run
```

## 📁 Structure du projet

```
src/
├── main/
│   ├── java/com/rucheconnectee/
│   │   ├── config/           # Configuration
│   │   ├── controller/       # Contrôleurs REST
│   │   ├── dto/              # Objets de transfert de données
│   │   ├── exception/        # Gestion des exceptions
│   │   ├── model/            # Entités
│   │   ├── repository/       # Accès aux données
│   │   ├── security/         # Configuration de sécurité
│   │   ├── service/          # Services métier
│   │   └── RucheConnecteeApplication.java
│   └── resources/
│       ├── application.properties
│       └── firebase-service-account.json
└── test/                     # Tests unitaires et d'intégration
```

## 📚 Documentation API

La documentation de l'API est disponible via Swagger UI à l'adresse :
```
http://localhost:8080/swagger-ui.html
```

## 🧪 Tests

Pour exécuter les tests :
```bash
./mvnw test
```

## 🚢 Déploiement

Pour créer un package déployable :
```bash
./mvnw clean package
```

Le fichier JAR sera généré dans le dossier `target/`.

## 🔄 Intégration continue

Le projet utilise GitHub Actions pour l'intégration continue. Voir le fichier `.github/workflows/maven.yml` pour plus de détails.

## 🛠️ Technologies utilisées

- **Spring Boot** : Framework Java
- **Spring Security** : Sécurité et authentification
- **Firebase Admin SDK** : Intégration avec Firebase
- **Firestore** : Base de données
- **JavaMail** : Envoi d'emails
- **Swagger** : Documentation API
- **JUnit & Mockito** : Tests
- **Maven** : Gestion des dépendances