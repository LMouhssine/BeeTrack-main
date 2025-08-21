package com.rucheconnectee.controller;

import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.FirebaseDatabase;
import com.rucheconnectee.service.FirebaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * Contrôleur de test pour vérifier la connexion Firebase
 */
@RestController
@RequestMapping("/api/firebase-test")
@ConditionalOnProperty(name = "app.use-mock-data", havingValue = "false", matchIfMissing = true)
public class FirebaseTestController {

    @Autowired(required = false)
    private FirebaseService firebaseService;

    @Autowired(required = false)
    private FirebaseAuth firebaseAuth;

    @Autowired(required = false)
    private FirebaseDatabase firebaseDatabase;

    @Value("${firebase.project-id:}")
    private String projectId;

    @Value("${app.use-mock-data:true}")
    private boolean useMockData;

    @GetMapping("/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> getFirebaseStatus() {
        Map<String, Object> status = new HashMap<>();
        
        try {
            // Vérifier les propriétés de configuration
            status.put("useMockData", useMockData);
            status.put("projectId", projectId != null && !projectId.isEmpty() ? projectId : "NOT_CONFIGURED");
            
            // Vérifier l'initialisation Firebase
            boolean firebaseInitialized = !FirebaseApp.getApps().isEmpty();
            status.put("firebaseInitialized", firebaseInitialized);
            
            if (firebaseInitialized) {
                FirebaseApp app = FirebaseApp.getInstance();
                status.put("firebaseAppName", app.getName());
                status.put("firebaseProjectId", app.getOptions().getProjectId());
            }
            
            // Vérifier les services Firebase
            status.put("firebaseAuthAvailable", firebaseAuth != null);
            status.put("firebaseDatabaseAvailable", firebaseDatabase != null);
            status.put("firebaseServiceAvailable", firebaseService != null);
            
            // Test de connexion simple
            if (firebaseDatabase != null) {
                try {
                    // Test simple de référence à la base de données
                    String testPath = firebaseDatabase.getReference().toString();
                    status.put("databaseConnectionTest", "SUCCESS");
                    status.put("databaseUrl", testPath);
                } catch (Exception e) {
                    status.put("databaseConnectionTest", "FAILED");
                    status.put("databaseError", e.getMessage());
                }
            }
            
            status.put("overallStatus", firebaseInitialized && firebaseAuth != null && firebaseDatabase != null ? "CONNECTED" : "PARTIAL_CONNECTION");
            
        } catch (Exception e) {
            status.put("overallStatus", "ERROR");
            status.put("error", e.getMessage());
        }
        
        return ResponseEntity.ok(status);
    }

    @GetMapping("/test-write")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> testFirebaseWrite() {
        Map<String, Object> result = new HashMap<>();
        
        if (useMockData) {
            result.put("status", "SKIPPED");
            result.put("message", "Application en mode mock data");
            return ResponseEntity.ok(result);
        }
        
        if (firebaseDatabase == null) {
            result.put("status", "ERROR");
            result.put("message", "Firebase Database non disponible");
            return ResponseEntity.ok(result);
        }
        
        try {
            // Test d'écriture simple
            Map<String, Object> testData = new HashMap<>();
            testData.put("timestamp", System.currentTimeMillis());
            testData.put("message", "Test de connexion Firebase");
            testData.put("source", "BeeTrack API Test");
            
            firebaseDatabase.getReference("test/connection-test").setValueAsync(testData);
            
            result.put("status", "SUCCESS");
            result.put("message", "Test d'écriture Firebase réussi");
            result.put("testData", testData);
            
        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", "Erreur lors du test d'écriture");
            result.put("error", e.getMessage());
        }
        
        return ResponseEntity.ok(result);
    }
}