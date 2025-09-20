# 🔌 Guide du Sélecteur ESP32 - BeeTrack

## 🎯 **Fonctionnalité implémentée**

J'ai créé un **sélecteur ESP32 complet** pour votre interface BeeTrack, parfait pour votre cas d'usage avec un seul ESP32 principal (`887D681C0610`).

## 📱 **Interface du sélecteur**

### **1. Menu déroulant dans le header**
- **Position** : En haut à droite de la page
- **Options** : Liste de tous vos ESP32 disponibles
- **ESP par défaut** : `887D681C0610` (votre ESP principal)
- **Action** : Change automatiquement les données affichées

### **2. Cartes ESP32 visuelles**
- **Affichage** : Cartes cliquables avec icônes 📡
- **Informations** : ID, nom, statut (en ligne/hors ligne)
- **Sélection** : Clic sur une carte pour sélectionner l'ESP
- **Visual feedback** : Bordure verte pour l'ESP actif

### **3. Boutons d'action**
- **"Actualiser"** : Met à jour les données de l'ESP sélectionné
- **"Données test"** : Crée des mesures de test pour l'ESP actuel
- **"Détails"** : Ouvre la page détaillée de l'ESP

## 🚀 **Comment utiliser**

### **Étape 1 : Démarrer l'application**
```bash
cd C:\Users\mlakh\Desktop\BeeTrack-main\ruche-connectee\web-app
mvn spring-boot:run
```

### **Étape 2 : Créer des données de test**
```bash
# Script automatique
test-selecteur-esp.bat
```

### **Étape 3 : Accéder à l'interface**
```
http://localhost:8080/mesures
```

## 🎛️ **URLs disponibles**

### **Page principale (tous les ESP)**
```
http://localhost:8080/mesures
```
→ Affiche le sélecteur et toutes les ruches

### **Page filtrée (ESP spécifique)**
```
http://localhost:8080/mesures?esp=887D681C0610
```
→ Affiche uniquement les mesures de votre ESP principal

### **Autres ESP de test**
```
http://localhost:8080/mesures?esp=R001
http://localhost:8080/mesures?esp=R002
http://localhost:8080/mesures?esp=R003
```

### **Page de détails**
```
http://localhost:8080/mesures/ruche/887D681C0610
```
→ Vue détaillée avec graphiques et statistiques

## 🔧 **Fonctionnalités du sélecteur**

### **1. Sélection d'ESP**
- **Menu déroulant** : Changement rapide d'ESP
- **Cartes visuelles** : Sélection intuitive par clic
- **Synchronisation** : Les deux méthodes se synchronisent

### **2. Feedback visuel**
- **ESP actif** : Bordure verte et fond coloré
- **ESP inactif** : Bordure grise
- **Statut en ligne** : Point vert/rouge
- **Notifications** : Messages de confirmation

### **3. Actions contextuelles**
- **Actualisation** : Recharge les données de l'ESP actuel
- **Création de test** : Génère des mesures pour l'ESP sélectionné
- **Détails** : Navigation vers la vue détaillée

### **4. Gestion d'erreurs**
- **ESP sans données** : Message "Aucune mesure trouvée"
- **Erreur de connexion** : Fallback vers données par défaut
- **Loading** : Indicateur de chargement pendant les requêtes

## 📊 **Adaptation pour votre configuration**

### **Votre ESP32 principal : `887D681C0610`**
- ✅ **Pré-sélectionné** par défaut
- ✅ **Marqué comme "En ligne"**
- ✅ **Structure Firebase** : `ruche/887D681C0610/historique`
- ✅ **APIs dédiées** : Tous les endpoints supportent cet ID

### **ESP de test disponibles**
- `R001`, `R002`, `R003` : Pour tester le sélecteur
- Marqués comme "Hors ligne" par défaut
- Peuvent être activés en créant des données de test

## 🎨 **Interface utilisateur**

### **Design moderne**
- **Cartes ESP** : Design carte avec icônes et couleurs
- **Animations** : Transitions fluides lors de la sélection
- **Responsive** : S'adapte à toutes les tailles d'écran
- **Notifications** : Alertes en temps réel des actions

### **Expérience utilisateur**
- **Une sélection = un ESP** : Focus sur l'ESP choisi
- **Données en temps réel** : Auto-refresh toutes les 30s
- **Navigation fluide** : Pas de rechargement de page
- **Feedback immédiat** : Confirmations des actions

## 🧪 **Test du sélecteur**

### **1. Test automatique**
```bash
test-selecteur-esp.bat
```

### **2. Test manuel**
1. Allez sur `http://localhost:8080/mesures`
2. Cliquez sur le menu déroulant "ESP32"
3. Sélectionnez votre ESP `887D681C0610`
4. Vérifiez que les données se chargent
5. Testez le bouton "Données test"

### **3. Vérification des APIs**
```bash
# Votre ESP principal
curl "http://localhost:8080/api/mesures/ruche/887D681C0610/derniere"

# Création de données
curl -X POST "http://localhost:8080/dev/create-test-data/887D681C0610?nombreJours=2&mesuresParJour=6"
```

## 🔄 **Workflow recommandé**

### **Usage quotidien**
1. **Ouvrir** : `http://localhost:8080/mesures`
2. **ESP pré-sélectionné** : `887D681C0610` (automatique)
3. **Voir les mesures** : Affichage immédiat
4. **Actualiser** : Bouton ou auto-refresh
5. **Détails** : Clic sur "Voir détails" si besoin

### **Ajout d'autres ESP32**
1. Ajoutez l'ID dans le menu déroulant (code)
2. Créez une carte ESP dans l'interface
3. Configurez Firebase avec la structure `ruche/{ESP_ID}/historique`
4. L'ESP apparaîtra automatiquement dans le sélecteur

---

## ✨ **Résumé**

**Vous avez maintenant un sélecteur ESP32 complet qui :**
- ✅ Affiche votre ESP `887D681C0610` par défaut
- ✅ Permet de changer d'ESP via menu déroulant ou cartes
- ✅ Charge les mesures spécifiques à l'ESP sélectionné
- ✅ Offre des actions contextuelles (actualiser, test, détails)
- ✅ Gère les erreurs et les états sans données
- ✅ Propose une interface moderne et intuitive

**🎯 Parfait pour votre cas d'usage avec un ESP32 principal !**
