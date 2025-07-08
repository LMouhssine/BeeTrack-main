# 🚀 Guide de démarrage rapide - BeeTrack

Guide complet pour démarrer rapidement avec BeeTrack (version Spring Boot + Thymeleaf).

## ⚡ Démarrage en 5 minutes

### 1. Prérequis
```powershell
# Vérifier Java (requis : 17+)
java -version

# Vérifier Maven
cd ruche-connectee/web-app
mvn -version
```

### 2. Configuration Firebase
```powershell
# S'assurer que le fichier firebase-service-account.json est présent
ls src/main/resources/firebase-service-account.json
```

### 3. Lancement
```powershell
# Démarrer l'application (PowerShell)
cd ruche-connectee/web-app
mvn spring-boot:run

# Alternative avec séparateur PowerShell
cd ruche-connectee/web-app; mvn spring-boot:run
```

### 4. Accès à l'application
- **Dashboard** : http://localhost:8080/dashboard
- **Test Firebase** : http://localhost:8080/test

## 🐚 Commandes par shell

### PowerShell (Windows)
```powershell
# Naviguer et démarrer
cd ruche-connectee/web-app
mvn spring-boot:run

# Mode développement
mvn spring-boot:run -Dspring.profiles.active=dev

# Mode debug
mvn spring-boot:run -Dagentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005

# Build
mvn clean package

# Tests
mvn test
```

### Command Prompt (Windows)
```cmd
cd ruche-connectee\web-app
mvn spring-boot:run

REM Mode développement
mvn spring-boot:run -Dspring.profiles.active=dev
```

### Bash/Zsh (Linux/macOS)
```bash
cd ruche-connectee/web-app
mvn spring-boot:run

# Mode développement
mvn spring-boot:run -Dspring.profiles.active=dev
```

## 🔧 Configuration rapide

### application.properties minimal
```properties
# Configuration serveur
server.port=8080

# Configuration Firebase
firebase.project-id=votre-projet-id
firebase.service-account=firebase-service-account.json

# Mode développement
spring.thymeleaf.cache=false
logging.level.com.rucheconnectee=INFO
```

### Variables d'environnement (optionnel)
```powershell
# PowerShell
$env:FIREBASE_PROJECT_ID="votre-projet-id"
$env:SERVER_PORT="8080"

# Puis lancer
mvn spring-boot:run
```

## 📱 URLs essentielles

Une fois l'application démarrée :

| Page | URL | Description |
|------|-----|-------------|
| **Dashboard** | http://localhost:8080/dashboard | Page d'accueil avec métriques |
| **Ruchers** | http://localhost:8080/ruchers | Gestion des ruchers |
| **Ruches** | http://localhost:8080/ruches | Liste des ruches |
| **Statistiques** | http://localhost:8080/statistiques | Analyses et rapports |
| **Test Firebase** | http://localhost:8080/test | Test de connexion |
| **Health Check** | http://localhost:8080/actuator/health | Statut application |

## 🧪 Génération de données de test

```powershell
# Après démarrage de l'application
curl -X POST http://localhost:8080/dev/mock-data

# Ou via navigateur
# http://localhost:8080/dev/mock-data (méthode POST)
```

## 🔍 Diagnostic rapide

### Vérification du statut
```powershell
# Test de base
curl http://localhost:8080/actuator/health

# Test Firebase
curl http://localhost:8080/test

# Test page principale
curl -I http://localhost:8080/dashboard
```

### Logs en temps réel
```powershell
# Démarrer avec logs verbeux
mvn spring-boot:run -Dlogging.level.com.rucheconnectee=DEBUG

# Ou suivre les logs (si configuré)
Get-Content logs/spring.log -Wait -Tail 50
```

## ❌ Résolution des problèmes courants

### Erreur : "Port 8080 already in use"
```powershell
# Trouver le processus utilisant le port 8080
netstat -ano | findstr :8080

# Tuer le processus (remplacer PID par l'ID trouvé)
taskkill /PID <PID> /F

# Ou utiliser un autre port
mvn spring-boot:run -Dserver.port=8081
```

### Erreur : "firebase-service-account.json not found"
```powershell
# Vérifier la présence du fichier
ls src/main/resources/firebase-service-account.json

# Si absent, télécharger depuis Firebase Console :
# 1. Firebase Console > Paramètres projet > Comptes de service
# 2. Générer nouvelle clé privée
# 3. Placer dans src/main/resources/
```

### Erreur : "Java version not supported"
```powershell
# Vérifier la version Java
java -version

# Doit être 17 ou supérieur
# Télécharger depuis https://adoptium.net/ si nécessaire
```

### Application ne démarre pas
```powershell
# Nettoyer et rebuilder
mvn clean install

# Vérifier les dépendances
mvn dependency:tree

# Mode debug Maven
mvn spring-boot:run -X
```

## 🐳 Docker (optionnel)

### Build et run avec Docker
```powershell
# Build du JAR
mvn clean package

# Build de l'image Docker
docker build -t beetrck-web .

# Run du conteneur
docker run -p 8080:8080 `
  -e FIREBASE_PROJECT_ID=votre-projet `
  -v ${PWD}/src/main/resources/firebase-service-account.json:/app/firebase-service-account.json `
  beetrck-web
```

## 📋 Checklist de vérification

Après démarrage, vérifier que :

- [ ] Application démarre sans erreur
- [ ] Port 8080 est accessible
- [ ] Page dashboard s'affiche : http://localhost:8080/dashboard
- [ ] Firebase est connecté : http://localhost:8080/test
- [ ] Health check répond : http://localhost:8080/actuator/health
- [ ] Logs ne montrent pas d'erreurs critiques

## 🔄 Redémarrage rapide

```powershell
# Arrêter l'application (Ctrl+C dans le terminal)
# Puis relancer
mvn spring-boot:run

# Ou avec rechargement automatique des templates
mvn spring-boot:run -Dspring.thymeleaf.cache=false
```

## 📚 Prochaines étapes

1. **Explorer l'interface** : Naviguer dans les différentes pages
2. **Ajouter des données** : Créer des ruchers et ruches de test
3. **Consulter la documentation** : Lire `/docs/README.md`
4. **Personnaliser** : Modifier les templates Thymeleaf
5. **Déployer** : Suivre le guide de déploiement

---

<div align="center">

**BeeTrack démarré avec succès !** 🎉  
*Spring Boot + Thymeleaf ready to go*

</div> 