# 🚨 SOLUTION URGENTE : ERR_TOO_MANY_REDIRECTS

## 🎯 Problème
`ERR_TOO_MANY_REDIRECTS` - Boucle de redirection infinie

## ⚡ SOLUTIONS IMMÉDIATES

### 1. **SUPPRIMER LES COOKIES (SOLUTION RAPIDE)**

**Chrome :**
1. Appuyez sur `Ctrl + Shift + Delete`
2. Sélectionnez "Cookies et autres données de sites"
3. Cliquez sur "Effacer les données"

**Firefox :**
1. Appuyez sur `Ctrl + Shift + Delete`
2. Cochez "Cookies"
3. Cliquez sur "Effacer maintenant"

**Edge :**
1. Appuyez sur `Ctrl + Shift + Delete`
2. Sélectionnez "Cookies et données de sites web"
3. Cliquez sur "Effacer maintenant"

### 2. **UTILISER LA NAVIGATION PRIVÉE**

- **Chrome** : `Ctrl + Shift + N`
- **Firefox** : `Ctrl + Shift + P`
- **Edge** : `Ctrl + Shift + P`

Puis aller sur : http://localhost:8080/login

### 3. **REDÉMARRER L'APPLICATION**

```bash
# 1. Arrêter l'application (Ctrl+C dans le terminal)
# 2. Redémarrer
scripts/start-beetrck.bat
```

### 4. **ENDPOINTS DE DÉBOGAGE (Après redémarrage)**

Une fois l'application redémarrée, ces URLs évitent les redirections :

- **Debug** : http://localhost:8080/debug
- **Login sécurisé** : http://localhost:8080/safe-login
- **Dashboard simple** : http://localhost:8080/simple-dashboard

## 🔧 CAUSES PROBABLES

1. **Cookies corrompus** ❌
2. **Session Spring Security bloquée** ❌
3. **Exception dans le dashboard** qui créé une boucle ❌
4. **Firebase non initialisé** qui génère des erreurs ❌

## 📋 PROCÉDURE RECOMMANDÉE

### Étape 1 : Nettoyage immédiat
```bash
1. Supprimer les cookies du navigateur
2. Fermer tous les onglets de l'application
3. Utiliser la navigation privée
```

### Étape 2 : Redémarrage de l'application
```bash
# Dans le terminal de l'application
Ctrl + C

# Puis redémarrer
scripts/start-beetrck.bat
```

### Étape 3 : Connexion sécurisée
```bash
# Ouvrir en navigation privée
http://localhost:8080/safe-login

# Utiliser les identifiants
Email: admin@beetrackdemo.com
Mot de passe: admin123
```

## ✅ VÉRIFICATION

Après avoir appliqué les solutions :

1. ✅ Plus d'erreur de redirection
2. ✅ Page de login accessible
3. ✅ Connexion réussie
4. ✅ Dashboard accessible

## 🛠️ SCRIPT AUTOMATIQUE

```bash
scripts/fix-redirect-loop.bat
```

Ce script :
- Vérifie l'application
- Ouvre les pages de solution
- Guide vers les solutions

## 🎯 RÉSOLUTION IMMÉDIATE

**LA PLUS RAPIDE :**
1. Navigation privée (`Ctrl + Shift + N`)
2. Aller sur : http://localhost:8080/login
3. Se connecter avec : `admin@beetrackdemo.com` / `admin123`

---

**Problème de redirection résolu !** 🎉 