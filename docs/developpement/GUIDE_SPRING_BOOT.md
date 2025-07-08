# 🛠️ Guide de développement Spring Boot - BeeTrack

Guide complet pour développer et contribuer à l'application web BeeTrack.

## 🏗️ Architecture de l'application

### Stack technique
- **Backend** : Spring Boot 3.x
- **Frontend** : Thymeleaf + Bootstrap 5
- **Base de données** : Firebase Firestore
- **Build** : Maven 3.8+
- **Java** : 17+

### Pattern MVC
```
┌─────────────────────────────────────────────────────────┐
│                    Web Browser                          │
└─────────────────────┬───────────────────────────────────┘
                      │ HTTP Request/Response
┌─────────────────────▼───────────────────────────────────┐
│                  Controller                             │
│  - WebController (pages)                                │
│  - RucheController (API)                                │
│  - RucherController (API)                               │
└─────────────────────┬───────────────────────────────────┘
                      │ Appel métier
┌─────────────────────▼───────────────────────────────────┐
│                   Service                               │
│  - RucheService                                         │
│  - RucherService                                        │
│  - FirebaseService                                      │
└─────────────────────┬───────────────────────────────────┘
                      │ Accès données
┌─────────────────────▼───────────────────────────────────┐
│               Firebase Firestore                        │
│  - Collections (ruchers, ruches, donneesCapteurs)       │
└─────────────────────────────────────────────────────────┘
```

## 📁 Structure du code

### Packages principaux

```java
com.rucheconnectee/
├── BeeTrackApplication.java           // Point d'entrée
├── config/                           // Configuration Spring
│   ├── FirebaseConfig.java          // Configuration Firebase
│   ├── SecurityConfig.java          // Sécurité
│   └── DevelopmentConfig.java       // Profil dev
├── controller/                      // Contrôleurs MVC
│   ├── WebController.java           // Pages Thymeleaf
│   ├── RucheController.java         // API REST ruches
│   ├── RucherController.java        // API REST ruchers
│   └── TestController.java          // Endpoints de test
├── service/                         // Logique métier
│   ├── FirebaseService.java         // Service Firebase
│   ├── RucheService.java           // Gestion ruches
│   ├── RucherService.java          // Gestion ruchers
│   └── MockDataService.java        // Données de test
├── model/                          // Modèles de données
│   ├── Ruche.java                  // Entité ruche
│   ├── Rucher.java                 // Entité rucher
│   └── DonneesCapteur.java         // Données IoT
└── exception/                      // Gestion d'erreurs
    ├── RucheNotFoundException.java
    └── FirebaseException.java
```

### Templates Thymeleaf

```
templates/
├── layout.html                     // Template de base
├── dashboard.html                  // Page d'accueil
├── ruchers.html                   // Gestion ruchers
├── ruches-list.html              // Liste ruches
├── ruche-details.html            // Détail ruche
├── statistiques.html             // Analyses
└── fragments/                    // Composants réutilisables
    ├── navigation.html           // Menu navigation
    ├── alerts.html               // Alertes
    └── charts.html               // Graphiques
```

## 🔧 Configuration

### application.properties

```properties
# Configuration serveur
server.port=8080
server.servlet.context-path=/

# Configuration Thymeleaf
spring.thymeleaf.cache=false
spring.thymeleaf.encoding=UTF-8
spring.thymeleaf.prefix=classpath:/templates/
spring.thymeleaf.suffix=.html

# Configuration Firebase
firebase.project-id=${FIREBASE_PROJECT_ID:your-project-id}
firebase.service-account=${FIREBASE_SERVICE_ACCOUNT:firebase-service-account.json}

# Configuration logs
logging.level.com.rucheconnectee=INFO
logging.level.com.google.firebase=WARN
logging.pattern.console=%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n

# Configuration développement
spring.devtools.restart.enabled=true
spring.devtools.livereload.enabled=true

# Configuration production
spring.profiles.active=@spring.profiles.active@
```

### Profils d'environnement

#### application-dev.properties
```properties
# Mode développement
spring.thymeleaf.cache=false
logging.level.com.rucheconnectee=DEBUG
management.endpoints.web.exposure.include=*
```

#### application-prod.properties
```properties
# Mode production
spring.thymeleaf.cache=true
logging.level.com.rucheconnectee=WARN
management.endpoints.web.exposure.include=health,info
```

## 🔥 Configuration Firebase

### FirebaseConfig.java

```java
@Configuration
public class FirebaseConfig {
    
    @Value("${firebase.service-account}")
    private String serviceAccountPath;
    
    @Value("${firebase.project-id}")
    private String projectId;
    
    @Bean
    @Primary
    public FirebaseApp firebaseApp() throws IOException {
        if (FirebaseApp.getApps().isEmpty()) {
            FileInputStream serviceAccount = new FileInputStream(
                getClass().getClassLoader().getResource(serviceAccountPath).getFile()
            );
            
            FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                .setProjectId(projectId)
                .build();
                
            return FirebaseApp.initializeApp(options);
        }
        return FirebaseApp.getInstance();
    }
    
    @Bean
    public Firestore firestore() {
        return FirestoreClient.getFirestore();
    }
}
```

### FirebaseService.java

```java
@Service
@Slf4j
public class FirebaseService {
    
    @Autowired
    private Firestore firestore;
    
    public <T> List<T> getCollection(String collectionName, Class<T> clazz) {
        try {
            ApiFuture<QuerySnapshot> query = firestore.collection(collectionName).get();
            QuerySnapshot querySnapshot = query.get();
            
            return querySnapshot.getDocuments().stream()
                .map(doc -> {
                    T object = doc.toObject(clazz);
                    // Ajout de l'ID du document
                    if (object instanceof BaseEntity) {
                        ((BaseEntity) object).setId(doc.getId());
                    }
                    return object;
                })
                .collect(Collectors.toList());
        } catch (Exception e) {
            log.error("Erreur lors de la récupération de la collection {}", collectionName, e);
            throw new RuntimeException("Erreur Firebase", e);
        }
    }
    
    public <T> Optional<T> getDocument(String collection, String id, Class<T> clazz) {
        try {
            DocumentSnapshot document = firestore.collection(collection).document(id).get().get();
            if (document.exists()) {
                T object = document.toObject(clazz);
                if (object instanceof BaseEntity) {
                    ((BaseEntity) object).setId(document.getId());
                }
                return Optional.of(object);
            }
            return Optional.empty();
        } catch (Exception e) {
            log.error("Erreur lors de la récupération du document {}/{}", collection, id, e);
            return Optional.empty();
        }
    }
    
    public String saveDocument(String collection, Object data) {
        try {
            ApiFuture<DocumentReference> result = firestore.collection(collection).add(data);
            return result.get().getId();
        } catch (Exception e) {
            log.error("Erreur lors de la sauvegarde dans {}", collection, e);
            throw new RuntimeException("Erreur Firebase", e);
        }
    }
}
```

## 🎮 Contrôleurs

### WebController.java (Pages)

```java
@Controller
@Slf4j
public class WebController {
    
    @Autowired
    private RucherService rucherService;
    
    @Autowired
    private RucheService rucheService;
    
    @GetMapping("/")
    public String home() {
        return "redirect:/dashboard";
    }
    
    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        try {
            // Statistiques globales
            model.addAttribute("totalRuchers", rucherService.count());
            model.addAttribute("totalRuches", rucheService.count());
            model.addAttribute("ruchesActives", rucheService.countActives());
            model.addAttribute("alertesActives", rucheService.countAlertes());
            
            // Graphiques
            model.addAttribute("temperaturesData", rucheService.getTemperaturesData());
            model.addAttribute("humiditeData", rucheService.getHumiditeData());
            
            // Activité récente
            model.addAttribute("activiteRecente", rucheService.getActiviteRecente());
            
            model.addAttribute("currentPage", "dashboard");
            model.addAttribute("pageTitle", "Dashboard");
            
            return "dashboard";
        } catch (Exception e) {
            log.error("Erreur dashboard", e);
            model.addAttribute("error", "Erreur de chargement des données");
            return "error";
        }
    }
    
    @GetMapping("/ruchers")
    public String ruchers(Model model) {
        try {
            List<Rucher> ruchers = rucherService.getAllRuchers();
            
            model.addAttribute("ruchers", ruchers);
            model.addAttribute("totalRuchers", ruchers.size());
            model.addAttribute("totalRuches", ruchers.stream()
                .mapToInt(r -> r.getNombreRuches())
                .sum());
            model.addAttribute("currentPage", "ruchers");
            model.addAttribute("pageTitle", "Gestion des Ruchers");
            
            return "ruchers";
        } catch (Exception e) {
            log.error("Erreur ruchers", e);
            model.addAttribute("error", "Erreur de chargement des ruchers");
            return "error";
        }
    }
}
```

### RucheController.java (API REST)

```java
@RestController
@RequestMapping("/api/ruches")
@Slf4j
public class RucheController {
    
    @Autowired
    private RucheService rucheService;
    
    @GetMapping
    public ResponseEntity<List<Ruche>> getAllRuches() {
        try {
            List<Ruche> ruches = rucheService.getAllRuches();
            return ResponseEntity.ok(ruches);
        } catch (Exception e) {
            log.error("Erreur récupération ruches", e);
            return ResponseEntity.status(500).build();
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Ruche> getRuche(@PathVariable String id) {
        try {
            Optional<Ruche> ruche = rucheService.getRucheById(id);
            return ruche.map(ResponseEntity::ok)
                       .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            log.error("Erreur récupération ruche {}", id, e);
            return ResponseEntity.status(500).build();
        }
    }
    
    @PostMapping
    public ResponseEntity<String> createRuche(@RequestBody Ruche ruche) {
        try {
            String id = rucheService.createRuche(ruche);
            return ResponseEntity.ok(id);
        } catch (Exception e) {
            log.error("Erreur création ruche", e);
            return ResponseEntity.status(500).build();
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Void> updateRuche(@PathVariable String id, @RequestBody Ruche ruche) {
        try {
            rucheService.updateRuche(id, ruche);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Erreur mise à jour ruche {}", id, e);
            return ResponseEntity.status(500).build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRuche(@PathVariable String id) {
        try {
            rucheService.deleteRuche(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Erreur suppression ruche {}", id, e);
            return ResponseEntity.status(500).build();
        }
    }
}
```

## 🔄 Services

### RucheService.java

```java
@Service
@Slf4j
public class RucheService {
    
    private static final String COLLECTION_NAME = "ruches";
    
    @Autowired
    private FirebaseService firebaseService;
    
    public List<Ruche> getAllRuches() {
        return firebaseService.getCollection(COLLECTION_NAME, Ruche.class);
    }
    
    public Optional<Ruche> getRucheById(String id) {
        return firebaseService.getDocument(COLLECTION_NAME, id, Ruche.class);
    }
    
    public String createRuche(Ruche ruche) {
        // Validation
        validateRuche(ruche);
        
        // Ajout timestamp
        ruche.setDateCreation(Timestamp.now());
        ruche.setActif(true);
        
        return firebaseService.saveDocument(COLLECTION_NAME, ruche);
    }
    
    public void updateRuche(String id, Ruche ruche) {
        validateRuche(ruche);
        ruche.setDateModification(Timestamp.now());
        
        firebaseService.updateDocument(COLLECTION_NAME, id, ruche);
    }
    
    public void deleteRuche(String id) {
        // Soft delete
        Map<String, Object> updates = new HashMap<>();
        updates.put("actif", false);
        updates.put("dateSupression", Timestamp.now());
        
        firebaseService.updateDocument(COLLECTION_NAME, id, updates);
    }
    
    public long count() {
        return getAllRuches().stream()
               .filter(Ruche::isActif)
               .count();
    }
    
    public long countActives() {
        return getAllRuches().stream()
               .filter(ruche -> ruche.isActif() && ruche.getStatut().equals("ACTIVE"))
               .count();
    }
    
    private void validateRuche(Ruche ruche) {
        if (ruche.getNom() == null || ruche.getNom().trim().isEmpty()) {
            throw new IllegalArgumentException("Le nom de la ruche est obligatoire");
        }
        if (ruche.getIdRucher() == null || ruche.getIdRucher().trim().isEmpty()) {
            throw new IllegalArgumentException("Le rucher est obligatoire");
        }
    }
}
```

## 🧪 Tests

### Tests unitaires

```java
@SpringBootTest
@TestMethodOrder(OrderAnnotation.class)
class RucheServiceTest {
    
    @Autowired
    private RucheService rucheService;
    
    @MockBean
    private FirebaseService firebaseService;
    
    @Test
    @Order(1)
    void testGetAllRuches() {
        // Arrange
        List<Ruche> mockRuches = Arrays.asList(
            createTestRuche("Ruche 1"),
            createTestRuche("Ruche 2")
        );
        when(firebaseService.getCollection("ruches", Ruche.class))
            .thenReturn(mockRuches);
        
        // Act
        List<Ruche> result = rucheService.getAllRuches();
        
        // Assert
        assertThat(result).hasSize(2);
        assertThat(result.get(0).getNom()).isEqualTo("Ruche 1");
    }
    
    @Test
    @Order(2)
    void testCreateRuche() {
        // Arrange
        Ruche ruche = createTestRuche("Nouvelle Ruche");
        when(firebaseService.saveDocument(eq("ruches"), any(Ruche.class)))
            .thenReturn("generated-id");
        
        // Act
        String id = rucheService.createRuche(ruche);
        
        // Assert
        assertThat(id).isEqualTo("generated-id");
        verify(firebaseService).saveDocument(eq("ruches"), any(Ruche.class));
    }
    
    @Test
    void testCreateRuche_NomVide_ThrowsException() {
        // Arrange
        Ruche ruche = new Ruche();
        ruche.setNom("");
        
        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> {
            rucheService.createRuche(ruche);
        });
    }
    
    private Ruche createTestRuche(String nom) {
        Ruche ruche = new Ruche();
        ruche.setNom(nom);
        ruche.setIdRucher("rucher-1");
        ruche.setType("Dadant");
        ruche.setActif(true);
        return ruche;
    }
}
```

### Tests d'intégration

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestPropertySource(locations = "classpath:application-test.properties")
class WebControllerIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @LocalServerPort
    private int port;
    
    @Test
    void testDashboardPage() {
        // Act
        ResponseEntity<String> response = restTemplate.getForEntity(
            "http://localhost:" + port + "/dashboard", 
            String.class
        );
        
        // Assert
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).contains("Dashboard");
        assertThat(response.getBody()).contains("Total ruchers");
    }
    
    @Test
    void testApiRuches() {
        // Act
        ResponseEntity<String> response = restTemplate.getForEntity(
            "http://localhost:" + port + "/api/ruches", 
            String.class
        );
        
        // Assert
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }
}
```

## 🔨 Outils de développement

### Maven plugins utiles

```xml
<build>
    <plugins>
        <!-- Spring Boot plugin -->
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
        
        <!-- Tests plugin -->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-surefire-plugin</artifactId>
            <configuration>
                <includes>
                    <include>**/*Test.java</include>
                    <include>**/*Tests.java</include>
                </includes>
            </configuration>
        </plugin>
        
        <!-- Coverage plugin -->
        <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <executions>
                <execution>
                    <goals>
                        <goal>prepare-agent</goal>
                    </goals>
                </execution>
                <execution>
                    <id>report</id>
                    <phase>test</phase>
                    <goals>
                        <goal>report</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

### Scripts de développement

```bash
#!/bin/bash
# scripts/dev.sh

# Démarrage avec profil dev
mvn spring-boot:run -Dspring.profiles.active=dev

# Mode debug
mvn spring-boot:run -Dspring.profiles.active=dev \
    -Dagentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005

# Tests avec coverage
mvn clean test jacoco:report

# Build production
mvn clean package -Pprod
```

## 📈 Monitoring et observabilité

### Spring Boot Actuator

```java
@Component
public class CustomHealthIndicator implements HealthIndicator {
    
    @Autowired
    private FirebaseService firebaseService;
    
    @Override
    public Health health() {
        try {
            // Test connexion Firebase
            firebaseService.testConnection();
            return Health.up()
                .withDetail("firebase", "Connected")
                .withDetail("timestamp", System.currentTimeMillis())
                .build();
        } catch (Exception e) {
            return Health.down()
                .withDetail("firebase", "Disconnected")
                .withDetail("error", e.getMessage())
                .build();
        }
    }
}
```

### Métriques personnalisées

```java
@Component
public class BeeTrackMetrics {
    
    private final Counter ruchesCreatedCounter;
    private final Timer rucheServiceTimer;
    
    public BeeTrackMetrics(MeterRegistry meterRegistry) {
        this.ruchesCreatedCounter = Counter.builder("beetrck.ruches.created")
            .description("Nombre de ruches créées")
            .register(meterRegistry);
            
        this.rucheServiceTimer = Timer.builder("beetrck.ruche.service.duration")
            .description("Durée des appels service ruche")
            .register(meterRegistry);
    }
    
    public void incrementRuchesCreated() {
        ruchesCreatedCounter.increment();
    }
    
    public Timer.Sample startTimer() {
        return Timer.start();
    }
}
```

## 🚀 Déploiement

### Configuration Docker

```dockerfile
FROM openjdk:17-jre-slim

# Variables d'environnement
ENV SPRING_PROFILES_ACTIVE=prod
ENV SERVER_PORT=8080

# Création utilisateur non-root
RUN addgroup --system spring && adduser --system spring --group spring

# Copie du JAR
COPY --chown=spring:spring target/web-app-*.jar app.jar

# Exposition du port
EXPOSE 8080

# Utilisateur d'exécution
USER spring:spring

# Point d'entrée
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

### Scripts de build

```bash
#!/bin/bash
# scripts/build.sh

# Build JAR
mvn clean package -DskipTests

# Build image Docker
docker build -t beetrck-web:latest .

# Tag pour production
docker tag beetrck-web:latest beetrck-web:$(date +%Y%m%d)

echo "Build terminé avec succès"
```

---

<div align="center">

**Guide de développement BeeTrack**  
*Spring Boot + Thymeleaf + Firebase*

*Développez des fonctionnalités robustes pour l'apiculture connectée*

</div> 