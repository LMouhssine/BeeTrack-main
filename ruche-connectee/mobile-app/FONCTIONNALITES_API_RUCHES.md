# 🐝 Nouvelles Fonctionnalités API Ruches

## Vue d'ensemble

Ce document présente l'implémentation de deux nouvelles fonctionnalités dans l'application Flutter BeeTrack :

1. **Récupération des ruches d'un rucher** - triées par nom croissant
2. **Récupération des mesures des 7 derniers jours d'une ruche** - avec visualisation graphique

## 📋 Fonctionnalités Implémentées

### 1. Récupération des Ruches par Rucher

**Description :** Permet de récupérer toutes les ruches associées à un rucher spécifique, automatiquement triées par nom croissant.

**API Endpoint :** `GET /api/mobile/ruches/rucher/{rucherId}`

**Fonctionnalités :**
- ✅ Récupération sécurisée avec authentification Firebase
- ✅ Tri automatique par nom (insensible à la casse)
- ✅ Validation de l'appartenance du rucher à l'utilisateur
- ✅ Gestion d'erreurs complète
- ✅ Interface utilisateur dédiée avec recherche et filtres

### 2. Récupération des Mesures des 7 Derniers Jours

**Description :** Récupère l'historique des mesures de capteurs (température, humidité, batterie) des 7 derniers jours pour une ruche donnée.

**API Endpoint :** `GET /api/mobile/ruches/{rucheId}/mesures-7-jours`

**Fonctionnalités :**
- ✅ Données triées par timestamp croissant
- ✅ Graphiques interactifs (température et humidité)
- ✅ Statistiques automatiques (min, max, moyenne)
- ✅ Liste des mesures récentes
- ✅ Gestion des cas sans données

## 🏗️ Architecture Technique

### Structure des Fichiers

```
lib/
├── models/
│   └── api_models.dart              # Modèles : RucheResponse, DonneesCapteur
├── services/
│   ├── api_client_service.dart      # Client HTTP avec authentification
│   └── api_ruche_service.dart       # Service API ruches + RucheApiException
├── config/
│   └── api_config.dart              # Configuration endpoints API
└── screens/
    ├── ruches/
    │   ├── ruches_by_rucher_screen.dart    # Liste des ruches d'un rucher
    │   └── ruche_detail_api_screen.dart    # Détails avec mesures et graphiques
    └── test_ruches_api_screen.dart         # Écran de test des fonctionnalités
```

### Modèles de Données

#### RucheResponse
```dart
class RucheResponse {
  final String id;
  final String idRucher;
  final String nom;
  final String position;
  final String? typeRuche;
  final String? description;
  final bool enService;
  final DateTime? dateInstallation;
  final DateTime dateCreation;
  final bool actif;
  final String idApiculteur;
  final String? rucherNom;
  // ...
}
```

#### DonneesCapteur
```dart
class DonneesCapteur {
  final String id;
  final String rucheId;
  final DateTime timestamp;
  final double? temperature;
  final double? humidity;
  final bool? couvercleOuvert;
  final int? batterie;
  final int? signalQualite;
  final String? erreur;
}
```

### Services

#### ApiRucheService

Service principal pour les opérations sur les ruches :

```dart
class ApiRucheService {
  // Récupère les ruches d'un rucher (triées par nom)
  Future<List<RucheResponse>> obtenirRuchesParRucher(String idRucher);
  
  // Récupère les mesures des 7 derniers jours
  Future<List<DonneesCapteur>> obtenirMesures7DerniersJours(String idRuche);
  
  // Autres méthodes : obtenirRucheParId, supprimerRuche, etc.
}
```

### Gestion d'Erreurs

**RucheApiException** : Exception personnalisée pour les erreurs API avec codes de statut HTTP.

```dart
class RucheApiException implements Exception {
  final String message;
  final int statusCode;
  final String? code;
}
```

Gestion des codes d'erreur :
- **403** : Accès refusé au rucher/ruche
- **404** : Rucher/ruche non trouvé(e)
- **500** : Erreur serveur

## 🎨 Interface Utilisateur

### 1. RuchesByRucherScreen

**Fonctionnalités UI :**
- 📊 Carte de statistiques (total, en service, hors service)
- 🔍 Barre de recherche (nom et position)
- 📝 Liste des ruches avec informations détaillées
- 🔄 Actualisation pull-to-refresh
- ➡️ Navigation vers les détails de chaque ruche

### 2. RucheDetailApiScreen

**Fonctionnalités UI :**
- ℹ️ Informations générales de la ruche
- 📈 Graphique d'évolution de la température
- 💧 Graphique d'évolution de l'humidité
- 📊 Statistiques des 7 derniers jours
- 📋 Liste des mesures récentes
- 🔄 Actualisation des données

### 3. TestRuchesApiScreen

**Écran de test et démonstration :**
- 🧪 Interface de test pour les deux fonctionnalités
- 📝 Champs de saisie pour IDs de test
- 📊 Affichage des résultats
- ➡️ Navigation vers les écrans complets

## 🚀 Utilisation

### Test des Fonctionnalités

1. **Lancer l'application Flutter**
2. **Naviguer vers TestRuchesApiScreen**
3. **Tester la récupération des ruches :**
   - Saisir un ID de rucher (ex: `test-rucher-001`)
   - Cliquer sur "Tester Ruches par Rucher"
4. **Tester les mesures :**
   - Saisir un ID de ruche (ex: `test-ruche-001`)
   - Cliquer sur "Tester Mesures 7 Jours"

### Navigation vers les Écrans Complets

Les boutons "Voir détails complets" et "Voir graphiques complets" permettent d'accéder aux interfaces complètes avec toutes les fonctionnalités.

## 🛡️ Sécurité

### Authentification
- 🔐 Authentification Firebase requise
- 🔑 Token JWT dans les headers
- 👤 Validation de l'ID apiculteur

### Contrôles d'Accès
- ✅ Vérification de propriété des ruchers
- ✅ Validation des permissions sur les ruches
- ✅ Isolation des données par utilisateur

## 📦 Dépendances

### Nouvelles Dépendances
- `fl_chart: ^0.63.0` - Graphiques interactifs
- `dio: ^5.3.2` - Client HTTP (déjà présent)

### Dépendances Existantes Utilisées
- `firebase_auth` - Authentification
- `firebase_core` - Configuration Firebase
- `flutter_bloc` - Gestion d'état
- `get_it` - Injection de dépendances

## 🔧 Configuration

### API Configuration
```dart
// lib/config/api_config.dart
static const String baseUrl = 'http://localhost:8080';
static const String apiPrefix = '/api/mobile';
static String ruchesByRucherUrl(String rucherId) => '$fullRuchesUrl/rucher/$rucherId';
static String mesures7JoursUrl(String rucheId) => '$fullRuchesUrl/$rucheId/mesures-7-jours';
```

### Headers d'Authentification
```dart
'Authorization': 'Bearer $firebaseToken'
'X-Apiculteur-ID': '$userId'
'Content-Type': 'application/json'
```

## 📊 Fonctionnalités des Graphiques

### Graphique de Température
- 📈 Courbe lisse avec données filtrées
- 🎨 Couleur orange thématique
- 📅 Axe X : dates (jour/mois)
- 🌡️ Axe Y : température en °C

### Graphique d'Humidité
- 💧 Courbe bleue pour l'humidité
- 📊 Échelle en pourcentage
- 📍 Points de données sans affichage (ligne lisse)

### Statistiques Calculées
- 📉 **Minimum** : valeur la plus basse
- 📈 **Maximum** : valeur la plus haute  
- ⚖️ **Moyenne** : calculée automatiquement
- 🎯 Précision : 1 décimale

## 🐛 Gestion d'Erreurs

### Types d'Erreurs Gérées
1. **Erreurs Réseau** : Timeout, connexion perdue
2. **Erreurs d'Authentification** : Token expiré, non connecté
3. **Erreurs d'Autorisation** : Accès refusé, ruche non autorisée
4. **Erreurs de Données** : Ruche/rucher non trouvé, données corrompues

### Interface Utilisateur d'Erreur
- 🚨 Messages d'erreur contextuels
- 🔄 Boutons de réessai
- 📱 Snackbars pour les notifications
- 🎨 Interface cohérente avec le design system

## 🔄 États de Chargement

### Indicateurs Visuels
- ⏳ Indicateurs de progression circulaires
- 🔄 États de chargement différenciés
- 📊 Shimmer effects pour les listes
- 🎯 Désactivation des boutons pendant le chargement

## 📱 Responsive Design

### Adaptabilité
- 📱 Interface optimisée mobile-first
- 🔄 Orientation portrait/paysage
- 📏 Grilles flexibles pour les statistiques
- 🎨 Marges et espacements adaptatifs

## 🚀 Performances

### Optimisations
- 📊 Tri côté client en backup du serveur
- 🎯 Requêtes asynchrones parallèles
- 📦 Gestion mémoire des listes longues
- 🔄 Cache intelligent des données

---

## 📞 Support

Pour toute question ou problème concernant ces fonctionnalités, se référer à :
- 📚 Documentation technique dans le code
- 🐛 Logs détaillés via LoggerService  
- 🧪 Écran de test pour diagnostics
- 📊 Métriques d'erreurs API

**Développé avec 💚 pour BeeTrack - Surveillance intelligente de ruches connectées** 🐝 