package com.rucheconnectee.controller;

import com.rucheconnectee.model.DonneesCapteur;
import com.rucheconnectee.service.MesuresService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Contrôleur API mobile pour l'application Flutter
 */
@RestController
@RequestMapping("/api/mobile")
public class MobileController {

    @Autowired
    private MesuresService mesuresService;

    /**
     * Récupération des ruches pour l'application mobile
     */
    @GetMapping("/ruches")
    public ResponseEntity<List<Map<String, Object>>> getRuches(
            @RequestHeader(value = "X-Apiculteur-ID", required = false) String apiculteurId) {
        
        List<Map<String, Object>> ruches = new ArrayList<>();
        String userId = apiculteurId != null ? apiculteurId : "mock-user-1";
        
        ruches.add(createMockRuche("R001", "Ruche 1 - Jardin", userId, "RU001", true, 25.5, 65.0, 35.2, 1));
        ruches.add(createMockRuche("R002", "Ruche 2 - Verger", userId, "RU001", true, 26.1, 62.5, 33.8, 2));
        ruches.add(createMockRuche("R003", "Ruche 3 - Prairie", userId, "RU002", false, 22.0, 58.0, 30.5, 3));
        
        return ResponseEntity.ok(ruches);
    }

    /**
     * Récupération des détails d'une ruche
     */
    @GetMapping("/ruches/{id}")
    public ResponseEntity<Map<String, Object>> getRucheDetails(@PathVariable String id) {
        Map<String, Object> ruche = switch (id) {
            case "R001" -> createMockRucheDetails("R001", "Ruche 1 - Jardin", 
                    "Ruche principale située dans le jardin", 25.5, 65.0, 35.2, true);
            case "R002" -> createMockRucheDetails("R002", "Ruche 2 - Verger", 
                    "Ruche située près des arbres fruitiers", 26.1, 62.5, 33.8, true);
            case "R003" -> createMockRucheDetails("R003", "Ruche 3 - Prairie", 
                    "Ruche en prairie (actuellement inactive)", 22.0, 58.0, 30.5, false);
            default -> null;
        };
        
        return ruche != null ? ResponseEntity.ok(ruche) : ResponseEntity.notFound().build();
    }

    /**
     * Récupération des ruchers
     */
    @GetMapping("/ruchers")
    public ResponseEntity<List<Map<String, Object>>> getRuchers() {
        List<Map<String, Object>> ruchers = new ArrayList<>();
        ruchers.add(createMockRucher("RU001", "Rucher Principal", "48.8566,2.3522"));
        ruchers.add(createMockRucher("RU002", "Rucher Secondaire", "48.8534,2.3488"));
        return ResponseEntity.ok(ruchers);
    }

    /**
     * Health check pour l'API mobile
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> health = Map.of(
                "status", "OK",
                "message", "API Mobile BeeTrack opérationnelle",
                "timestamp", System.currentTimeMillis(),
                "mode", "development"
        );
        return ResponseEntity.ok(health);
    }

    /**
     * API mobile - Récupère la dernière mesure avec authentification
     * GET /api/mobile/ruches/{rucheId}/derniere-mesure
     */
    @GetMapping("/ruches/{rucheId}/derniere-mesure")
    public ResponseEntity<?> getDerniereMesureMobile(@PathVariable String rucheId,
                                                   @RequestHeader(value = "X-Apiculteur-ID", required = false) String apiculteurId) {
        try {
            // TODO: Vérifier que l'apiculteur a accès à cette ruche
            
            DonneesCapteur derniereMesure = mesuresService.getDerniereMesure(rucheId);
            
            if (derniereMesure == null) {
                return ResponseEntity.status(404).body(Map.of(
                    "status", "NOT_FOUND",
                    "message", "Aucune mesure trouvée",
                    "rucheId", rucheId
                ));
            }
            
            // Format simplifié pour le mobile
            Map<String, Object> response = new HashMap<>();
            response.put("id", derniereMesure.getId());
            response.put("rucheId", rucheId);
            response.put("timestamp", derniereMesure.getTimestamp().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
            response.put("temperature", derniereMesure.getTemperature());
            response.put("humidity", derniereMesure.getHumidity());
            response.put("couvercleOuvert", derniereMesure.getCouvercleOuvert());
            response.put("batterie", derniereMesure.getBatterie());
            response.put("signalQualite", derniereMesure.getSignalQualite());
            response.put("erreur", derniereMesure.getErreur());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of(
                "status", "ERROR",
                "message", "Erreur interne du serveur",
                "error", e.getMessage()
            ));
        }
    }

    // --- Méthodes utilitaires ---

    private Map<String, Object> createMockRuche(String id, String nom, String apiculteurId, 
                                                 String rucherId, boolean actif, double temperature, 
                                                 double humidite, double poids, int dayOffset) {
        Map<String, Object> ruche = new HashMap<>();
        ruche.put("id", id);
        ruche.put("nom", nom);
        ruche.put("apiculteurId", apiculteurId);
        ruche.put("rucherId", rucherId);
        ruche.put("actif", actif);
        ruche.put("temperature", temperature);
        ruche.put("humidite", humidite);
        ruche.put("poids", poids);
        ruche.put("derniereSync", System.currentTimeMillis());
        ruche.put("createdAt", System.currentTimeMillis() - (dayOffset * 86400000L)); // dayOffset jours
        return ruche;
    }

    private Map<String, Object> createMockRucheDetails(String id, String nom, String description,
                                                       double temperature, double humidite, 
                                                       double poids, boolean actif) {
        Map<String, Object> ruche = new HashMap<>();
        ruche.put("id", id);
        ruche.put("nom", nom);
        ruche.put("description", description);
        ruche.put("temperature", temperature);
        ruche.put("humidite", humidite);
        ruche.put("poids", poids);
        ruche.put("actif", actif);
        ruche.put("derniereSync", System.currentTimeMillis());
        return ruche;
    }

    private Map<String, Object> createMockRucher(String id, String nom, String coordonnees) {
        Map<String, Object> rucher = new HashMap<>();
        rucher.put("id", id);
        rucher.put("nom", nom);
        rucher.put("coordonnees", coordonnees);
        rucher.put("actif", true);
        return rucher;
    }
}