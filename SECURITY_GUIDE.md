# 🛡️ Guide de Sécurisation - BeeTrack

## ⚠️ ACTIONS URGENTES APRÈS RÉCUPÉRATION DU PROJET

### 1. Configuration des Variables d'Environnement

#### Créer le fichier `.env` (NE JAMAIS COMMITTER)
```bash
cp .env.template .env
```

Puis éditer `.env` avec vos vraies valeurs :
```env
# Configuration Firebase - REMPLACER PAR VOS VRAIES VALEURS
FIREBASE_PROJECT_ID=votre-projet-firebase-id
FIREBASE_API_KEY=votre-cle-api-firebase
FIREBASE_DATABASE_URL=https://votre-projet-default-rtdb.region.firebasedatabase.app
FIREBASE_CREDENTIALS_PATH=firebase-service-account.json

# Configuration Email
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=votre-email@gmail.com
MAIL_PASSWORD=votre-mot-de-passe-application
```

### 2. Configuration Firebase

#### Créer le fichier service account
```bash
cp config/firebase/service-account.template.json config/firebase/service-account.json
```

Puis télécharger votre vraie clé service account depuis Firebase Console et remplacer le contenu.

#### Configuration Flutter
```bash
cp ruche-connectee/mobile-app/lib/firebase_options.template.dart ruche-connectee/mobile-app/lib/firebase_options.dart
```

Puis remplacer les valeurs par vos vraies configurations Firebase.

### 3. Configuration ESP32
```bash
# Éditer le fichier secrets.h avec vos vraies valeurs
# NE JAMAIS COMMITTER AVEC DE VRAIES VALEURS
```

## 🔒 RÈGLES DE SÉCURITÉ

### ✅ À FAIRE
- ✅ Utiliser uniquement des variables d'environnement pour les secrets
- ✅ Vérifier que `.gitignore` exclut tous les fichiers secrets
- ✅ Tester que les fichiers secrets ne sont pas trackés par Git
- ✅ Utiliser HTTPS en production
- ✅ Limiter CORS aux domaines autorisés
- ✅ Désactiver les logs de debug en production
- ✅ Régénérer toutes les clés si compromises

### ❌ À NE JAMAIS FAIRE
- ❌ Committer des clés API, mots de passe ou secrets
- ❌ Partager des fichiers de configuration avec des secrets
- ❌ Utiliser des secrets en dur dans le code
- ❌ Activer CORS pour tous les domaines (`*`) en production
- ❌ Laisser les logs de debug activés en production
- ❌ Ignorer les alertes de sécurité

## 🚨 PROCÉDURE EN CAS DE COMPROMISSION

### Si des secrets ont été exposés :

1. **IMMÉDIATEMENT** :
   - Révoquer toutes les clés exposées dans Firebase Console
   - Changer tous les mots de passe
   - Régénérer toutes les clés API

2. **Nettoyer l'historique Git** :
   ```bash
   # Supprimer les fichiers de l'historique
   git filter-branch --force --index-filter \
   'git rm --cached --ignore-unmatch path/to/secret/file' \
   --prune-empty --tag-name-filter cat -- --all
   
   # Forcer le push (ATTENTION : destructeur)
   git push origin --force --all
   ```

3. **Créer de nouveaux secrets** et reconfigurer

## 🔍 VÉRIFICATIONS RÉGULIÈRES

### Checklist de Sécurité

#### Avant chaque commit :
- [ ] Aucun fichier secret n'est staged
- [ ] Les variables d'environnement sont utilisées
- [ ] Aucune clé API en dur dans le code
- [ ] `.gitignore` est à jour

#### Avant déploiement :
- [ ] Configuration CORS limitée
- [ ] Logs de debug désactivés
- [ ] Variables d'environnement de production configurées
- [ ] Certificats SSL valides

#### Mensuellement :
- [ ] Rotation des clés API
- [ ] Vérification des accès Firebase
- [ ] Audit des logs d'accès
- [ ] Mise à jour des dépendances de sécurité

## 🛠️ COMMANDES UTILES

### Vérifier les fichiers trackés par Git :
```bash
git ls-files | grep -E "(secret|key|\.env|firebase.*\.json)" 
```

### Vérifier le statut Git :
```bash
git status --porcelain
```

### Rechercher des secrets dans le code :
```bash
grep -r "api.*key\|password\|secret" . --exclude-dir=.git
```

## 📞 SUPPORT

En cas de problème de sécurité :
1. Suivre la procédure de compromission ci-dessus
2. Documenter l'incident
3. Renforcer les mesures préventives

---

**⚠️ IMPORTANT** : Ce guide doit être suivi scrupuleusement pour maintenir la sécurité du projet. Toute négligence peut compromettre l'ensemble du système.