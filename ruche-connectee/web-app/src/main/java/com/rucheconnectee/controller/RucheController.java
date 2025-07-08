package com.rucheconnectee.controller;

import com.rucheconnectee.model.Ruche;
import com.rucheconnectee.model.DonneesCapteur;
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
 * Contrôleur REST pour la gestion des ruches.
 * Désactivé en mode développement sans Firebase.
 * Reproduit les fonctionnalités de gestion des ruches de l'application mobile.
 */
@RestController
@RequestMapping("/api/ruches")
@ConditionalOnProperty(name = "firebase.project-id")
@CrossOrigin(origins = "*")
public class RucheController {

    @Autowired
    private RucheService rucheService;

    /**
     * Récupère une ruche par son ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<Ruche> getRuche(@PathVariable String id) {
        try {
            Ruche ruche = rucheService.getRucheById(id);
            if (ruche != null) {
                return ResponseEntity.ok(ruche);
            }
            return ResponseEntity.notFound().build();
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Récupère toutes les ruches d'un apiculteur
     */
    @GetMapping("/apiculteur/{apiculteurId}")
    public ResponseEntity<List<Ruche>> getRuchesByApiculteur(@PathVariable String apiculteurId) {
        try {
            List<Ruche> ruches = rucheService.getRuchesByApiculteur(apiculteurId);
            return ResponseEntity.ok(ruches);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Récupère toutes les ruches d'un rucher
     */
    @GetMapping("/rucher/{rucherId}")
    public ResponseEntity<List<Ruche>> getRuchesByRucher(@PathVariable String rucherId) {
        try {
            List<Ruche> ruches = rucheService.getRuchesByRucher(rucherId);
            return ResponseEntity.ok(ruches);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Crée une nouvelle ruche
     */
    @PostMapping
    public ResponseEntity<Ruche> createRuche(@Valid @RequestBody Ruche ruche) {
        try {
            Ruche nouvelleRuche = rucheService.createRuche(ruche);
            return ResponseEntity.status(HttpStatus.CREATED).body(nouvelleRuche);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Met à jour une ruche
     */
    @PutMapping("/{id}")
    public ResponseEntity<Ruche> updateRuche(@PathVariable String id, @Valid @RequestBody Ruche ruche) {
        try {
            Ruche rucheMiseAJour = rucheService.updateRuche(id, ruche);
            return ResponseEntity.ok(rucheMiseAJour);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Désactive une ruche
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> desactiverRuche(@PathVariable String id) {
        try {
            rucheService.desactiverRuche(id);
            return ResponseEntity.noContent().build();
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Met à jour les données de capteurs d'une ruche (endpoint pour ESP32)
     */
    @PostMapping("/{rucheId}/donnees")
    public ResponseEntity<Void> updateDonneesCapteurs(@PathVariable String rucheId, @RequestBody DonneesCapteur donnees) {
        try {
            donnees.setRucheId(rucheId);
            rucheService.updateDonneesCapteurs(rucheId, donnees);
            return ResponseEntity.ok().build();
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Récupère l'historique des données d'une ruche
     */
    @GetMapping("/{rucheId}/historique")
    public ResponseEntity<List<DonneesCapteur>> getHistoriqueDonnees(
            @PathVariable String rucheId,
            @RequestParam(defaultValue = "100") int limite) {
        try {
            List<DonneesCapteur> historique = rucheService.getHistoriqueDonnees(rucheId, limite);
            return ResponseEntity.ok(historique);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Récupère les mesures des 7 derniers jours d'une ruche
     */
    @GetMapping("/{rucheId}/mesures-7-jours")
    public ResponseEntity<List<DonneesCapteur>> getMesures7DerniersJours(@PathVariable String rucheId) {
        try {
            List<DonneesCapteur> mesures = rucheService.getMesures7DerniersJours(rucheId);
            return ResponseEntity.ok(mesures);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Vérifie les alertes d'une ruche
     */
    @GetMapping("/{id}/alertes")
    public ResponseEntity<Boolean> verifierAlertes(@PathVariable String id) {
        try {
            Ruche ruche = rucheService.getRucheById(id);
            if (ruche != null) {
                boolean hasAlertes = rucheService.verifierAlertes(ruche);
                return ResponseEntity.ok(hasAlertes);
            }
            return ResponseEntity.notFound().build();
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
} 