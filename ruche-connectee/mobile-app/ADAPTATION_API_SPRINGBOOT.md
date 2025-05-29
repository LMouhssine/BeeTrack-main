# Adaptation Flutter pour API Spring Boot 🚀

## Vue d'ensemble

Ce document décrit l'adaptation de l'application mobile Flutter pour utiliser l'API Spring Boot au lieu d'accéder directement à Firebase Firestore. Cette approche créé une architecture unifiée entre les applications web et mobile.

## Architecture mise à jour

```
Flutter Mobile App
      ↓ HTTP/REST
API Spring Boot 
      ↓ Firebase Admin SDK
Firebase Firestore
```

### Avantages de cette architecture

✅ **Uniformité** : Web et mobile utilisent la même API  
✅ **Sécurité** : Validation centralisée côté serveur  
✅ **Maintenance** : Logique métier centralisée  
✅ **Performance** : Mise en cache possible côté API  
✅ **Évolutivité** : Ajout facile de nouvelles fonctionnalités  

## Fichiers créés/modifiés

### 🆕 Nouveaux fichiers

1. **Configuration API**
   - `lib/config/api_config.dart` - URLs et configuration de l'API
   - `lib/config/service_locator.dart` - Injection de dépendances

2. **Modèles de données**
   - `lib/models/api_models.dart` - DTOs pour requêtes/réponses API

3. **Services API**
   - `lib/services/api_client_service.dart` - Client HTTP avec authentification
   - `lib/services/api_ruche_service.dart` - Service métier pour les ruches

4. **Widgets**
   - `lib/widgets/api_health_widget.dart` - Widget de test de connectivité API

### 🔄 Fichiers modifiés

1. **Configuration**
   - `pubspec.yaml` - Ajout des dépendances HTTP (dio, http)
   - `lib/main.dart` - Mise à jour de l'injection de dépendances

2. **Écrans**
   - `lib/screens/ruches/ajouter_ruche_screen.dart` - Utilisation des nouveaux services API

## Dépendances ajoutées

```yaml
dependencies:
  # HTTP Client pour API REST
  http: ^1.1.0
  dio: ^5.3.2
```

## Configuration de l'API

### URL de base

```dart
// En développement
static const String baseUrl = 'http://localhost:8080';

// En production
static const String baseUrl = 'https://your-production-api.com';
```

### Endpoints disponibles

- `POST /api/mobile/ruches` - Créer une ruche
- `GET /api/mobile/ruches` - Lister les ruches utilisateur
- `GET /api/mobile/ruches/rucher/{id}` - Ruches par rucher
- `GET /api/mobile/ruches/{id}` - Détails d'une ruche
- `PUT /api/mobile/ruches/{id}` - Mettre à jour une ruche
- `DELETE /api/mobile/ruches/{id}` - Supprimer une ruche
- `GET /api/mobile/ruches/health` - Health check

## Authentification

### Mécanisme

1. **Firebase Authentication** : L'utilisateur se connecte via Firebase
2. **JWT Token** : Récupération du token JWT Firebase
3. **Headers HTTP** : Ajout automatique dans toutes les requêtes
   ```
   Authorization: Bearer <firebase-jwt-token>
   X-Apiculteur-ID: <user-uid>
   ```

### Implémentation

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final String? idToken = await currentUser.getIdToken();
      options.headers['Authorization'] = 'Bearer $idToken';
      options.headers['X-Apiculteur-ID'] = currentUser.uid;
    }
    handler.next(options);
  }
}
```

## Services API

### ApiClientService

Service de base pour les appels HTTP avec :
- Configuration automatique des headers
- Gestion des timeouts
- Authentification automatique
- Gestion centralisée des erreurs
- Logging en mode développement

### ApiRucheService

Service métier pour les ruches avec :
- CRUD complet des ruches
- Validation côté client
- Gestion des erreurs spécifiques
- Messages d'erreur utilisateur
- Health check de l'API

## Nouveaux champs supportés

L'API supporte maintenant des champs additionnels :

### CreateRucheRequest
```dart
{
  "idRucher": "string",
  "nom": "string", 
  "position": "string",
  "typeRuche": "string?",        // 🆕 Nouveau
  "description": "string?",      // 🆕 Nouveau  
  "enService": boolean,
  "dateInstallation": "string?"
}
```

### RucheResponse
```dart
{
  "id": "string",
  "idRucher": "string",
  "nom": "string",
  "position": "string", 
  "typeRuche": "string?",        // 🆕 Nouveau
  "description": "string?",      // 🆕 Nouveau
  "enService": boolean,
  "dateInstallation": "string?",
  "dateCreation": "string",
  "actif": boolean,
  "idApiculteur": "string",
  // Informations enrichies du rucher
  "rucherNom": "string?",        // 🆕 Enrichi par l'API
  "rucherVille": "string?",      // 🆕 Enrichi par l'API  
  "rucherAdresse": "string?"     // 🆕 Enrichi par l'API
}
```

## Gestion des erreurs

### Types d'erreurs

```dart
class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  // Méthodes utilitaires
  bool get isAuthError => statusCode == 401 || statusCode == 403;
  bool get isNetworkError => statusCode >= 500;
  bool get isBadRequest => statusCode >= 400 && statusCode < 500;
}
```

### Messages utilisateur

```dart
String getErrorMessage(dynamic error) {
  if (error is ApiException) {
    switch (error.statusCode) {
      case 400: return 'Données invalides. Veuillez vérifier vos informations.';
      case 401: return 'Authentification requise. Veuillez vous reconnecter.';
      case 403: return 'Accès refusé. Vous n\'avez pas les permissions nécessaires.';
      case 404: return 'Élément non trouvé.';
      case 500: return 'Erreur du serveur. Veuillez réessayer plus tard.';
      case 503: return 'Service temporairement indisponible.';
      default: return error.message;
    }
  }
  return 'Une erreur inattendue s\'est produite.';
}
```

## Widget de santé de l'API

Un widget `ApiHealthWidget` a été créé pour :
- Tester la connectivité à l'API
- Afficher le statut en temps réel
- Permettre les tests manuels
- Afficher les erreurs de connexion

Usage :
```dart
const ApiHealthWidget()
```

## Installation et configuration

### 1. Installer les dépendances

```bash
cd ruche-connectee/mobile-app
flutter pub get
```

### 2. Configurer l'URL de l'API

Modifier `lib/config/api_config.dart` :
```dart
static const String baseUrl = 'http://your-api-url:8080';
```

### 3. Démarrer l'API Spring Boot

```bash
cd backend
./mvnw spring-boot:run
```

### 4. Lancer l'application Flutter

```bash
flutter run
```

## Tests de connectivité

### Vérification manuelle

1. Ouvrir l'application Flutter
2. Aller dans un écran avec le widget `ApiHealthWidget`
3. Vérifier que le statut est "En ligne" (vert)
4. Tester l'ajout d'une ruche

### Test d'API directe

```bash
# Health check
curl http://localhost:8080/api/mobile/ruches/health

# Test avec authentification (remplacer TOKEN)
curl -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
     -H "X-Apiculteur-ID: YOUR_USER_ID" \
     http://localhost:8080/api/mobile/ruches
```

## Migration des données

### ⚠️ Important
Les données existantes dans Firebase restent compatibles. Aucune migration nécessaire.

### Compatibilité
- ✅ Ruches existantes fonctionnent
- ✅ Champs existants préservés  
- ✅ Nouveaux champs optionnels
- ✅ Validation rétrocompatible

## Performance et optimisation

### Mise en cache
- L'API peut implémenter du cache Redis
- Réduction des appels Firebase
- Amélioration des temps de réponse

### Pagination
- Support de la pagination côté API
- Chargement progressif des listes
- Meilleure UX pour grandes données

## Troubleshooting

### Erreurs communes

**Connection refused**
```
Erreur: Connection refused
```
→ Vérifier que l'API Spring Boot est démarrée sur le bon port

**401 Unauthorized**
```
Erreur: Authentification requise
```  
→ Vérifier que l'utilisateur est connecté à Firebase

**404 Not Found**
```
Erreur: Élément non trouvé
```
→ Vérifier les URLs dans `api_config.dart`

### Logs de debug

```dart
// Activer les logs HTTP en mode développement
if (ApiConfig.isDevelopment) {
  _dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
}
```

## Prochaines étapes

### Phase 1 ✅
- [x] Configuration de base
- [x] Service API pour les ruches
- [x] Adaptation de l'écran d'ajout
- [x] Widget de santé API

### Phase 2 🔄 
- [ ] Adaptation de tous les écrans ruches
- [ ] Liste des ruches via API
- [ ] Édition/suppression via API
- [ ] Tests d'intégration

### Phase 3 📋
- [ ] Service API pour les ruchers  
- [ ] Synchronisation temps réel
- [ ] Gestion hors ligne
- [ ] Optimisations performance

## Support

Pour toute question ou problème :
1. Vérifier la documentation Spring Boot
2. Tester la connectivité avec `ApiHealthWidget`
3. Vérifier les logs Flutter et Spring Boot
4. Valider la configuration Firebase

---

**🎯 Objectif atteint** : Architecture unifiée avec API Spring Boot pour web et mobile ! 🚀 