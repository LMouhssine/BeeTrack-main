# 🔧 Résolution des problèmes Firebase

## Problème : "class path resource [config/firebase/service-account.json] cannot be opened because it does not exist"

### Cause
Spring Boot ne peut pas accéder au fichier Firebase depuis le dossier `config/` car il n'est pas dans le classpath.

### Solution
Copier le fichier dans les ressources de l'application :

```bash
# Depuis la racine du projet
copy "config\firebase\service-account.json" "ruche-connectee\web-app\src\main\resources\firebase-service-account.json"
```

### Configuration mise à jour
```properties
# application.properties
firebase.credentials-path=firebase-service-account.json
```

## Problème : "Erreur lors de l'initialisation de Firestore"

### Causes possibles
1. **Fichier Firebase manquant**
2. **Clés privées incorrectes**
3. **Projet ID incorrect**
4. **Permissions insuffisantes**

### Solutions

#### 1. Vérifier le fichier
```bash
# Vérifier que le fichier existe
ls ruche-connectee\web-app\src\main\resources\firebase-service-account.json
```

#### 2. Vérifier la configuration
```properties
# application.properties
firebase.project-id=rucheconnecteeesp32
firebase.credentials-path=firebase-service-account.json
```

#### 3. Vérifier les permissions Firebase
- Aller dans Firebase Console
- Vérifier que le service account a les bonnes permissions
- Vérifier que Firestore est activé

## Problème : "Port 8080 already in use"

### Solution
```bash
# Trouver le processus
netstat -ano | findstr :8080

# Tuer le processus (remplacer PID)
taskkill /PID <PID> /F

# Ou utiliser un autre port
mvn spring-boot:run -Dserver.port=8081
```

## Problème : "Java version not supported"

### Solution
```bash
# Vérifier la version Java
java -version

# Doit être 17 ou supérieur
# Télécharger depuis https://adoptium.net/ si nécessaire
```

## Tests de diagnostic

### Test rapide
```bash
scripts/test-app-final.bat
```

### Test complet
```bash
scripts/test-firebase-config.ps1
```

### Test manuel
```bash
cd ruche-connectee/web-app
mvn spring-boot:run
```

## Logs utiles

### Activer les logs détaillés
```properties
# application.properties
logging.level.com.google.firebase=DEBUG
logging.level.com.google.cloud=DEBUG
logging.level.com.rucheconnectee=DEBUG
```

### Messages de succès
```
Firebase initialisé avec succès pour le projet: rucheconnecteeesp32
```

### Messages d'erreur courants
```
Erreur lors de l'initialisation de Firebase: [message]
Fonctionnement en mode dégradé avec données mockées
```

## Prévention

### Bonnes pratiques
1. **Toujours copier** le fichier Firebase dans `src/main/resources/`
2. **Vérifier** la configuration avant de démarrer
3. **Tester** avec les scripts fournis
4. **Consulter** les logs en cas de problème

### Structure recommandée
```
ruche-connectee/web-app/src/main/resources/
├── application.properties
├── firebase-service-account.json    # Fichier Firebase
└── templates/                       # Templates Thymeleaf
```

## Support

En cas de problème persistant :
1. Vérifier les logs détaillés
2. Tester avec les scripts de diagnostic
3. Vérifier la configuration Firebase Console
4. Consulter la documentation Firebase 