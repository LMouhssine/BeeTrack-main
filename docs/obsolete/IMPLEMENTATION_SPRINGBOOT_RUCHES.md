# 🐝 Implémentation Spring Boot + React - Gestion des Ruches

## 📋 Vue d'ensemble

Cette documentation décrit l'implémentation complète de la gestion des ruches avec une architecture **Java Spring Boot (backend) + React (frontend)** qui remplace l'accès direct à Firebase depuis le frontend par des API REST sécurisées.

## 🏗️ Architecture

```
┌─────────────────┐    HTTP/REST     ┌─────────────────┐    Firebase Admin    ┌─────────────────┐
│   React App     │ ────────────────→ │  Spring Boot    │ ─────────────────────→ │   Firestore     │
│   (Frontend)    │                  │   (Backend)     │                      │   (Database)    │
└─────────────────┘                  └─────────────────┘                      └─────────────────┘
```

### Composants

#### **Backend - Spring Boot**
- **Contrôleurs** : `RucheMobileController`
- **Services** : `RucheService` (étendu), `RucherService`
- **Modèles** : `Ruche`, `CreateRucheRequest`, `RucheResponse`
- **Configuration** : Firebase Admin SDK

#### **Frontend - React**
- **Services** : `ApiRucheService`
- **Composants** : `RuchesList`, `AjouterRucheModal`
- **Configuration** : Authentification Firebase + API

## 🔧 Implémentation Backend

### 1. Modèles de données

#### `CreateRucheRequest.java`
```java
public class CreateRucheRequest {
    @NotBlank(message = "Le nom de la ruche est requis")
    private String nom;
    
    @NotBlank(message = "La position est requise")
    private String position;
    
    @NotNull(message = "L'ID du rucher est requis")
    private String idRucher;
    
    private boolean enService = true;
    private LocalDateTime dateInstallation;
    private String typeRuche;
    private String description;
    
    // Getters, setters et méthode toRuche()
}
```

#### `RucheResponse.java`
```java
public class RucheResponse {
    private String id, nom, position, idRucher;
    private String rucherNom, rucherAdresse;
    private boolean enService, actif;
    private LocalDateTime dateInstallation, dateCreation, dateMiseAJour;
    private String idApiculteur, typeRuche, description;
    
    // Données capteurs optionnelles
    private Double temperature, humidite;
    private Boolean couvercleOuvert;
    private Integer niveauBatterie;
    
    public static RucheResponse fromRuche(Ruche ruche) { /* ... */ }
}
```

### 2. Service étendu

#### Nouvelles méthodes dans `RucheService.java`
```java
// Création avec validation complète
public RucheResponse ajouterRuche(CreateRucheRequest request, String apiculteurId) {
    // 1. Validation du rucher et permissions
    // 2. Vérification unicité position/nom
    // 3. Création et sauvegarde
    // 4. Mise à jour compteurs rucher
}

// Récupération avec infos rucher
public List<RucheResponse> obtenirRuchesUtilisateur(String apiculteurId) {
    // Récupération + enrichissement avec données rucher
}

// Suppression sécurisée
public void supprimerRuche(String rucheId, String apiculteurId) {
    // Validation permissions + suppression logique
}
```

### 3. Contrôleur API

#### `RucheMobileController.java`
```java
@RestController
@RequestMapping("/api/mobile/ruches")
@CrossOrigin(origins = "*")
public class RucheMobileController {
    
    @PostMapping
    public ResponseEntity<?> ajouterRuche(
        @Valid @RequestBody CreateRucheRequest request,
        @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
        // Validation + création
    }
    
    @GetMapping
    public ResponseEntity<?> obtenirRuchesUtilisateur(
        @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
        // Récupération toutes ruches utilisateur
    }
    
    @GetMapping("/rucher/{rucherId}")
    public ResponseEntity<?> obtenirRuchesParRucher(
        @PathVariable String rucherId,
        @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
        // Récupération ruches d'un rucher
    }
    
    @DeleteMapping("/{rucheId}")
    public ResponseEntity<?> supprimerRuche(
        @PathVariable String rucheId,
        @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
        // Suppression sécurisée
    }
    
    @GetMapping("/health")
    public ResponseEntity<?> healthCheck() {
        // Vérification santé API
    }
}
```

## 🎨 Implémentation Frontend

### 1. Service API

#### `apiRucheService.ts`
```typescript
export class ApiRucheService {
    private static apiKey: string | null = null;
    private static apiculteurId: string | null = null;
    
    static setAuth(apiKey: string, apiculteurId: string) {
        this.apiKey = apiKey;
        this.apiculteurId = apiculteurId;
    }
    
    private static getHeaders(): HeadersInit {
        return {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.apiKey}`,
            'X-Apiculteur-ID': this.apiculteurId!,
        };
    }
    
    static async ajouterRuche(request: CreateRucheRequest): Promise<RucheResponse> {
        const response = await fetch(`${API_BASE_URL}/api/mobile/ruches`, {
            method: 'POST',
            headers: this.getHeaders(),
            body: JSON.stringify(request),
        });
        return this.handleResponse<RucheResponse>(response);
    }
    
    // Autres méthodes...
}
```

### 2. Configuration d'authentification

#### `config/api.ts`
```typescript
export const initializeApiAuthentication = () => {
    onAuthStateChanged(auth, async (user) => {
        if (user) {
            const token = await user.getIdToken();
            ApiRucheService.setAuth(token, user.uid);
            
            // Test connectivité
            const isHealthy = await ApiRucheService.healthCheck();
            console.log(isHealthy ? '✅ API accessible' : '⚠️ API non accessible');
        }
    });
};
```

### 3. Composants modifiés

#### `AjouterRucheModal.tsx`
- Remplacement `RucheService` par `ApiRucheService`
- Ajout champs `typeRuche` et `description`
- Gestion erreurs API améliorée

#### `RuchesList.tsx`
- Utilisation `RucheResponse[]` au lieu de `RucheAvecRucher[]`
- Affichage données capteurs optionnelles
- Test connectivité API avec bouton "Réessayer"

## 🔐 Authentification et Sécurité

### Flux d'authentification
1. **Frontend** : Connexion Firebase → Token JWT
2. **API** : Header `Authorization: Bearer <token>` + `X-Apiculteur-ID`
3. **Backend** : Validation token Firebase + vérification permissions

### Validation côté backend
```java
// Vérification permissions rucher
if (!rucher.getApiculteurId().equals(apiculteurId)) {
    throw new IllegalArgumentException("Accès non autorisé");
}

// Validation unicité
boolean nomExiste = ruchesExistantes.stream()
    .anyMatch(r -> request.getNom().trim().equalsIgnoreCase(r.getNom()));
```

### Sécurité
- ✅ Validation JWT Firebase
- ✅ Contrôle d'accès par utilisateur
- ✅ Validation des entrées (Bean Validation)
- ✅ Suppression logique (préservation données)
- ✅ Transaction Firestore (cohérence)

## 📡 API Endpoints

### Base URL
- **Développement** : `http://localhost:8080`
- **Production** : À configurer dans `REACT_APP_API_URL`

### Endpoints disponibles

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| `POST` | `/api/mobile/ruches` | Créer une ruche |
| `GET` | `/api/mobile/ruches` | Lister toutes les ruches |
| `GET` | `/api/mobile/ruches/rucher/{id}` | Ruches d'un rucher (triées par nom croissant) |
| `GET` | `/api/mobile/ruches/{id}` | Détails d'une ruche |
| `PUT` | `/api/mobile/ruches/{id}` | Modifier une ruche |
| `DELETE` | `/api/mobile/ruches/{id}` | Supprimer une ruche |
| `GET` | `/api/mobile/ruches/health` | État de l'API |

### Format des réponses

#### Succès
```json
{
    "id": "abc123",
    "nom": "Ruche A1",
    "position": "A1",
    "idRucher": "rucher123",
    "rucherNom": "Rucher Principal",
    "rucherAdresse": "123 Rue des Abeilles",
    "enService": true,
    "dateInstallation": "2024-01-15T10:00:00",
    "typeRuche": "Dadant",
    "actif": true
}
```

#### Erreur
```json
{
    "code": "VALIDATION_ERROR",
    "message": "Le nom de la ruche est requis",
    "timestamp": 1705312800000
}
```

## 🚀 Configuration et Déploiement

### Variables d'environnement

#### Frontend (`.env`)
```env
REACT_APP_API_URL=http://localhost:8080
REACT_APP_FIREBASE_API_KEY=your_key
REACT_APP_FIREBASE_PROJECT_ID=your_project
```

#### Backend (`application.properties`)
```properties
# Firebase
firebase.config.path=path/to/service-account.json

# Firestore
spring.cloud.gcp.firestore.project-id=your-project-id

# CORS
cors.allowed-origins=http://localhost:3000,https://your-domain.com
```

### Démarrage

#### Backend
```bash
cd ruche-connectee/web-app
mvn spring-boot:run
```

#### Frontend
```bash
cd /path/to/react-app
REACT_APP_API_URL=http://localhost:8080 npm start
```

## 🧪 Tests

### Tests Backend
```java
@Test
public void testAjouterRucheAvecValidation() {
    CreateRucheRequest request = new CreateRucheRequest();
    request.setNom("Test Ruche");
    request.setPosition("A1");
    request.setIdRucher("rucher123");
    
    RucheResponse result = rucheService.ajouterRuche(request, "user123");
    assertNotNull(result.getId());
    assertEquals("Test Ruche", result.getNom());
}
```

### Tests Frontend
```typescript
describe('ApiRucheService', () => {
    test('devrait créer une ruche', async () => {
        const request: CreateRucheRequest = {
            nom: 'Test Ruche',
            position: 'A1',
            idRucher: 'rucher123'
        };
        
        const result = await ApiRucheService.ajouterRuche(request);
        expect(result.nom).toBe('Test Ruche');
    });
});
```

## 📊 Métriques et Monitoring

### Logs Backend
```java
// RucheService
log.info("🐝 Création ruche {} pour utilisateur {}", request.getNom(), apiculteurId);
log.warn("⚠️ Tentative création ruche sur rucher non autorisé: {}", rucherId);
```

### Logs Frontend
```typescript
console.log('🐝 Ruches chargées:', ruchesData.length);
console.log('🔑 Authentification API configurée pour utilisateur:', user.uid);
console.log('✅ API Spring Boot accessible');
```

## 🔮 Évolutions futures

### Backend
- [ ] **Cache Redis** : Performance des requêtes fréquentes
- [ ] **WebSocket** : Mises à jour temps réel des capteurs
- [ ] **Pagination** : Gestion grandes collections
- [ ] **Rate Limiting** : Protection contre les abus
- [ ] **Métriques** : Prometheus/Grafana

### Frontend
- [ ] **Offline-first** : Cache local + synchronisation
- [ ] **PWA** : Installation application web
- [ ] **WebSocket** : Temps réel côté client
- [ ] **Optimistic UI** : UX améliorée
- [ ] **Service Worker** : Cache intelligent

### Sécurité
- [ ] **HTTPS** : Chiffrement communications
- [ ] **API Keys** : Alternative aux tokens Firebase
- [ ] **Audit Trail** : Traçabilité modifications
- [ ] **Backup** : Stratégie sauvegarde
- [ ] **GDPR** : Conformité données personnelles

## 🆘 Dépannage

### Problèmes courants

#### API non accessible
1. Vérifier `REACT_APP_API_URL`
2. Contrôler démarrage Spring Boot
3. Tester `/api/mobile/ruches/health`

#### Erreur d'authentification
1. Vérifier token Firebase valide
2. Contrôler header `X-Apiculteur-ID`
3. Vérifier configuration Firebase Admin

#### Erreur de permissions
1. Vérifier propriété du rucher
2. Contrôler ID utilisateur cohérent
3. Tester avec rucher actif

### Commandes utiles
```bash
# Test API
curl -X GET http://localhost:8080/api/mobile/ruches/health

# Logs Spring Boot
tail -f logs/application.log

# Logs React
npm start --verbose
```

---

*Cette implémentation offre une architecture robuste, sécurisée et scalable pour la gestion des ruches avec une séparation claire entre frontend et backend.* 🐝 