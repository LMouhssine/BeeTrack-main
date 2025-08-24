# 🔒 Sécurité Firebase - Guide de configuration

## ⚠️ **IMPORTANT - Sécurité des clés API**

**❌ NE JAMAIS COMMITTER :**
- Votre vraie clé API Firebase
- Les fichiers .env avec des vraies valeurs
- Le fichier firebase-service-account.json

**✅ TOUJOURS UTILISER :**
- Variables d'environnement
- Fichiers de configuration locaux (.gitignore)
- Valeurs par défaut sécurisées dans le code

## 🔧 **Configuration sécurisée**

### 1. Copier le fichier exemple
```bash
cp firebase-config.example firebase-config.sh
```

### 2. Modifier avec vos vraies valeurs
```bash
nano firebase-config.sh
# Remplacez VOTRE_VRAIE_CLE_API_ICI par votre clé
```

### 3. Charger la configuration
```bash
source firebase-config.sh
mvn spring-boot:run
```

### 4. Ou directement en une ligne
```bash
FIREBASE_API_KEY="VOTRE_CLE_ICI" mvn spring-boot:run
```

## 🛡️ **Bonnes pratiques de sécurité**

### Variables d'environnement uniquement
- Jamais de clés en dur dans le code
- Utilisation de `${FIREBASE_API_KEY:default}`
- Fichiers .gitignore appropriés

### Restrictions Firebase
1. Console Firebase > Paramètres du projet
2. Onglet "Restrictions de l'API"
3. Limitez les domaines autorisés :
   - `localhost:8080`
   - Votre domaine de production

### Rotation des clés
- Changez régulièrement vos clés API
- Surveillez l'utilisation dans Firebase Console
- Désactivez les clés compromises immédiatement

## 📁 **Fichiers à ajouter au .gitignore**

```gitignore
# Configuration Firebase locale
firebase-config.sh
.env
.env.local
firebase-service-account-prod.json

# Logs sensibles
*.log
```

## 🔍 **Vérification de sécurité**

Avant chaque commit, vérifiez :

```bash
# Rechercher des clés API dans le code
grep -r "AIzaSy" . --exclude-dir=.git
grep -r "firebase.*key" . --exclude-dir=.git

# Vérifier le status git
git status
git diff --cached
```

## 🚨 **En cas de fuite de clé**

1. **Immédiatement :**
   - Désactivez la clé dans Firebase Console
   - Générez une nouvelle clé API

2. **Nettoyage :**
   - Supprimez la clé de l'historique Git si nécessaire
   - Notifiez l'équipe

3. **Prévention :**
   - Activez les restrictions d'API
   - Surveillez les logs d'utilisation

## ✅ **Configuration actuelle sécurisée**

Le projet est configuré pour :
- ✅ Utiliser des variables d'environnement
- ✅ Avoir des valeurs par défaut sécurisées
- ✅ Instructions claires pour la configuration
- ✅ Pas de clés sensibles dans le repository

---

**🔒 La sécurité est notre priorité ! Suivez toujours ces pratiques.**
