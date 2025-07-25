package com.rucheconnectee.controller;

import com.rucheconnectee.service.FirebaseRealtimeListenerService;
import com.rucheconnectee.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Contrôleur pour la gestion des alertes en temps réel
 */
@RestController
@RequestMapping("/api/alertes")
public class AlerteController {

    @Autowired
    private FirebaseRealtimeListenerService listenerService;

    @Autowired
    private NotificationService notificationService;

    /**
     * Test d'envoi d'alerte manuelle
     */
    @PostMapping("/test")
    public ResponseEntity<?> testerAlerte(
            @RequestBody Map<String, Object> request,
            Authentication authentication) {
        
        try {
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
            }

            String rucheId = (String) request.get("rucheId");
            if (rucheId == null) {
                return ResponseEntity.badRequest().body(Map.of("error", "rucheId requis"));
            }

            // Créer une mesure de test
            Map<String, Object> mesureTest = new HashMap<>();
            mesureTest.put("rucheId", rucheId);
            mesureTest.put("couvercleOuvert", true);
            mesureTest.put("temperature", 25.5);
            mesureTest.put("humidite", 65.0);
            mesureTest.put("timestamp", java.time.LocalDateTime.now().toString());

            // Déclencher l'alerte
            notificationService.envoyerAlerteCouvercleOuvert(rucheId, mesureTest);

            return ResponseEntity.ok(Map.of(
                "message", "Test d'alerte envoyé avec succès",
                "rucheId", rucheId,
                "timestamp", mesureTest.get("timestamp")
            ));

        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Obtient le statut des surveillances
     */
    @GetMapping("/statut")
    public ResponseEntity<?> obtenirStatutSurveillance(Authentication authentication) {
        try {
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
            }

            Map<String, Object> statut = new HashMap<>();
            statut.put("surveillanceActive", listenerService.obtenirNombreRuchesSurveillees() > 0);
            statut.put("nombreRuchesSurveillees", listenerService.obtenirNombreRuchesSurveillees());
            statut.put("ruchesSurveillees", listenerService.obtenirRuchesSurveillees());

            return ResponseEntity.ok(statut);

        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Démarre la surveillance d'une ruche spécifique
     */
    @PostMapping("/surveillance/{rucheId}/demarrer")
    public ResponseEntity<?> demarrerSurveillanceRuche(
            @PathVariable String rucheId,
            Authentication authentication) {
        
        try {
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
            }

            listenerService.demarrerSurveillanceRuche(rucheId);

            return ResponseEntity.ok(Map.of(
                "message", "Surveillance démarrée pour la ruche",
                "rucheId", rucheId
            ));

        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Arrête la surveillance d'une ruche spécifique
     */
    @PostMapping("/surveillance/{rucheId}/arreter")
    public ResponseEntity<?> arreterSurveillanceRuche(
            @PathVariable String rucheId,
            Authentication authentication) {
        
        try {
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
            }

            listenerService.arreterSurveillanceRuche(rucheId);

            return ResponseEntity.ok(Map.of(
                "message", "Surveillance arrêtée pour la ruche",
                "rucheId", rucheId
            ));

        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Obtient le statut d'inhibition pour une ruche
     */
    @GetMapping("/inhibition/{rucheId}")
    public ResponseEntity<?> obtenirStatutInhibition(
            @PathVariable String rucheId,
            Authentication authentication) {
        
        try {
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
            }

            Map<String, Object> statut = notificationService.obtenirStatutInhibition(rucheId);
            return ResponseEntity.ok(statut);

        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * Obtient toutes les inhibitions actives
     */
    @GetMapping("/inhibition/actives")
    public ResponseEntity<?> obtenirInhibitionsActives(Authentication authentication) {
        try {
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
            }

            Map<String, Object> inhibitions = new HashMap<>();
            notificationService.obtenirInhibitionsActives().forEach((rucheId, info) -> {
                inhibitions.put(rucheId, Map.of(
                    "finInhibition", info.finInhibition.toString(),
                    "dureeHeures", info.dureeHeures
                ));
            });

            return ResponseEntity.ok(inhibitions);

        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }
} 