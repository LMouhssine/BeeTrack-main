package com.rucheconnectee.controller;

import com.rucheconnectee.model.DonneesCapteur;
import com.rucheconnectee.service.RucheService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeoutException;

/**
 * Contrôleur de test pour vérifier les services.
 * Désactivé en mode développement sans Firebase.
 */
@RestController
@RequestMapping("/api/test")
@ConditionalOnProperty(name = "firebase.project-id")
@CrossOrigin(origins = "*")
public class TestController {

    @Autowired
    private RucheService rucheService;

    /**
     * Test de la fonctionnalité de récupération des mesures des 7 derniers jours
     */
    @GetMapping("/ruche/{rucheId}/mesures-7-jours")
    public ResponseEntity<?> testMesures7DerniersJours(@PathVariable String rucheId) {
        try {
            // Récupérer les mesures
            List<DonneesCapteur> mesures = rucheService.getMesures7DerniersJours(rucheId);
            
            // Créer une réponse détaillée pour le test
            Map<String, Object> response = new HashMap<>();
            response.put("rucheId", rucheId);
            response.put("dateLimite", LocalDateTime.now().minusDays(7).format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            response.put("nombreMesures", mesures.size());
            response.put("mesures", mesures);
            
            // Statistiques supplémentaires
            if (!mesures.isEmpty()) {
                DonneesCapteur premiere = mesures.get(0);
                DonneesCapteur derniere = mesures.get(mesures.size() - 1);
                
                Map<String, Object> stats = new HashMap<>();
                stats.put("premiereMesure", premiere.getTimestamp());
                stats.put("derniereMesure", derniere.getTimestamp());
                stats.put("temperatureMin", mesures.stream()
                    .filter(m -> m.getTemperature() != null)
                    .mapToDouble(DonneesCapteur::getTemperature)
                    .min().orElse(0.0));
                stats.put("temperatureMax", mesures.stream()
                    .filter(m -> m.getTemperature() != null)
                    .mapToDouble(DonneesCapteur::getTemperature)
                    .max().orElse(0.0));
                stats.put("temperatureMoyenne", mesures.stream()
                    .filter(m -> m.getTemperature() != null)
                    .mapToDouble(DonneesCapteur::getTemperature)
                    .average().orElse(0.0));
                
                response.put("statistiques", stats);
            }
            
            return ResponseEntity.ok(response);
        } catch (ExecutionException | InterruptedException | TimeoutException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("erreur", "Erreur lors de la récupération des mesures");
            errorResponse.put("message", e.getMessage());
            errorResponse.put("timestamp", LocalDateTime.now());
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * Endpoint pour tester la connectivité générale
     */
    @GetMapping("/health")
    public ResponseEntity<?> healthCheck() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "OK");
        response.put("message", "Contrôleur de test fonctionnel");
        response.put("timestamp", LocalDateTime.now());
        response.put("features", List.of("mesures-7-jours"));
        return ResponseEntity.ok(response);
    }

    /**
     * Crée des données de test pour une ruche
     */
    @PostMapping("/ruche/{rucheId}/creer-donnees-test")
    public ResponseEntity<?> creerDonneesTest(
            @PathVariable String rucheId,
            @RequestParam(defaultValue = "10") int nombreJours,
            @RequestParam(defaultValue = "8") int mesuresParJour) {
        try {
            int mesuresCreees = rucheService.creerDonneesTest(rucheId, nombreJours, mesuresParJour);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "OK");
            response.put("rucheId", rucheId);
            response.put("nombreJours", nombreJours);
            response.put("mesuresParJour", mesuresParJour);
            response.put("mesuresCreees", mesuresCreees);
            response.put("message", "Données de test créées avec succès");
            response.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(response);
        } catch (ExecutionException | InterruptedException | TimeoutException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("erreur", "Erreur lors de la création des données de test");
            errorResponse.put("message", e.getMessage());
            errorResponse.put("timestamp", LocalDateTime.now());
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * Test de récupération de la dernière mesure d'une ruche
     * GET /test/derniere-mesure/{rucheId}
     */
    @GetMapping("/derniere-mesure/{rucheId}")
    public ResponseEntity<?> testDerniereMesure(@PathVariable String rucheId) {
        try {
            var derniereMesure = rucheService.getDerniereMesure(rucheId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "OK");
            response.put("rucheId", rucheId);
            response.put("derniereMesure", derniereMesure);
            response.put("message", derniereMesure != null ? 
                "Dernière mesure trouvée" : "Aucune mesure trouvée pour cette ruche");
            
            return ResponseEntity.ok(response);
            
        } catch (ExecutionException | InterruptedException | TimeoutException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "ERROR");
            errorResponse.put("message", "Erreur lors de la récupération de la dernière mesure");
            errorResponse.put("error", e.getMessage());
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * Test de récupération des mesures des 7 derniers jours
     * GET /test/mesures-7-jours/{rucheId}
     */
    @GetMapping("/mesures-7-jours/{rucheId}")
    public ResponseEntity<?> testMesures7Jours(@PathVariable String rucheId) {
        try {
            var mesures = rucheService.getMesures7DerniersJours(rucheId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "OK");
            response.put("rucheId", rucheId);
            response.put("nombreMesures", mesures.size());
            response.put("mesures", mesures);
            response.put("message", mesures.size() + " mesures trouvées pour les 7 derniers jours");
            
            return ResponseEntity.ok(response);
            
        } catch (ExecutionException | InterruptedException | TimeoutException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "ERROR");
            errorResponse.put("message", "Erreur lors de la récupération des mesures");
            errorResponse.put("error", e.getMessage());
            return ResponseEntity.status(500).body(errorResponse);
        }
    }
} 