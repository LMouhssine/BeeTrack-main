# Configuration Firebase

## Vue d'ensemble

Ce document explique comment configurer Firebase pour l'application BeeTrack.

## Structure des fichiers

```
config/
└── firebase/
    └── service-account.json    # Fichier de configuration Firebase (backup)

ruche-connectee/web-app/src/main/resources/
└── firebase-service-account.json    # Fichier utilisé par l'application
```

## Configuration actuelle

### Projet Firebase
- **Projet ID**: `rucheconnecteeesp32`
- **Service Account**: `firebase-adminsdk-fbsvc@rucheconnecteeesp32.iam.gserviceaccount.com`

### Fichier de configuration
Le fichier `config/firebase/service-account.json` contient :
- Les clés privées pour l'authentification
- Les informations du projet
- Les URLs d'authentification

## Configuration de l'application

### application.properties
```properties
# Configuration Firebase
firebase.project-id=rucheconnecteeesp32
firebase.credentials-path=firebase-service-account.json
```

### FirebaseConfig.java
La classe `FirebaseConfig` gère :
- L'initialisation de Firebase
- La configuration de Firestore
- L'authentification Firebase

## Sécurité

⚠️ **IMPORTANT** : Le fichier `service-account.json` contient des clés privées sensibles.

### Bonnes pratiques
1. **Ne jamais commiter** le fichier `service-account.json` dans Git
2. **Utiliser des variables d'environnement** en production
3. **Restreindre les permissions** du service account
4. **Régulièrement renouveler** les clés

### .gitignore
Le fichier est déjà exclu du versioning :
```
config/firebase/service-account.json
```

## Test de la configuration

### Script de test
```bash
scripts/test-firebase-config.bat
```

### Test manuel
1. Démarrer l'application :
   ```bash
   cd ruche-connectee/web-app
   mvn spring-boot:run
   ```

2. Vérifier les logs :
   - `Firebase initialisé avec succès` = Configuration OK
   - Erreurs = Problème de configuration

## Dépannage

### Erreurs courantes

1. **Fichier non trouvé**
   - Vérifier que `config/firebase/service-account.json` existe
   - Vérifier le chemin dans `application.properties`

2. **Erreur d'authentification**
   - Vérifier que les clés privées sont correctes
   - Vérifier que le service account a les bonnes permissions

3. **Projet ID incorrect**
   - Vérifier `firebase.project-id` dans `application.properties`
   - Vérifier que le projet existe dans Firebase Console

### Logs utiles
```properties
logging.level.com.google.firebase=DEBUG
logging.level.com.google.cloud=DEBUG
```

## Migration vers un nouveau projet

Pour changer de projet Firebase :

1. **Remplacer** `config/firebase/service-account.json`
2. **Mettre à jour** `firebase.project-id` dans `application.properties`
3. **Tester** avec le script de test
4. **Vérifier** les permissions du nouveau service account

## Support

En cas de problème :
1. Vérifier les logs de l'application
2. Tester avec le script de test
3. Vérifier la configuration Firebase Console
4. Consulter la documentation Firebase 