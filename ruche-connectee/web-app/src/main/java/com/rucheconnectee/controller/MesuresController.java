package com.rucheconnectee.controller;

import com.rucheconnectee.model.DonneesCapteur;
import com.rucheconnectee.service.AuthorizationService;
import com.rucheconnectee.service.MesuresService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Contrôleur REST pour la gestion des mesures des capteurs IoT
 */
@RestController
@RequestMapping("/api/mesures")
@CrossOrigin(origins = "*", maxAge = 3600)
public class MesuresController {

    @Autowired
    private MesuresService mesuresService;

    @Autowired
    private AuthorizationService authorizationService;

    /**
     * Récupère la dernière mesure d'une ruche
     * GET /api/mesures/ruche/{rucheId}/derniere
     */
    @GetMapping("/ruche/{rucheId}/derniere")
    public ResponseEntity<?> getDerniereMesure(@PathVariable String rucheId) {
        try {
            DonneesCapteur derniereMesure = mesuresService.getDerniereMesure(rucheId);
            
            if (derniereMesure == null) {
                Map<String, Object> response = new HashMap<>();
                response.put("status", "NOT_FOUND");
                response.put("message", "Aucune mesure trouvée pour la ruche " + rucheId);
                response.put("rucheId", rucheId);
                return ResponseEntity.status(404).body(response);
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "OK");
            response.put("rucheId", rucheId);
            response.put("mesure", convertToMap(derniereMesure));
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "ERROR");
            errorResponse.put("message", "Erreur lors de la récupération de la dernière mesure");
            errorResponse.put("error", e.getMessage());
            errorResponse.put("rucheId", rucheId);
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * Récupère toutes les mesures d'une ruche
     * GET /api/mesures/ruche/{rucheId}
     */
    @GetMapping("/ruche/{rucheId}")
    public ResponseEntity<?> getMesuresRuche(@PathVariable String rucheId,
                                           @RequestParam(defaultValue = "100") int limit) {
        try {
            List<DonneesCapteur> mesures = mesuresService.getMesuresRuche(rucheId);
            
            // Limiter le nombre de résultats
            if (mesures.size() > limit) {
                mesures = mesures.subList(0, limit);
            }
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "OK");
            response.put("rucheId", rucheId);
            response.put("nombreMesures", mesures.size());
            response.put("mesures", mesures.stream().map(this::convertToMap).toList());
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "ERROR");
            errorResponse.put("message", "Erreur lors de la récupération des mesures");
            errorResponse.put("error", e.getMessage());
            errorResponse.put("rucheId", rucheId);
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * Récupère les mesures récentes d'une ruche
     * GET /api/mesures/ruche/{rucheId}/recentes?heures=24
     */
    @GetMapping("/ruche/{rucheId}/recentes")
    public ResponseEntity<?> getMesuresRecentes(@PathVariable String rucheId,
                                              @RequestParam(defaultValue = "24") int heures) {
        try {
            List<DonneesCapteur> mesures = mesuresService.getMesuresRecentes(rucheId, heures);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "OK");
            response.put("rucheId", rucheId);
            response.put("periode", heures + " heures");
            response.put("nombreMesures", mesures.size());
            response.put("mesures", mesures.stream().map(this::convertToMap).toList());
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "ERROR");
            errorResponse.put("message", "Erreur lors de la récupération des mesures récentes");
            errorResponse.put("error", e.getMessage());
            errorResponse.put("rucheId", rucheId);
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * Récupère les statistiques des mesures d'une ruche
     * GET /api/mesures/ruche/{rucheId}/statistiques?jours=7
     */
    @GetMapping("/ruche/{rucheId}/statistiques")
    public ResponseEntity<?> getStatistiquesMesures(@PathVariable String rucheId,
                                                   @RequestParam(defaultValue = "7") int jours) {
        try {
            Map<String, Object> statistiques = mesuresService.getStatistiquesMesures(rucheId, jours);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "OK");
            response.put("rucheId", rucheId);
            response.put("periode", jours + " jours");
            response.put("statistiques", statistiques);
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "ERROR");
            errorResponse.put("message", "Erreur lors du calcul des statistiques");
            errorResponse.put("error", e.getMessage());
            errorResponse.put("rucheId", rucheId);
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    /**
     * Ajoute une nouvelle mesure pour une ruche
     * POST /api/mesures/ruche/{rucheId}
     */
    @PostMapping("/ruche/{rucheId}")
    public ResponseEntity<?> ajouterMesure(@PathVariable String rucheId,
                                         @RequestBody Map<String, Object> mesureData) {
        try {
            DonneesCapteur nouvelleMesure = convertFromMap(mesureData, rucheId);
            DonneesCapteur mesureCreee = mesuresService.ajouterMesure(rucheId, nouvelleMesure);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "CREATED");
            response.put("message", "Mesure ajoutée avec succès");
            response.put("rucheId", rucheId);
            response.put("mesure", convertToMap(mesureCreee));
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.status(201).body(response);
            
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
     * API mobile - Récupère la dernière mesure avec authentification
     * GET /api/mobile/ruches/{rucheId}/derniere-mesure
     */
    @GetMapping("/mobile/ruches/{rucheId}/derniere-mesure")
    public ResponseEntity<?> getDerniereMesureMobile(@PathVariable String rucheId,
                                                   @RequestHeader(value = "X-Apiculteur-ID", required = false) String apiculteurId) {
        try {
            // Vérifier que l'apiculteur a accès à cette ruche
            if (apiculteurId != null && !authorizationService.hasAccessToRuche(apiculteurId, rucheId)) {
                return ResponseEntity.status(403).body(Map.of(
                    "status", "FORBIDDEN",
                    "message", "Accès refusé à cette ruche",
                    "rucheId", rucheId
                ));
            }
            
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

    /**
     * Endpoint de test pour les mesures
     * GET /test/derniere-mesure/{rucheId}
     */
    @GetMapping("/test/derniere-mesure/{rucheId}")
    public ResponseEntity<?> testDerniereMesure(@PathVariable String rucheId) {
        try {
            DonneesCapteur derniereMesure = mesuresService.getDerniereMesure(rucheId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "OK");
            response.put("rucheId", rucheId);
            response.put("message", derniereMesure != null ? "Dernière mesure trouvée" : "Aucune mesure trouvée");
            response.put("derniereMesure", derniereMesure != null ? convertToMap(derniereMesure) : null);
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "ERROR");
            errorResponse.put("message", "Erreur lors du test");
            errorResponse.put("error", e.getMessage());
            errorResponse.put("rucheId", rucheId);
            return ResponseEntity.status(500).body(errorResponse);
        }
    }

    // --- Méthodes utilitaires ---

    private Map<String, Object> convertToMap(DonneesCapteur mesure) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", mesure.getId());
        map.put("rucheId", mesure.getRucheId());
        map.put("timestamp", mesure.getTimestamp().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        map.put("temperature", mesure.getTemperature());
        map.put("humidity", mesure.getHumidity());
        map.put("couvercleOuvert", mesure.getCouvercleOuvert());
        map.put("batterie", mesure.getBatterie());
        map.put("signalQualite", mesure.getSignalQualite());
        map.put("erreur", mesure.getErreur());
        return map;
    }

    private DonneesCapteur convertFromMap(Map<String, Object> data, String rucheId) {
        DonneesCapteur mesure = new DonneesCapteur();
        mesure.setRucheId(rucheId);
        
        if (data.get("timestamp") != null) {
            mesure.setTimestamp(LocalDateTime.parse((String) data.get("timestamp")));
        } else {
            mesure.setTimestamp(LocalDateTime.now());
        }
        
        if (data.get("temperature") != null) {
            mesure.setTemperature(((Number) data.get("temperature")).doubleValue());
        }
        
        if (data.get("humidity") != null) {
            mesure.setHumidity(((Number) data.get("humidity")).doubleValue());
        }
        
        if (data.get("couvercleOuvert") != null) {
            mesure.setCouvercleOuvert((Boolean) data.get("couvercleOuvert"));
        }
        
        if (data.get("batterie") != null) {
            mesure.setBatterie(((Number) data.get("batterie")).intValue());
        }
        
        if (data.get("signalQualite") != null) {
            mesure.setSignalQualite(((Number) data.get("signalQualite")).intValue());
        }
        
        if (data.get("erreur") != null) {
            mesure.setErreur((String) data.get("erreur"));
        }
        
        return mesure;
    }
}
