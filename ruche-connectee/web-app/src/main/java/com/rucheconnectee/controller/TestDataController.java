package com.rucheconnectee.controller;

import com.rucheconnectee.model.DonneesCapteur;
import com.rucheconnectee.service.MesuresService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * Contrôleur pour créer des données de test
 */
@RestController
@RequestMapping("/dev")
@CrossOrigin(origins = "*", maxAge = 3600)
public class TestDataController {

    @Autowired
    private MesuresService mesuresService;
    
    private final Random random = new Random();

    /**
     * Crée des données de test pour une ruche
     * POST /dev/create-test-data/{rucheId}?nombreJours=7&mesuresParJour=8
     */
    @PostMapping("/create-test-data/{rucheId}")
    public ResponseEntity<?> createTestData(@PathVariable String rucheId,
                                          @RequestParam(defaultValue = "7") int nombreJours,
                                          @RequestParam(defaultValue = "8") int mesuresParJour) {
        try {
            int totalMesures = 0;
            LocalDateTime maintenant = LocalDateTime.now();
            
            for (int jour = nombreJours; jour >= 0; jour--) {
                for (int mesure = 0; mesure < mesuresParJour; mesure++) {
                    LocalDateTime timestamp = maintenant
                            .minusDays(jour)
                            .withHour(6 + (mesure * 2))  // Une mesure toutes les 2h à partir de 6h
                            .withMinute(random.nextInt(60))
                            .withSecond(random.nextInt(60));
                    
                    DonneesCapteur nouvelleMesure = createRandomMesure(timestamp);
                    mesuresService.ajouterMesure(rucheId, nouvelleMesure);
                    totalMesures++;
                }
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "SUCCESS");
            response.put("message", "Données de test créées avec succès");
            response.put("rucheId", rucheId);
            response.put("nombreJours", nombreJours);
            response.put("mesuresParJour", mesuresParJour);
            response.put("totalMesures", totalMesures);
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "ERROR");
            errorResponse.put("message", "Erreur lors de la création des données de test");
            errorResponse.put("error", e.getMessage());
            errorResponse.put("rucheId", rucheId);
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * Crée une mesure aléatoire réaliste
     */
    private DonneesCapteur createRandomMesure(LocalDateTime timestamp) {
        DonneesCapteur mesure = new DonneesCapteur();
        mesure.setTimestamp(timestamp);
        
        // Température réaliste pour une ruche (20-30°C avec variations selon l'heure)
        double tempBase = 25.0;
        int heure = timestamp.getHour();
        if (heure < 8 || heure > 20) {
            tempBase -= 3; // Plus frais la nuit
        } else if (heure >= 12 && heure <= 16) {
            tempBase += 2; // Plus chaud l'après-midi
        }
        mesure.setTemperature(tempBase + (random.nextGaussian() * 2.0));
        
        // Humidité réaliste (50-80%)
        double humiditeBase = 65.0;
        mesure.setHumidity(humiditeBase + (random.nextGaussian() * 8.0));
        
        // Couvercle généralement fermé (95% du temps)
        mesure.setCouvercleOuvert(random.nextDouble() < 0.05);
        
        // Niveau de batterie décroissant lentement
        int batterie = 100 - random.nextInt(30); // Entre 70 et 100%
        mesure.setBatterie(batterie);
        
        // Qualité du signal variable
        int signal = 70 + random.nextInt(30); // Entre 70 et 100%
        mesure.setSignalQualite(signal);
        
        // Pas d'erreur dans 90% des cas
        if (random.nextDouble() < 0.1) {
            String[] erreurs = {"CAPTEUR_TEMP", "CAPTEUR_HUM", "BATTERIE_FAIBLE", "SIGNAL_FAIBLE"};
            mesure.setErreur(erreurs[random.nextInt(erreurs.length)]);
        }
        
        return mesure;
    }

    /**
     * Ajoute une mesure manuelle
     * POST /dev/add-mesure/{rucheId}
     */
    @PostMapping("/add-mesure/{rucheId}")
    public ResponseEntity<?> addManualMesure(@PathVariable String rucheId,
                                           @RequestBody Map<String, Object> mesureData) {
        try {
            DonneesCapteur mesure = new DonneesCapteur();
            mesure.setTimestamp(LocalDateTime.now());
            
            if (mesureData.get("temperature") != null) {
                mesure.setTemperature(((Number) mesureData.get("temperature")).doubleValue());
            }
            
            if (mesureData.get("humidity") != null) {
                mesure.setHumidity(((Number) mesureData.get("humidity")).doubleValue());
            }
            
            if (mesureData.get("couvercleOuvert") != null) {
                mesure.setCouvercleOuvert((Boolean) mesureData.get("couvercleOuvert"));
            }
            
            if (mesureData.get("batterie") != null) {
                mesure.setBatterie(((Number) mesureData.get("batterie")).intValue());
            }
            
            if (mesureData.get("signalQualite") != null) {
                mesure.setSignalQualite(((Number) mesureData.get("signalQualite")).intValue());
            }
            
            DonneesCapteur mesureCreee = mesuresService.ajouterMesure(rucheId, mesure);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "SUCCESS");
            response.put("message", "Mesure ajoutée avec succès");
            response.put("rucheId", rucheId);
            response.put("mesureId", mesureCreee.getId());
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "ERROR");
            errorResponse.put("message", "Erreur lors de l'ajout de la mesure");
            errorResponse.put("error", e.getMessage());
            errorResponse.put("rucheId", rucheId);
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * Endpoint pour tester la structure Firebase en direct
     * GET /dev/test-firebase-structure/{rucheId}
     */
    @GetMapping("/test-firebase-structure/{rucheId}")
    public ResponseEntity<?> testFirebaseStructure(@PathVariable String rucheId) {
        try {
            // Test d'accès à la structure Firebase
            DonneesCapteur derniereMesure = mesuresService.getDerniereMesure(rucheId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "SUCCESS");
            response.put("message", "Test de la structure Firebase");
            response.put("rucheId", rucheId);
            response.put("structure", "ruche/" + rucheId + "/historique");
            response.put("derniereMesure", derniereMesure != null ? "Trouvée" : "Aucune mesure");
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "ERROR");
            errorResponse.put("message", "Erreur lors du test Firebase");
            errorResponse.put("error", e.getMessage());
            errorResponse.put("rucheId", rucheId);
            return ResponseEntity.status(500).body(errorResponse);
        }
    }
}
