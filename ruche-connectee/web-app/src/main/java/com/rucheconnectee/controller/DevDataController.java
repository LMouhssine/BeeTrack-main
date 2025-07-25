package com.rucheconnectee.controller;

import com.rucheconnectee.service.FirebaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

/**
 * Contrôleur pour générer des données de développement.
 * Désactivé en mode développement sans Firebase.
 */
@RestController
@RequestMapping("/api/dev")
@ConditionalOnProperty(name = "firebase.project-id")
public class DevDataController {

    @Autowired
    private FirebaseService firebaseService;

    /**
     * Health check simple
     */
    @GetMapping("/health")
    public ResponseEntity<?> healthCheck() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "OK");
        response.put("message", "Contrôleur de données de test actif");
        response.put("timestamp", LocalDateTime.now());
        return ResponseEntity.ok(response);
    }

    /**
     * Crée des données de test pour une ruche spécifique
     */
    @PostMapping("/create-test-data/{rucheId}")
    public ResponseEntity<?> createTestData(
            @PathVariable String rucheId,
            @RequestParam(defaultValue = "10") int nombreJours,
            @RequestParam(defaultValue = "8") int mesuresParJour) {
        try {
            
            List<Map<String, Object>> mesuresCreees = new ArrayList<>();
            LocalDateTime maintenant = LocalDateTime.now();
            Random random = new Random();
            
            // Créer des données pour les X derniers jours
            for (int jour = nombreJours; jour >= 0; jour--) {
                LocalDateTime dateJour = maintenant.minusDays(jour);
                
                // Créer plusieurs mesures par jour
                for (int mesure = 0; mesure < mesuresParJour; mesure++) {
                    // Espacer les mesures dans la journée
                    LocalDateTime timestampMesure = dateJour.plusHours(mesure * (24 / mesuresParJour))
                        .plusMinutes(random.nextInt(60));
                    
                    // Générer des données réalistes
                    double temperature = 15.0 + random.nextGaussian() * 5.0; // 15°C ± 5°C
                    double humidity = 50.0 + random.nextGaussian() * 15.0; // 50% ± 15%
                    int batterie = Math.max(10, Math.min(100, 80 + random.nextInt(20))); // 80-100%
                    boolean couvercleOuvert = random.nextDouble() < 0.1; // 10% de chance d'être ouvert
                    int signalQualite = 70 + random.nextInt(30); // 70-100%
                    
                    // Limiter les valeurs dans des plages réalistes
                    temperature = Math.max(-10, Math.min(40, temperature));
                    humidity = Math.max(0, Math.min(100, humidity));
                    
                    // Créer l'objet de données
                    Map<String, Object> donnees = new HashMap<>();
                    donnees.put("rucheId", rucheId);
                    donnees.put("timestamp", timestampMesure.toInstant(java.time.ZoneOffset.UTC).toEpochMilli());
                    donnees.put("temperature", Math.round(temperature * 10.0) / 10.0);
                    donnees.put("humidity", Math.round(humidity * 10.0) / 10.0);
                    donnees.put("batterie", batterie);
                    donnees.put("couvercleOuvert", couvercleOuvert);
                    donnees.put("signalQualite", signalQualite);
                    
                    // Ajouter à Firestore dans la collection donneesCapteurs
                    String docId = firebaseService.addDocument("donneesCapteurs", donnees);
                    
                    Map<String, Object> mesureInfo = new HashMap<>();
                    mesureInfo.put("id", docId);
                    mesureInfo.put("timestamp", timestampMesure.toString());
                    mesureInfo.put("temperature", Math.round(temperature * 10.0) / 10.0);
                    mesureInfo.put("humidity", Math.round(humidity * 10.0) / 10.0);
                    mesureInfo.put("batterie", batterie);
                    
                    mesuresCreees.add(mesureInfo);
                }
            }
            
            // Réponse de succès
            Map<String, Object> response = new HashMap<>();
            response.put("status", "OK");
            response.put("message", "Données de test créées avec succès");
            response.put("rucheId", rucheId);
            response.put("nombreJours", nombreJours);
            response.put("mesuresParJour", mesuresParJour);
            response.put("totalMesures", mesuresCreees.size());
            response.put("premiereMesure", mesuresCreees.isEmpty() ? null : mesuresCreees.get(0));
            response.put("derniereMesure", mesuresCreees.isEmpty() ? null : mesuresCreees.get(mesuresCreees.size() - 1));
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "ERROR");
            errorResponse.put("message", "Erreur lors de la création des données de test");
            errorResponse.put("error", e.getMessage());
            errorResponse.put("timestamp", LocalDateTime.now());
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * Liste les données de test d'une ruche
     */
    @GetMapping("/test-data/{rucheId}")
    public ResponseEntity<?> getTestData(@PathVariable String rucheId) {
        try {
            // Récupérer les documents depuis Realtime Database
            List<Map<String, Object>> documents = firebaseService.getDocuments("donneesCapteurs", "rucheId", rucheId);
            
            List<Map<String, Object>> mesures = new ArrayList<>();
            for (Map<String, Object> doc : documents) {
                Map<String, Object> mesure = new HashMap<>();
                mesure.put("id", doc.get("id"));
                mesure.put("rucheId", doc.get("rucheId"));
                mesure.put("timestamp", doc.get("timestamp"));
                mesure.put("temperature", doc.get("temperature"));
                mesure.put("humidity", doc.get("humidity"));
                mesure.put("batterie", doc.get("batterie"));
                mesure.put("couvercleOuvert", doc.get("couvercleOuvert"));
                mesure.put("signalQualite", doc.get("signalQualite"));
                mesures.add(mesure);
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "OK");
            response.put("rucheId", rucheId);
            response.put("totalMesures", mesures.size());
            response.put("mesures", mesures);
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "ERROR");
            errorResponse.put("message", "Erreur lors de la récupération des données de test");
            errorResponse.put("error", e.getMessage());
            errorResponse.put("timestamp", LocalDateTime.now());
            return ResponseEntity.status(500).body(errorResponse);
        }
    }
} 