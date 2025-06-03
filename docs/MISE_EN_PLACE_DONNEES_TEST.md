# Mise en place des données de test - BeeTrack

## 🎯 Objectif

Résoudre l'erreur HTTP 401 dans l'onglet "Mesures" en créant des données de test pour visualiser les graphiques et tableaux.

## 🛠️ Solutions implémentées

### 1. Endpoint Spring Boot principal (avec authentification)
- **URL**: `POST /api/test/ruche/{rucheId}/creer-donnees-test`
- **Authentification**: Requise (Firebase JWT + X-Apiculteur-ID)
- **Utilisation**: Via le bouton "🧪 Créer des données de test"

### 2. Endpoint de développement (sans authentification)
- **URL**: `POST /dev/create-test-data/{rucheId}`
- **Authentification**: Aucune
- **Utilisation**: Fallback automatique si l'endpoint principal échoue

### 3. Création directe Firestore (frontend)
- **Méthode**: `TestDataService.creerDonneesTestFirestore()`
- **Authentification**: Firebase Auth (automatique)
- **Utilisation**: Via le bouton "🔥 Créer via Firestore"

## 🚀 Comment utiliser

### Méthode recommandée (automatique)
1. Aller dans l'onglet "Mesures" d'une ruche
2. Cliquer sur "🧪 Créer des données de test"
3. Le système essaiera automatiquement les 3 méthodes dans l'ordre

### Méthode directe Firestore
1. Aller dans l'onglet "Mesures" d'une ruche
2. Cliquer sur "🔥 Créer via Firestore"
3. Les données sont créées directement dans Firestore

## 📊 Données générées

### Paramètres par défaut
- **Période**: 10 derniers jours
- **Fréquence**: 8 mesures par jour
- **Total**: ~80 mesures

### Types de données
- **Température**: 10°C à 20°C (variations réalistes)
- **Humidité**: 30% à 60% (variations réalistes)
- **Batterie**: Déclin progressif de 100% à ~60%
- **Couvercle**: 5% de chance d'être ouvert
- **Signal**: 70% à 100%

## 🔧 Diagnostic des problèmes

### Composant DiagnosticApi
Le composant `DiagnosticApi` teste automatiquement :
- ✅ Connectivité endpoint de développement (`/dev/health`)
- ✅ Connectivité endpoint principal (`/api/test/health`)
- ✅ Création de données de test

### Messages d'erreur courants

#### Erreur 401 - Non autorisé
- **Cause**: Configuration Spring Security
- **Solution**: Utiliser l'endpoint `/dev/` ou la création Firestore

#### Erreur de connexion
- **Cause**: API Spring Boot non démarrée
- **Solution**: Démarrer l'API avec `./mvnw spring-boot:run`

#### Erreur Firestore
- **Cause**: Configuration Firebase incorrecte
- **Solution**: Vérifier `firebase-config.ts` et les credentials

## 📁 Fichiers modifiés

### Backend Spring Boot
- `SecurityConfig.java` - Désactivation sécurité en dev
- `DevDataController.java` - Endpoint sans authentification
- `TestController.java` - Endpoint avec authentification

### Frontend React
- `api-config.ts` - Configuration endpoints
- `rucheService.ts` - Méthodes API
- `testDataService.ts` - Création directe Firestore
- `MesuresRuche.tsx` - Interface utilisateur
- `DiagnosticApi.tsx` - Diagnostic automatique

## 🎯 Résultat attendu

Après création des données de test :
- ✅ Graphiques de température et humidité
- ✅ Graphique de batterie
- ✅ Statistiques (min/max/moyenne)
- ✅ Tableau des dernières mesures
- ✅ Contrôles d'affichage fonctionnels

## 🔄 Prochaines étapes

1. **Tester** la création de données via l'interface
2. **Vérifier** l'affichage des graphiques
3. **Valider** les statistiques calculées
4. **Optimiser** les performances si nécessaire

## 🐛 Dépannage

### Si aucune méthode ne fonctionne
1. Vérifier la console du navigateur pour les erreurs
2. Vérifier que Firebase est configuré correctement
3. Vérifier que l'utilisateur est connecté à Firebase
4. Redémarrer l'API Spring Boot

### Si les données n'apparaissent pas
1. Vérifier la console pour les logs de création
2. Vérifier Firestore dans la console Firebase
3. Actualiser la page
4. Vérifier que `rucheId` est correct 