package com.rucheconnectee.controller;

import com.rucheconnectee.model.CreateRucheRequest;
import com.rucheconnectee.model.RucheResponse;
import com.rucheconnectee.service.RucheService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.concurrent.ExecutionException;

/**
 * Contrôleur REST pour la gestion des ruches via les applications mobiles.
 * API optimisée pour Flutter et React avec validation complète.
 * Désactivé en mode développement sans Firebase.
 */
@RestController
@RequestMapping("/api/mobile/ruches")
@ConditionalOnProperty(name = "firebase.project-id")
@CrossOrigin(origins = "*")
public class RucheMobileController {

    @Autowired
    private RucheService rucheService;

    /**
     * Ajoute une nouvelle ruche avec validation complète
     * POST /api/mobile/ruches
     */
    @PostMapping
    public ResponseEntity<?> ajouterRuche(
            @Valid @RequestBody CreateRucheRequest request,
            @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
        try {
            RucheResponse ruche = rucheService.ajouterRuche(request, apiculteurId);
            return ResponseEntity.status(HttpStatus.CREATED).body(ruche);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("VALIDATION_ERROR", e.getMessage()));
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("SERVER_ERROR", "Erreur interne du serveur"));
        }
    }

    /**
     * Récupère toutes les ruches d'un apiculteur
     * GET /api/mobile/ruches
     */
    @GetMapping
    public ResponseEntity<?> obtenirRuchesUtilisateur(
            @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
        try {
            List<RucheResponse> ruches = rucheService.obtenirRuchesUtilisateur(apiculteurId);
            return ResponseEntity.ok(ruches);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("SERVER_ERROR", "Erreur lors de la récupération des ruches"));
        }
    }

    /**
     * Récupère les ruches d'un rucher spécifique, triées par nom croissant
     * GET /api/mobile/ruches/rucher/{rucherId}
     */
    @GetMapping("/rucher/{rucherId}")
    public ResponseEntity<?> obtenirRuchesParRucher(
            @PathVariable String rucherId,
            @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
        try {
            List<RucheResponse> ruches = rucheService.obtenirRuchesParRucher(rucherId, apiculteurId);
            return ResponseEntity.ok(ruches);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(new ErrorResponse("ACCESS_DENIED", e.getMessage()));
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("SERVER_ERROR", "Erreur lors de la récupération des ruches"));
        }
    }

    /**
     * Récupère une ruche par son ID
     * GET /api/mobile/ruches/{rucheId}
     */
    @GetMapping("/{rucheId}")
    public ResponseEntity<?> obtenirRucheParId(
            @PathVariable String rucheId,
            @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
        try {
            var ruche = rucheService.getRucheById(rucheId);
            if (ruche == null) {
                return ResponseEntity.notFound().build();
            }
            
            // Vérifier que la ruche appartient à l'utilisateur
            if (!ruche.getApiculteurId().equals(apiculteurId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("ACCESS_DENIED", "Accès non autorisé à cette ruche"));
            }

            RucheResponse response = RucheResponse.fromRuche(ruche);
            response.setPositionFromDescription();
            
            return ResponseEntity.ok(response);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("SERVER_ERROR", "Erreur lors de la récupération de la ruche"));
        }
    }

    /**
     * Supprime une ruche (suppression logique)
     * DELETE /api/mobile/ruches/{rucheId}
     */
    @DeleteMapping("/{rucheId}")
    public ResponseEntity<?> supprimerRuche(
            @PathVariable String rucheId,
            @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
        try {
            rucheService.supprimerRuche(rucheId, apiculteurId);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("VALIDATION_ERROR", e.getMessage()));
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("SERVER_ERROR", "Erreur lors de la suppression"));
        }
    }

    /**
     * Met à jour une ruche
     * PUT /api/mobile/ruches/{rucheId}
     */
    @PutMapping("/{rucheId}")
    public ResponseEntity<?> mettreAJourRuche(
            @PathVariable String rucheId,
            @Valid @RequestBody CreateRucheRequest request,
            @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
        try {
            // Vérifier que la ruche existe et appartient à l'utilisateur
            var rucheExistante = rucheService.getRucheById(rucheId);
            if (rucheExistante == null) {
                return ResponseEntity.notFound().build();
            }
            if (!rucheExistante.getApiculteurId().equals(apiculteurId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("ACCESS_DENIED", "Accès non autorisé à cette ruche"));
            }

            // Convertir et mettre à jour
            var rucheUpdate = request.toRuche(apiculteurId);
            var rucheMiseAJour = rucheService.updateRuche(rucheId, rucheUpdate);
            
            RucheResponse response = RucheResponse.fromRuche(rucheMiseAJour);
            response.setPosition(request.getPosition());
            response.setEnService(request.isEnService());
            
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("VALIDATION_ERROR", e.getMessage()));
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("SERVER_ERROR", "Erreur lors de la mise à jour"));
        }
    }

    /**
     * Vérifie la connectivité API (endpoint public)
     * GET /api/mobile/ruches/health
     */
    @GetMapping("/health")
    public ResponseEntity<?> healthCheck() {
        return ResponseEntity.ok(new HealthResponse("OK", "API Ruches fonctionnelle"));
    }

    /**
     * Vérifie la connectivité API avec authentification
     * GET /api/mobile/ruches/health/auth
     */
    @GetMapping("/health/auth")
    public ResponseEntity<?> healthCheckWithAuth(
            @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
        return ResponseEntity.ok(new HealthResponse("OK", "API Ruches fonctionnelle - Utilisateur: " + apiculteurId));
    }

    /**
     * Récupère les mesures des 7 derniers jours d'une ruche
     * GET /api/mobile/ruches/{rucheId}/mesures-7-jours
     */
    @GetMapping("/{rucheId}/mesures-7-jours")
    public ResponseEntity<?> getMesures7DerniersJours(
            @PathVariable String rucheId,
            @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
        try {
            // Vérifier que la ruche existe et appartient à l'utilisateur
            var ruche = rucheService.getRucheById(rucheId);
            if (ruche == null) {
                return ResponseEntity.notFound().build();
            }
            if (!ruche.getApiculteurId().equals(apiculteurId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("ACCESS_DENIED", "Accès non autorisé à cette ruche"));
            }

            // Récupérer les mesures
            var mesures = rucheService.getMesures7DerniersJours(rucheId);
            return ResponseEntity.ok(mesures);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("SERVER_ERROR", "Erreur lors de la récupération des mesures"));
        }
    }

    /**
     * Récupère la dernière mesure d'une ruche
     * GET /api/mobile/ruches/{rucheId}/derniere-mesure
     */
    @GetMapping("/{rucheId}/derniere-mesure")
    public ResponseEntity<?> getDerniereMesure(
            @PathVariable String rucheId,
            @RequestHeader("X-Apiculteur-ID") String apiculteurId) {
        try {
            // Vérifier que la ruche existe et appartient à l'utilisateur
            var ruche = rucheService.getRucheById(rucheId);
            if (ruche == null) {
                return ResponseEntity.notFound().build();
            }
            if (!ruche.getApiculteurId().equals(apiculteurId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("ACCESS_DENIED", "Accès non autorisé à cette ruche"));
            }

            // Récupérer la dernière mesure
            var derniereMesure = rucheService.getDerniereMesure(rucheId);
            if (derniereMesure == null) {
                return ResponseEntity.notFound().build();
            }
            
            return ResponseEntity.ok(derniereMesure);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("SERVER_ERROR", "Erreur lors de la récupération de la dernière mesure"));
        }
    }

    // ==================== CLASSES INTERNES POUR LES RÉPONSES ====================

    /**
     * Classe pour les réponses d'erreur
     */
    public static class ErrorResponse {
        private String code;
        private String message;
        private long timestamp;

        public ErrorResponse(String code, String message) {
            this.code = code;
            this.message = message;
            this.timestamp = System.currentTimeMillis();
        }

        // Getters
        public String getCode() { return code; }
        public String getMessage() { return message; }
        public long getTimestamp() { return timestamp; }
    }

    /**
     * Classe pour les réponses de santé
     */
    public static class HealthResponse {
        private String status;
        private String message;
        private long timestamp;

        public HealthResponse(String status, String message) {
            this.status = status;
            this.message = message;
            this.timestamp = System.currentTimeMillis();
        }

        // Getters
        public String getStatus() { return status; }
        public String getMessage() { return message; }
        public long getTimestamp() { return timestamp; }
    }
} 