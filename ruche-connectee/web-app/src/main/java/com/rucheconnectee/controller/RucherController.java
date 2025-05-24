package com.rucheconnectee.controller;

import com.rucheconnectee.model.Rucher;
import com.rucheconnectee.service.RucherService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.concurrent.ExecutionException;

/**
 * Contrôleur REST pour la gestion des ruchers.
 * Reproduit les fonctionnalités de gestion des ruchers de l'application mobile.
 */
@RestController
@RequestMapping("/api/ruchers")
@CrossOrigin(origins = "*")
public class RucherController {

    @Autowired
    private RucherService rucherService;

    /**
     * Récupère un rucher par son ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<Rucher> getRucher(@PathVariable String id) {
        try {
            Rucher rucher = rucherService.getRucherById(id);
            if (rucher != null) {
                return ResponseEntity.ok(rucher);
            }
            return ResponseEntity.notFound().build();
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Récupère tous les ruchers d'un apiculteur
     */
    @GetMapping("/apiculteur/{apiculteurId}")
    public ResponseEntity<List<Rucher>> getRuchersByApiculteur(@PathVariable String apiculteurId) {
        try {
            List<Rucher> ruchers = rucherService.getRuchersByApiculteur(apiculteurId);
            return ResponseEntity.ok(ruchers);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Crée un nouveau rucher
     */
    @PostMapping
    public ResponseEntity<Rucher> createRucher(@Valid @RequestBody Rucher rucher) {
        try {
            Rucher nouveauRucher = rucherService.createRucher(rucher);
            return ResponseEntity.status(HttpStatus.CREATED).body(nouveauRucher);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Met à jour un rucher
     */
    @PutMapping("/{id}")
    public ResponseEntity<Rucher> updateRucher(@PathVariable String id, @Valid @RequestBody Rucher rucher) {
        try {
            Rucher rucherMisAJour = rucherService.updateRucher(id, rucher);
            return ResponseEntity.ok(rucherMisAJour);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Désactive un rucher
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> desactiverRucher(@PathVariable String id) {
        try {
            rucherService.desactiverRucher(id);
            return ResponseEntity.noContent().build();
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
} 