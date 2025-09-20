# 📊 Guide - Où voir les mesures dans l'interface BeeTrack

## 🎯 **Emplacements des mesures**

### 1. **Dashboard principal**
- **URL** : `http://localhost:8080/dashboard`
- **Accès** : Menu "Tableau de bord" dans la sidebar
- **Contenu** : 
  - Statistiques globales (température moyenne, ruches actives)
  - Vue d'ensemble des ruches avec leurs dernières mesures
  - KPIs temps réel

### 2. **Page Mesures IoT** ⭐ **NOUVEAU**
- **URL** : `http://localhost:8080/mesures`
- **Accès** : Menu "Mesures IoT" dans la sidebar
- **Contenu** :
  - État de toutes vos ruches
  - Dernières mesures de chaque capteur
  - Température, humidité, état du couvercle, batterie
  - Liens vers les détails de chaque ruche

### 3. **Détails d'une ruche** ⭐ **NOUVEAU**
- **URL** : `http://localhost:8080/mesures/ruche/{ID_RUCHE}`
- **Accès** : Bouton "Voir détails" sur une ruche
- **Contenu** :
  - État actuel détaillé
  - Statistiques sur 7 jours
  - Historique des mesures récentes
  - Graphiques (à venir)

## 🚀 **Comment démarrer**

### 1. **Lancer l'application**
```bash
cd ruche-connectee/web-app
start-with-test-data.bat
```

### 2. **Créer des données de test**
Une fois l'application démarrée, créez des données de test pour votre ruche :

```bash
# Via PowerShell ou Command Prompt
curl -X POST "http://localhost:8080/dev/create-test-data/887D681C0610?nombreJours=3&mesuresParJour=6"
```

### 3. **Accéder à l'interface**
- Ouvrez votre navigateur : `http://localhost:8080`
- Connectez-vous (si nécessaire)
- Cliquez sur "Mesures IoT" dans le menu

## 📱 **Structure des données**

Vos mesures de la ruche `887D681C0610` sont stockées selon cette structure Firebase :
```
ruche/887D681C0610/historique/
├── mesureId1/
│   ├── date: "2025-08-29"
│   ├── heure: "14:51:46"
│   ├── temperature: 28.8
│   ├── humidity: 56.6
│   └── couvercle: "OUVERT"
```

## 🔧 **APIs disponibles**

### Tester les APIs directement :

```bash
# Dernière mesure
curl "http://localhost:8080/api/mesures/ruche/887D681C0610/derniere"

# Mesures récentes (24h)
curl "http://localhost:8080/api/mesures/ruche/887D681C0610/recentes?heures=24"

# Statistiques (7 jours)
curl "http://localhost:8080/api/mesures/ruche/887D681C0610/statistiques?jours=7"

# API mobile
curl -H "X-Apiculteur-ID: test-user" "http://localhost:8080/api/mobile/ruches/887D681C0610/derniere-mesure"
```

## 🎨 **Interface utilisateur**

### Dashboard
✅ Affiche la température moyenne de toutes les ruches
✅ Nombre de ruches actives
✅ Liste des ruches avec leurs dernières mesures

### Page Mesures IoT
✅ Vue d'ensemble de toutes les ruches
✅ État en temps réel (température, humidité, couvercle, batterie)
✅ Indication visuelle des ruches actives/inactives
✅ Auto-refresh toutes les 30 secondes

### Détails d'une ruche
✅ État actuel avec grandes cartes visuelles
✅ Statistiques détaillées (min, max, moyenne)
✅ Tableau des mesures récentes
✅ Alertes visuelles (couvercle ouvert)

## ⚠️ **Résolution de problèmes**

### Si vous ne voyez pas de mesures :

1. **Vérifiez la connexion Firebase**
   ```bash
   curl "http://localhost:8080/dev/test-firebase-structure/887D681C0610"
   ```

2. **Créez des données de test**
   ```bash
   curl -X POST "http://localhost:8080/dev/create-test-data/887D681C0610?nombreJours=1&mesuresParJour=4"
   ```

3. **Vérifiez l'API**
   ```bash
   curl "http://localhost:8080/api/mesures/ruche/887D681C0610/derniere"
   ```

4. **Vérifiez les logs**
   - Regardez la console de l'application Spring Boot
   - Les erreurs Firebase y seront affichées

### Si l'interface ne charge pas :
- Vérifiez que l'application est démarrée sur le port 8080
- Essayez de rafraîchir la page
- Consultez la console du navigateur (F12)

## 🔄 **Actualisation des données**

- **Automatique** : La page se rafraîchit toutes les 30 secondes
- **Manuel** : Bouton "Actualiser" en haut de chaque page
- **Temps réel** : Les nouvelles mesures apparaissent immédiatement

## 📊 **Prochaines fonctionnalités**

🔲 Graphiques interactifs (Chart.js)
🔲 Export des données (CSV, Excel)
🔲 Alertes en temps réel
🔲 Notifications push
🔲 Comparaison entre ruches

---

**✨ Votre interface est maintenant prête à afficher les mesures de vos capteurs IoT !**
