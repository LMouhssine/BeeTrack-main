# Organisation du Projet BeeTrack

## Structure de la Racine

La racine du projet a été nettoyée et organisée pour une meilleure lisibilité :

### Fichiers de Configuration
- `.firebaserc` - Configuration Firebase
- `firebase.json` - Configuration du déploiement Firebase
- `.gitignore` - Fichiers à ignorer par Git
- `README.md` - Documentation principale du projet

### Dossiers Principaux
- `config/` - Configuration Firebase et Firestore
- `docs/` - Documentation complète du projet
- `public/` - Fichiers statiques publics
- `ruche-connectee/` - Code source principal (mobile + web)
- `scripts/` - Scripts utilitaires
- `.github/` - Configuration GitHub Actions
- `.vscode/` - Configuration VS Code

## Organisation de la Documentation

### `docs/configuration/`
- `CONFIGURATION_FIREBASE_FINALE.md` - Guide de configuration Firebase
- Autres fichiers de configuration...

### `docs/troubleshooting/`
- `GUIDE_CONNEXION_RESOLU.md` - Solutions pour les problèmes de connexion
- `SOLUTION_URGENT_REDIRECTS.md` - Solutions pour les problèmes de redirection
- Autres guides de dépannage...

### `docs/developpement/`
- Guides de développement
- Documentation technique

### `docs/utilisateur/`
- Guides utilisateur
- Documentation d'utilisation

## Avantages de cette Organisation

1. **Lisibilité** : La racine est maintenant claire et ne contient que les fichiers essentiels
2. **Maintenabilité** : Chaque type de documentation a sa place
3. **Évolutivité** : Structure extensible pour de nouveaux documents
4. **Séparation des préoccupations** : Configuration, documentation, code et scripts sont séparés

## Migration Effectuée

Les fichiers suivants ont été déplacés de la racine vers leurs dossiers appropriés :
- `CONFIGURATION_FIREBASE_FINALE.md` → `docs/configuration/`
- `GUIDE_CONNEXION_RESOLU.md` → `docs/troubleshooting/`
- `SOLUTION_URGENT_REDIRECTS.md` → `docs/troubleshooting/` 