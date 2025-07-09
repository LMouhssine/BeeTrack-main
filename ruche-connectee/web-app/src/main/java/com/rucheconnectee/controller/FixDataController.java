package com.rucheconnectee.controller;

import com.rucheconnectee.service.FirebaseService;
import com.rucheconnectee.service.ApiculteurService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * Contrôleur utilitaire pour corriger les associations de données Firebase
 */
@RestController
@RequestMapping("/fix")
@ConditionalOnProperty(name = "firebase.project-id")
public class FixDataController {

    @Autowired(required = false)
    private FirebaseService firebaseService;
    
    @Autowired(required = false)
    private ApiculteurService apiculteurService;

    @GetMapping("/associate-ruches")
    public ResponseEntity<Map<String, Object>> associateRuches() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            if (firebaseService == null) {
                result.put("status", "ERROR");
                result.put("message", "FirebaseService non disponible");
                return ResponseEntity.status(500).body(result);
            }

            // Récupérer l'apiculteur jean.dupont@email.com
            var apiculteur = apiculteurService.getApiculteurByEmail("jean.dupont@email.com");
            
            if (apiculteur == null) {
                result.put("status", "ERROR");
                result.put("message", "Apiculteur jean.dupont@email.com non trouvé");
                return ResponseEntity.status(404).body(result);
            }

            String apiculteurId = apiculteur.getId();
            result.put("apiculteur_id", apiculteurId);

            // Récupérer toutes les ruches
            var allRuches = firebaseService.getAllDocuments("ruches");
            result.put("total_ruches_found", allRuches.size());

            int ruchesAssociated = 0;
            for (var rucheDoc : allRuches) {
                String currentApiculteurId = (String) rucheDoc.getData().get("apiculteur_id");
                
                if (currentApiculteurId == null || currentApiculteurId.isEmpty()) {
                    // Associer cette ruche à jean.dupont@email.com
                    Map<String, Object> updates = new HashMap<>();
                    updates.put("apiculteur_id", apiculteurId);
                    
                    firebaseService.updateDocument("ruches", rucheDoc.getId(), updates);
                    ruchesAssociated++;
                    
                    result.put("ruche_" + ruchesAssociated + "_id", rucheDoc.getId());
                    result.put("ruche_" + ruchesAssociated + "_nom", rucheDoc.getData().get("nom"));
                }
            }

            result.put("ruches_associated", ruchesAssociated);
            result.put("status", "SUCCESS");
            result.put("message", ruchesAssociated + " ruches associées à jean.dupont@email.com");
            
        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", "Erreur lors de l'association: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body(result);
        }

        return ResponseEntity.ok(result);
    }

    @GetMapping("/associate-ruchers")
    public ResponseEntity<Map<String, Object>> associateRuchers() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            if (firebaseService == null) {
                result.put("status", "ERROR");
                result.put("message", "FirebaseService non disponible");
                return ResponseEntity.status(500).body(result);
            }

            // Récupérer l'apiculteur jean.dupont@email.com
            var apiculteur = apiculteurService.getApiculteurByEmail("jean.dupont@email.com");
            
            if (apiculteur == null) {
                result.put("status", "ERROR");
                result.put("message", "Apiculteur jean.dupont@email.com non trouvé");
                return ResponseEntity.status(404).body(result);
            }

            String apiculteurId = apiculteur.getId();

            // Récupérer tous les ruchers
            var allRuchers = firebaseService.getAllDocuments("ruchers");
            result.put("total_ruchers_found", allRuchers.size());

            int ruchersAssociated = 0;
            for (var rucherDoc : allRuchers) {
                String currentApiculteurId = (String) rucherDoc.getData().get("apiculteur_id");
                
                if (currentApiculteurId == null || currentApiculteurId.isEmpty()) {
                    // Associer ce rucher à jean.dupont@email.com
                    Map<String, Object> updates = new HashMap<>();
                    updates.put("apiculteur_id", apiculteurId);
                    
                    firebaseService.updateDocument("ruchers", rucherDoc.getId(), updates);
                    ruchersAssociated++;
                }
            }

            result.put("ruchers_associated", ruchersAssociated);
            result.put("status", "SUCCESS");
            result.put("message", ruchersAssociated + " ruchers associés à jean.dupont@email.com");
            
        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", "Erreur lors de l'association: " + e.getMessage());
            return ResponseEntity.status(500).body(result);
        }

        return ResponseEntity.ok(result);
    }

    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> checkStatus() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // Récupérer l'apiculteur
            var apiculteur = apiculteurService.getApiculteurByEmail("jean.dupont@email.com");
            
            if (apiculteur != null) {
                result.put("apiculteur_found", true);
                result.put("apiculteur_id", apiculteur.getId());
                
                // Compter les ruches associées
                var ruches = firebaseService.getDocuments("ruches", "apiculteur_id", apiculteur.getId());
                result.put("ruches_associated", ruches.size());
                
                // Compter les ruchers associés
                var ruchers = firebaseService.getDocuments("ruchers", "apiculteur_id", apiculteur.getId());
                result.put("ruchers_associated", ruchers.size());
                
            } else {
                result.put("apiculteur_found", false);
            }

            result.put("status", "SUCCESS");
            
        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", e.getMessage());
        }

        return ResponseEntity.ok(result);
    }

    @GetMapping("/diagnose-error")
    public ResponseEntity<Map<String, Object>> diagnoseError() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // Récupérer l'apiculteur
            var apiculteur = apiculteurService.getApiculteurByEmail("jean.dupont@email.com");
            
            if (apiculteur == null) {
                result.put("status", "ERROR");
                result.put("message", "Apiculteur non trouvé");
                return ResponseEntity.status(404).body(result);
            }

            result.put("apiculteur_id", apiculteur.getId());
            result.put("apiculteur_found", true);

            // Test: Récupération directe via Firebase
            try {
                var ruchesFirebase = firebaseService.getDocuments("ruches", "apiculteur_id", apiculteur.getId());
                result.put("ruches_firebase_direct", "SUCCESS");
                result.put("ruches_firebase_count", ruchesFirebase.size());
                
                // Lister les noms des ruches
                for (int i = 0; i < ruchesFirebase.size(); i++) {
                    var doc = ruchesFirebase.get(i);
                    result.put("ruche_" + i + "_nom", doc.getData().get("nom"));
                    result.put("ruche_" + i + "_id", doc.getId());
                }
            } catch (Exception e) {
                result.put("ruches_firebase_direct", "ERROR");
                result.put("ruches_firebase_error", e.getMessage());
                result.put("ruches_firebase_stack", java.util.Arrays.toString(e.getStackTrace()));
            }

            try {
                var ruchersFirebase = firebaseService.getDocuments("ruchers", "apiculteur_id", apiculteur.getId());
                result.put("ruchers_firebase_direct", "SUCCESS");
                result.put("ruchers_firebase_count", ruchersFirebase.size());
                
                // Lister les noms des ruchers
                for (int i = 0; i < ruchersFirebase.size(); i++) {
                    var doc = ruchersFirebase.get(i);
                    result.put("rucher_" + i + "_nom", doc.getData().get("nom"));
                    result.put("rucher_" + i + "_id", doc.getId());
                }
            } catch (Exception e) {
                result.put("ruchers_firebase_direct", "ERROR");
                result.put("ruchers_firebase_error", e.getMessage());
                result.put("ruchers_firebase_stack", java.util.Arrays.toString(e.getStackTrace()));
            }

            result.put("status", "SUCCESS");
            
        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", "Erreur générale: " + e.getMessage());
            result.put("error_stack", java.util.Arrays.toString(e.getStackTrace()));
            return ResponseEntity.status(500).body(result);
        }

        return ResponseEntity.ok(result);
    }
} 