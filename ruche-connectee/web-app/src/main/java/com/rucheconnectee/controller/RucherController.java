package com.rucheconnectee.controller;

import com.rucheconnectee.model.Rucher;
import com.rucheconnectee.service.RucherService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

/**
 * Contrôleur REST pour la gestion des ruchers.
 * Désactivé en mode développement sans Firebase.
 */
@RestController
@RequestMapping("/api/ruchers")
@ConditionalOnProperty(name = "firebase.project-id")
@CrossOrigin(origins = "*")
public class RucherController {

    @Autowired
    private RucherService rucherService;

    /**
     * Récupère un rucher par son ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<Rucher> getRucher(@PathVariable String id) throws Exception {
        Rucher rucher = rucherService.getRucherById(id);
        if (rucher != null) {
            return ResponseEntity.ok(rucher);
        }
        return ResponseEntity.notFound().build();
    }

    /**
     * Récupère tous les ruchers d'un apiculteur
     */
    @GetMapping("/apiculteur/{apiculteurId}")
    public ResponseEntity<List<Rucher>> getRuchersByApiculteur(@PathVariable String apiculteurId) throws Exception {
        List<Rucher> ruchers = rucherService.getRuchersByApiculteur(apiculteurId);
        return ResponseEntity.ok(ruchers);
    }

    /**
     * Crée un nouveau rucher
     */
    @PostMapping
    public ResponseEntity<Rucher> createRucher(@Valid @RequestBody Rucher rucher) throws Exception {
        Rucher nouveauRucher = rucherService.createRucher(rucher);
        return ResponseEntity.status(HttpStatus.CREATED).body(nouveauRucher);
    }

    /**
     * Met à jour un rucher
     */
    @PutMapping("/{id}")
    public ResponseEntity<Rucher> updateRucher(@PathVariable String id, @Valid @RequestBody Rucher rucher) throws Exception {
        Rucher rucherMisAJour = rucherService.updateRucher(id, rucher);
        return ResponseEntity.ok(rucherMisAJour);
    }

    /**
     * Désactive un rucher
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> desactiverRucher(@PathVariable String id) throws Exception {
        rucherService.desactiverRucher(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * Endpoint spécifique pour l'application mobile Flutter
     * Crée un rucher avec le format mobile (idApiculteur, dateCreation)
     */
    @PostMapping("/mobile")
    public ResponseEntity<?> createRucherMobile(@RequestBody java.util.Map<String, Object> rucherData) throws Exception {
        // Validation des champs requis
        if (!rucherData.containsKey("nom") || !rucherData.containsKey("adresse") || 
            !rucherData.containsKey("description") || !rucherData.containsKey("idApiculteur")) {
            return ResponseEntity.badRequest().body("Champs requis manquants: nom, adresse, description, idApiculteur");
        }

        // Créer l'objet Rucher
        Rucher rucher = new Rucher();
        rucher.setNom((String) rucherData.get("nom"));
        rucher.setAdresse((String) rucherData.get("adresse"));
        rucher.setDescription((String) rucherData.get("description"));
        rucher.setApiculteurId((String) rucherData.get("idApiculteur"));

        // Créer le rucher
        Rucher nouveauRucher = rucherService.createRucher(rucher);

        // Retourner la réponse au format mobile
        java.util.Map<String, Object> response = new java.util.HashMap<>();
        response.put("id", nouveauRucher.getId());
        response.put("nom", nouveauRucher.getNom());
        response.put("adresse", nouveauRucher.getAdresse());
        response.put("description", nouveauRucher.getDescription());
        response.put("idApiculteur", nouveauRucher.getApiculteurId());
        response.put("dateCreation", nouveauRucher.getDateCreation());
        response.put("nombreRuches", nouveauRucher.getNombreRuches());
        response.put("actif", nouveauRucher.isActif());

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * Endpoint pour récupérer les ruchers au format mobile
     */
    @GetMapping("/mobile/apiculteur/{apiculteurId}")
    public ResponseEntity<java.util.List<java.util.Map<String, Object>>> getRuchersMobile(@PathVariable String apiculteurId) throws Exception {
        List<Rucher> ruchers = rucherService.getRuchersByApiculteur(apiculteurId);
        
        // Convertir au format mobile
        java.util.List<java.util.Map<String, Object>> ruchersMobile = ruchers.stream()
                .map(rucher -> {
                    java.util.Map<String, Object> rucherMap = new java.util.HashMap<>();
                    rucherMap.put("id", rucher.getId());
                    rucherMap.put("nom", rucher.getNom());
                    rucherMap.put("adresse", rucher.getAdresse());
                    rucherMap.put("description", rucher.getDescription());
                    rucherMap.put("idApiculteur", rucher.getApiculteurId());
                    rucherMap.put("dateCreation", rucher.getDateCreation());
                    rucherMap.put("nombreRuches", rucher.getNombreRuches());
                    rucherMap.put("actif", rucher.isActif());
                    return rucherMap;
                })
                .collect(java.util.stream.Collectors.toList());

        return ResponseEntity.ok(ruchersMobile);
    }
} 