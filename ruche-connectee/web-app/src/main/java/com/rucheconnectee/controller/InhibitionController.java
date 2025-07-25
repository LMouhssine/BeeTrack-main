package com.rucheconnectee.controller;

import com.rucheconnectee.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Contrôleur pour la gestion des inhibitions temporaires des alertes
 */
@RestController
@RequestMapping("/api/inhibitions")
@ConditionalOnProperty(name = "firebase.project-id")
public class InhibitionController {

    @Autowired
    private NotificationService notificationService;

    /**
     * Active une inhibition temporaire pour une ruche
     */
    @PostMapping("/{rucheId}/activer")
    public ResponseEntity<?> activerInhibition(
            @PathVariable String rucheId,
            @RequestBody Map<String, Object> request,
            Authentication authentication) {
        
        try {
            // Vérifier l'authentification
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
            }

            // Récupérer la durée d'inhibition
            Integer dureeHeures = (Integer) request.get("dureeHeures");
            if (dureeHeures == null || dureeHeures <= 0) {
                return ResponseEntity.badRequest().body(Map.of("error", "Durée d'inhibition invalide"));
            }

            // Activer l'inhibition
            notificationService.activerInhibition(rucheId, dureeHeures);

            return ResponseEntity.ok(Map.of(
                "message", "Inhibition activée avec succès",
                "rucheId", rucheId,
                "dureeHeures", dureeHeures
            ));

        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Erreur lors de l'activation: " + e.getMessage()));
        }
    }

    /**
     * Désactive l'inhibition pour une ruche
     */
    @PostMapping("/{rucheId}/desactiver")
    public ResponseEntity<?> desactiverInhibition(
            @PathVariable String rucheId,
            Authentication authentication) {
        
        try {
            // Vérifier l'authentification
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
            }

            // Désactiver l'inhibition
            notificationService.desactiverInhibition(rucheId);

            return ResponseEntity.ok(Map.of(
                "message", "Inhibition désactivée avec succès",
                "rucheId", rucheId
            ));

        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Erreur lors de la désactivation: " + e.getMessage()));
        }
    }

    /**
     * Obtient le statut d'inhibition pour une ruche
     */
    @GetMapping("/{rucheId}/statut")
    public ResponseEntity<?> obtenirStatutInhibition(
            @PathVariable String rucheId,
            Authentication authentication) {
        
        try {
            // Vérifier l'authentification
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
            }

            // Obtenir le statut
            Map<String, Object> statut = notificationService.obtenirStatutInhibition(rucheId);

            return ResponseEntity.ok(Map.of(
                "rucheId", rucheId,
                "statut", statut
            ));

        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Erreur lors de la récupération: " + e.getMessage()));
        }
    }

    /**
     * Obtient toutes les inhibitions actives
     */
    @GetMapping("/actives")
    public ResponseEntity<?> obtenirInhibitionsActives(Authentication authentication) {
        try {
            // Vérifier l'authentification
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
            }

            // Obtenir toutes les inhibitions actives
            Map<String, ?> inhibitions = notificationService.obtenirInhibitionsActives();

            return ResponseEntity.ok(Map.of(
                "inhibitions", inhibitions,
                "nombre", inhibitions.size()
            ));

        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Erreur lors de la récupération: " + e.getMessage()));
        }
    }

    /**
     * Nettoie les inhibitions expirées
     */
    @PostMapping("/nettoyer")
    public ResponseEntity<?> nettoyerInhibitionsExpirees(Authentication authentication) {
        try {
            // Vérifier l'authentification
            if (authentication == null || !authentication.isAuthenticated()) {
                return ResponseEntity.status(401).body(Map.of("error", "Non authentifié"));
            }

            // Nettoyer les inhibitions expirées
            notificationService.nettoyerInhibitionsExpirees();

            return ResponseEntity.ok(Map.of(
                "message", "Nettoyage des inhibitions expirées effectué"
            ));

        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", "Erreur lors du nettoyage: " + e.getMessage()));
        }
    }
} 