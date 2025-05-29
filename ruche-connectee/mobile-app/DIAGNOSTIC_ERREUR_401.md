# Diagnostic et résolution de l'erreur 401 🚨

## Problème rencontré

```
ApiException(401): Erreur du serveur
DioException [unknown]: null
```

## Causes possibles

### 1. 🔐 Problème d'authentification Firebase
- L'utilisateur n'est pas connecté à Firebase
- Le token JWT Firebase est expiré ou invalide
- Erreur lors de la récupération du token

### 2. ⚙️ Configuration API Spring Boot
- L'API Spring Boot n'est pas démarrée
- Endpoint protégé par Spring Security
- Headers d'authentification manquants

### 3. 🌐 Problème de réseau/CORS
- L'API n'est pas accessible depuis Flutter
- Configuration CORS incorrecte

## Étapes de diagnostic

### Étape 1: Vérifier l'authentification Firebase

1. **Ouvrir l'écran de test** (`TestApiScreen`)
2. **Vérifier le widget "État Authentification"**
   - ✅ Utilisateur connecté: Oui
   - ✅ Token JWT: Présent
   - ❌ Si non, se reconnecter à Firebase

### Étape 2: Tester la connectivité API

1. **Vérifier le widget "API Spring Boot"**
   - ✅ Connectivité: En ligne
   - ❌ Si hors ligne, vérifier que l'API Spring Boot est démarrée

2. **Test manuel de l'API**
   ```bash
   # Test endpoint public (doit fonctionner)
   curl http://localhost:8080/api/mobile/ruches/health
   
   # Doit retourner:
   {"status":"OK","message":"API Ruches fonctionnelle","timestamp":...}
   ```

### Étape 3: Vérifier les logs Flutter

Chercher dans les logs Flutter :
```
🐛 Headers d'authentification ajoutés:
- Authorization: Bearer eyJhbGciOiJSUzI1...
- X-Apiculteur-ID: abc123...
```

Si ces logs n'apparaissent pas, le problème est côté Firebase.

## Solutions

### Solution 1: Problème d'authentification Firebase

**Symptômes:**
- Widget AuthDebugWidget montre "Utilisateur connecté: Non"
- Pas de token JWT

**Actions:**
1. Se reconnecter à Firebase dans l'app
2. Vérifier la configuration Firebase dans `firebase_options.dart`
3. Redémarrer l'application Flutter

### Solution 2: API Spring Boot non démarrée

**Symptômes:**
- Widget ApiHealthWidget montre "Connectivité: Hors ligne"
- Erreur de connexion

**Actions:**
1. Démarrer l'API Spring Boot :
   ```bash
   cd ruche-connectee/web-app
   ./mvnw spring-boot:run
   ```
2. Vérifier que l'API démarre sur le port 8080
3. Tester l'endpoint health : http://localhost:8080/api/mobile/ruches/health

### Solution 3: Configuration Spring Boot

**Symptômes:**
- Connectivité OK mais authentification échoue
- Erreur 401 même avec token valide

**Actions:**
1. **Modifier le contrôleur Spring Boot** pour rendre l'endpoint health public :
   ```java
   @GetMapping("/health")
   public ResponseEntity<?> healthCheck() {
       return ResponseEntity.ok(new HealthResponse("OK", "API Ruches fonctionnelle"));
   }
   ```

2. **Vérifier qu'il n'y a pas de Spring Security** qui bloque les requêtes

### Solution 4: Problème CORS

**Symptômes:**
- Erreur CORS dans les logs du navigateur (si testé depuis le web)

**Actions:**
1. Vérifier que `@CrossOrigin(origins = "*")` est présent sur le contrôleur
2. Ajouter la configuration CORS globale si nécessaire

## Tests de validation

### Test 1: Authentification Firebase
```dart
// Dans AuthDebugWidget
final user = FirebaseAuth.instance.currentUser;
final token = await user?.getIdToken();
print('Token: ${token?.substring(0, 20)}...');
```

### Test 2: Appel API direct
```dart
// Test sans authentification
final dio = Dio();
final response = await dio.get('http://localhost:8080/api/mobile/ruches/health');
print('Response: ${response.data}');
```

### Test 3: Appel API avec authentification
```dart
// Via ApiClientService
final apiClient = getIt<ApiClientService>();
final response = await apiClient.get('/api/mobile/ruches/health/auth');
print('Auth Response: ${response.data}');
```

## Configuration recommandée

### 1. Endpoint health public

```java
@GetMapping("/health")
public ResponseEntity<?> healthCheck() {
    return ResponseEntity.ok(new HealthResponse("OK", "API Ruches fonctionnelle"));
}
```

### 2. Endpoint health avec auth

```java
@GetMapping("/health/auth")
public ResponseEntity<?> healthCheckWithAuth(
        @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
    return ResponseEntity.ok(new HealthResponse("OK", "Auth OK - User: " + apiculteurId));
}
```

### 3. Headers Flutter

```dart
options.headers['Authorization'] = 'Bearer $idToken';
options.headers['X-Apiculteur-ID'] = currentUser.uid;
options.headers['Content-Type'] = 'application/json';
```

## Logs de débogage

### Activer les logs détaillés

1. **Flutter** : Les logs sont déjà activés via `LoggerService`
2. **Spring Boot** : Ajouter dans `application.properties` :
   ```properties
   logging.level.com.rucheconnectee=DEBUG
   logging.level.org.springframework.web=DEBUG
   ```

### Logs à surveiller

- ✅ `🐛 Utilisateur connecté: abc123... (email@example.com)`
- ✅ `🐛 Headers d'authentification ajoutés`
- ✅ `🐛 Requête préparée: POST http://localhost:8080/api/mobile/ruches`
- ❌ `⛔ Erreur HTTP 401: Unauthorized`

## Contact/Support

Si le problème persiste :
1. Vérifier tous les widgets de debug
2. Copier les logs complets Flutter et Spring Boot
3. Tester l'endpoint health manuellement
4. Vérifier la configuration Firebase

---

**🎯 Objectif** : Résoudre l'erreur 401 pour permettre la communication Flutter ↔ Spring Boot API ! 🚀 