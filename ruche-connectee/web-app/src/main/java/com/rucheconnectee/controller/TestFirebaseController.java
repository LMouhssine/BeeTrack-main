package com.rucheconnectee.controller;

import com.rucheconnectee.service.FirebaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * Contrôleur de test pour diagnostiquer la connectivité Firebase
 */
@RestController
@RequestMapping("/test/firebase")
@ConditionalOnProperty(name = "firebase.project-id")
public class TestFirebaseController {

    @Autowired(required = false)
    private FirebaseService firebaseService;

    @GetMapping("/connectivity")
    public ResponseEntity<Map<String, Object>> testConnectivity() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            if (firebaseService == null) {
                result.put("status", "ERROR");
                result.put("message", "FirebaseService n'est pas initialisé");
                return ResponseEntity.status(500).body(result);
            }

            // Test de connexion basique - récupération de toutes les collections
            try {
                var ruches = firebaseService.getAllDocuments("ruches");
                result.put("ruches_count", ruches.size());
                result.put("ruches_found", true);
            } catch (Exception e) {
                result.put("ruches_found", false);
                result.put("ruches_error", e.getMessage());
            }

            try {
                var ruchers = firebaseService.getAllDocuments("ruchers");
                result.put("ruchers_count", ruchers.size());
                result.put("ruchers_found", true);
            } catch (Exception e) {
                result.put("ruchers_found", false);
                result.put("ruchers_error", e.getMessage());
            }

            try {
                var apiculteurs = firebaseService.getAllDocuments("apiculteurs");
                result.put("apiculteurs_count", apiculteurs.size());
                result.put("apiculteurs_found", true);
            } catch (Exception e) {
                result.put("apiculteurs_found", false);
                result.put("apiculteurs_error", e.getMessage());
            }

            try {
                var donnees = firebaseService.getAllDocuments("donnees_capteur");
                result.put("donnees_count", donnees.size());
                result.put("donnees_found", true);
            } catch (Exception e) {
                result.put("donnees_found", false);
                result.put("donnees_error", e.getMessage());
            }

            result.put("status", "SUCCESS");
            result.put("message", "Test de connectivité Firebase terminé");
            
        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", "Erreur lors du test de connectivité");
            result.put("error", e.getMessage());
            result.put("error_class", e.getClass().getSimpleName());
            return ResponseEntity.status(500).body(result);
        }

        return ResponseEntity.ok(result);
    }

    @GetMapping("/collections")
    public ResponseEntity<Map<String, Object>> listCollections() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            if (firebaseService == null) {
                result.put("status", "ERROR");
                result.put("message", "FirebaseService n'est pas initialisé");
                return ResponseEntity.status(500).body(result);
            }

            // Liste des collections attendues
            String[] collections = {"ruches", "ruchers", "apiculteurs", "donnees_capteur"};
            
            for (String collection : collections) {
                try {
                    var documents = firebaseService.getAllDocuments(collection);
                    Map<String, Object> collectionInfo = new HashMap<>();
                    collectionInfo.put("exists", true);
                    collectionInfo.put("document_count", documents.size());
                    
                    if (!documents.isEmpty()) {
                        var firstDoc = documents.get(0);
                        collectionInfo.put("sample_fields", firstDoc.getData().keySet());
                    }
                    
                    result.put(collection, collectionInfo);
                } catch (Exception e) {
                    Map<String, Object> collectionInfo = new HashMap<>();
                    collectionInfo.put("exists", false);
                    collectionInfo.put("error", e.getMessage());
                    result.put(collection, collectionInfo);
                }
            }

            result.put("status", "SUCCESS");
            
        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", "Erreur lors de la liste des collections");
            result.put("error", e.getMessage());
            return ResponseEntity.status(500).body(result);
        }

        return ResponseEntity.ok(result);
    }

    @GetMapping("/simple-debug")
    public ResponseEntity<Map<String, Object>> simpleDebug() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            if (firebaseService == null) {
                result.put("status", "ERROR");
                result.put("message", "FirebaseService n'est pas initialisé");
                return ResponseEntity.status(500).body(result);
            }

            // Lister tous les apiculteurs
            try {
                var allApiculteurs = firebaseService.getAllDocuments("apiculteurs");
                result.put("apiculteurs_count", allApiculteurs.size());
                for (int i = 0; i < allApiculteurs.size(); i++) {
                    var doc = allApiculteurs.get(i);
                    Map<String, Object> apiculteurInfo = new HashMap<>();
                    apiculteurInfo.put("id", doc.getId());
                    apiculteurInfo.put("email", doc.getData().get("email"));
                    apiculteurInfo.put("nom", doc.getData().get("nom"));
                    result.put("apiculteur_" + i, apiculteurInfo);
                }
            } catch (Exception e) {
                result.put("apiculteurs_error", e.getMessage());
            }

            // Lister toutes les ruches
            try {
                var allRuches = firebaseService.getAllDocuments("ruches");
                result.put("ruches_count", allRuches.size());
                for (int i = 0; i < allRuches.size(); i++) {
                    var doc = allRuches.get(i);
                    Map<String, Object> rucheInfo = new HashMap<>();
                    rucheInfo.put("id", doc.getId());
                    rucheInfo.put("nom", doc.getData().get("nom"));
                    rucheInfo.put("apiculteur_id", doc.getData().get("apiculteur_id"));
                    rucheInfo.put("rucher_id", doc.getData().get("rucher_id"));
                    result.put("ruche_" + i, rucheInfo);
                }
            } catch (Exception e) {
                result.put("ruches_error", e.getMessage());
            }

            result.put("status", "SUCCESS");
            
        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", "Erreur lors du debug simple");
            result.put("error", e.getMessage());
            return ResponseEntity.status(500).body(result);
        }

        return ResponseEntity.ok(result);
    }
} 