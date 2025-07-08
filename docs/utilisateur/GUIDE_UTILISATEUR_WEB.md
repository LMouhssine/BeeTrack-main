# 📖 Guide utilisateur - Interface web BeeTrack

Guide complet d'utilisation de l'interface web BeeTrack pour la gestion des ruches connectées.

## 🚀 Accès à l'application

### URL de connexion
Une fois l'application démarrée, accédez à : **http://localhost:8080**

### Première connexion
1. Ouvrez votre navigateur web
2. Rendez-vous sur `http://localhost:8080`
3. Vous serez automatiquement redirigé vers le dashboard

## 🏠 Dashboard principal

### Vue d'ensemble
Le dashboard offre une vue synthétique de votre exploitation apicole :

#### Métriques clés
- **Total ruchers** : Nombre total de ruchers actifs
- **Total ruches** : Nombre total de ruches surveillées
- **Ruches actives** : Ruches en fonctionnement normal
- **Alertes actives** : Nombre d'alertes nécessitant une attention

#### Graphiques temps réel
- **Température moyenne** : Évolution sur les dernières 24h
- **Humidité moyenne** : Tendance générale des ruches
- **Activité récente** : Actions et événements importants

#### Actions rapides
- **Ajouter une ruche** : Bouton d'accès direct
- **Voir les statistiques** : Accès aux analyses détaillées
- **Gestion des alertes** : Vue des notifications

## 🏭 Gestion des ruchers

### Accéder aux ruchers
- Cliquez sur **"Ruchers"** dans le menu de navigation
- Ou utilisez l'URL : `http://localhost:8080/ruchers`

### Interface ruchers

#### Vue grille
- **Cartes ruchers** : Affichage visuel avec informations clés
- **Nom du rucher** : Identifiant principal
- **Adresse** : Localisation géographique
- **Nombre de ruches** : Compteur automatique
- **Statut** : Actif/Inactif avec indicateur visuel

#### Fonctionnalités disponibles

##### Recherche et filtres
```
┌─────────────────────────────────────┐
│ 🔍 Rechercher un rucher...          │
├─────────────────────────────────────┤
│ 📊 Tous les ruchers (12)           │
│ ✅ Actifs (10)                      │
│ ❌ Inactifs (2)                     │
└─────────────────────────────────────┘
```

##### Ajouter un rucher
1. Cliquez sur le bouton **"+ Ajouter un rucher"**
2. Remplissez le formulaire modal :
   - **Nom** : Nom du rucher (obligatoire)
   - **Adresse** : Localisation complète
   - **Superficie** : Surface en hectares
   - **Description** : Informations complémentaires
3. Cliquez sur **"Créer le rucher"**

##### Modifier un rucher
1. Cliquez sur l'icône **"✏️ Modifier"** sur la carte du rucher
2. Modifiez les informations dans le formulaire
3. Sauvegardez avec **"Mettre à jour"**

##### Supprimer un rucher
1. Cliquez sur l'icône **"🗑️ Supprimer"**
2. Confirmez la suppression dans la boîte de dialogue
3. ⚠️ **Attention** : Cette action supprime aussi toutes les ruches associées

## 🐝 Gestion des ruches

### Accéder aux ruches
- Cliquez sur **"Ruches"** dans le menu de navigation
- Ou utilisez l'URL : `http://localhost:8080/ruches`

### Interface ruches

#### Modes d'affichage
- **Vue grille** : Cartes visuelles avec photos
- **Vue liste** : Tableau détaillé avec tri et filtres

#### Informations par ruche
- **Nom de la ruche** : Identifiant unique
- **Rucher associé** : Localisation
- **État de santé** : Indicateur visuel (🟢 Bon, 🟡 Attention, 🔴 Critique)
- **Température actuelle** : Dernière mesure
- **Humidité actuelle** : Dernière mesure
- **Niveau batterie** : État de la sonde
- **Dernière mesure** : Horodatage

#### Filtres avancés
```
┌─────────────────────────────────────┐
│ 🔍 Rechercher...                    │
├─────────────────────────────────────┤
│ 📍 Tous les ruchers                 │
│ 📊 Tous les statuts                 │
│ 🔋 Tous niveaux batterie           │
└─────────────────────────────────────┘
```

#### Actions sur les ruches

##### Ajouter une ruche
1. Bouton **"+ Ajouter une ruche"**
2. Formulaire de création :
   - **Nom** : Identifiant de la ruche
   - **Rucher** : Sélection dans la liste
   - **Type** : Dadant, Langstroth, etc.
   - **Numéro de série** : ID capteur IoT
3. **"Créer la ruche"** pour valider

##### Voir les détails d'une ruche
1. Cliquez sur **"👁️ Voir détails"**
2. Accès à la page complète de la ruche

## 📊 Détails d'une ruche

### Accès
- Depuis la liste des ruches : bouton **"Voir détails"**
- URL directe : `http://localhost:8080/ruche/{id}`

### Interface détaillée

#### Métriques temps réel
```
┌─────────────────┬─────────────────┬─────────────────┐
│ 🌡️ Température  │ 💧 Humidité     │ ⚖️ Poids        │
│ 24.5°C          │ 65%             │ 45.2 kg        │
│ ↗️ +1.2°C        │ ↘️ -3%           │ ↗️ +0.8 kg      │
└─────────────────┴─────────────────┴─────────────────┘
```

#### Graphiques historiques
- **Température** : Évolution sur 7/30 jours
- **Humidité** : Tendances et variations
- **Poids** : Gain/perte de miel
- **Activité** : Niveau d'activité des abeilles

#### Alertes actives
- **🚨 Couvercle ouvert** : Détection automatique
- **🌡️ Température anormale** : Hors seuils configurés
- **💧 Humidité critique** : Risque de moisissure
- **🔋 Batterie faible** : Capteur à remplacer

#### Actions de maintenance
- **🔄 Calibrer capteurs** : Réinitialisation
- **🔁 Redémarrer capteurs** : Reboot à distance
- **📝 Ajouter note** : Journal de maintenance
- **⚠️ Marquer pour visite** : Planification

## 📈 Statistiques et analyses

### Accéder aux statistiques
- Menu **"Statistiques"**
- URL : `http://localhost:8080/statistiques`

### Sections disponibles

#### Vue d'ensemble
- **Production totale estimée** : Calcul basé sur le poids
- **Ruches les plus productives** : Top 5
- **Alertes du mois** : Tendances
- **Performance globale** : Score santé

#### Analyses par rucher
- **Production par rucher** : Comparaison
- **Efficacité** : Ratio production/ruche
- **Problèmes récurrents** : Identification

#### Graphiques avancés
- **Production mensuelle** : Évolution saisonnière
- **Corrélations météo** : Impact sur la production
- **Prédictions** : Estimation fin de saison

#### Recommandations automatiques
- **Actions suggérées** : Basées sur les données
- **Planification** : Calendrier des interventions
- **Optimisation** : Conseils d'amélioration

## 🚨 Système d'alertes

### Types d'alertes

#### Alertes critiques (🔴)
- **Couvercle ouvert** > 30 minutes
- **Température** < 10°C ou > 40°C
- **Humidité** < 20% ou > 85%
- **Batterie critique** < 10%

#### Alertes d'attention (🟡)
- **Variation température** > 5°C en 1h
- **Humidité élevée** 70-85%
- **Batterie faible** 10-30%
- **Inactivité capteur** > 2h

#### Informations (🔵)
- **Nouvelle mesure** reçue
- **Maintenance** programmée
- **Mise à jour** système

### Actions sur les alertes
- **👁️ Voir détails** : Information complète
- **✅ Marquer résolue** : Fermeture manuelle
- **⏰ Reporter** : Rappel plus tard
- **🔕 Ignorer** : Désactivation temporaire

## 🔧 Configuration et préférences

### Accès aux paramètres
- Icône **"⚙️"** en haut à droite
- Section utilisateur

### Paramètres disponibles
- **Seuils d'alerte** : Personnalisation par type
- **Notifications** : Fréquence et types
- **Affichage** : Préférences interface
- **Unités** : Celsius/Fahrenheit, kg/lbs

## 📱 Navigation et raccourcis

### Menu principal
```
🏠 Dashboard      - Vue d'ensemble
🏭 Ruchers        - Gestion des emplacements  
🐝 Ruches         - Surveillance des ruches
📊 Statistiques   - Analyses et rapports
🔧 Test Firebase  - Diagnostic technique
```

### Raccourcis clavier
- **Ctrl + D** : Retour au dashboard
- **Ctrl + R** : Actualiser les données
- **Ctrl + F** : Recherche rapide
- **Echap** : Fermer les modals

### Navigation mobile
- **Interface responsive** : Adaptation automatique
- **Menu hamburger** : Navigation tactile
- **Gestes tactiles** : Swipe et tap optimisés

## 🆘 Dépannage utilisateur

### Problèmes courants

#### Page ne se charge pas
1. Vérifiez l'URL : `http://localhost:8080`
2. Vérifiez que l'application est démarrée
3. Actualisez la page (F5)

#### Données non mises à jour
1. Actualisez la page
2. Vérifiez la connexion Firebase
3. Consultez le test : `http://localhost:8080/test`

#### Erreurs d'affichage
1. Videz le cache navigateur (Ctrl + F5)
2. Vérifiez la version du navigateur
3. Désactivez les bloqueurs de pub

### Support technique
- **Test Firebase** : `http://localhost:8080/test`
- **Santé application** : `http://localhost:8080/actuator/health`
- **Documentation** : Consultez `/docs`

---

<div align="center">

**Guide utilisateur BeeTrack**  
*Interface web Spring Boot + Thymeleaf*

*Gérez vos ruches connectées en toute simplicité*

</div> 