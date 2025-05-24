package com.rucheconnectee.service;

import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.rucheconnectee.model.Rucher;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

/**
 * Service pour la gestion des ruchers.
 * Reproduit la logique de gestion des ruchers de l'application mobile.
 */
@Service
public class RucherService {

    @Autowired
    private FirebaseService firebaseService;

    private static final String COLLECTION_RUCHERS = "ruchers";

    /**
     * Récupère un rucher par son ID
     */
    public Rucher getRucherById(String id) throws ExecutionException, InterruptedException {
        var document = firebaseService.getDocument(COLLECTION_RUCHERS, id);
        if (document.exists()) {
            return documentToRucher(document.getId(), document.getData());
        }
        return null;
    }

    /**
     * Récupère tous les ruchers d'un apiculteur
     */
    public List<Rucher> getRuchersByApiculteur(String apiculteurId) throws ExecutionException, InterruptedException {
        List<QueryDocumentSnapshot> documents = firebaseService.getDocuments(COLLECTION_RUCHERS, "apiculteur_id", apiculteurId);
        return documents.stream()
                .filter(doc -> (Boolean) doc.getData().getOrDefault("actif", true))
                .map(doc -> documentToRucher(doc.getId(), doc.getData()))
                .collect(Collectors.toList());
    }

    /**
     * Crée un nouveau rucher
     */
    public Rucher createRucher(Rucher rucher) throws ExecutionException, InterruptedException {
        rucher.setDateCreation(LocalDateTime.now());
        rucher.setActif(true);
        rucher.setNombreRuches(0);

        Map<String, Object> data = rucherToMap(rucher);
        String id = firebaseService.addDocument(COLLECTION_RUCHERS, data);
        rucher.setId(id);

        return rucher;
    }

    /**
     * Met à jour un rucher
     */
    public Rucher updateRucher(String id, Rucher rucher) throws ExecutionException, InterruptedException {
        Map<String, Object> updates = rucherToMap(rucher);
        firebaseService.updateDocument(COLLECTION_RUCHERS, id, updates);
        
        rucher.setId(id);
        return rucher;
    }

    /**
     * Désactive un rucher (soft delete)
     */
    public void desactiverRucher(String id) throws ExecutionException, InterruptedException {
        Map<String, Object> updates = new HashMap<>();
        updates.put("actif", false);
        firebaseService.updateDocument(COLLECTION_RUCHERS, id, updates);
    }

    /**
     * Supprime définitivement un rucher
     */
    public void deleteRucher(String id) throws ExecutionException, InterruptedException {
        firebaseService.deleteDocument(COLLECTION_RUCHERS, id);
    }

    /**
     * Incrémente le nombre de ruches d'un rucher
     */
    public void incrementerNombreRuches(String rucherId) throws ExecutionException, InterruptedException {
        Rucher rucher = getRucherById(rucherId);
        if (rucher != null) {
            Map<String, Object> updates = new HashMap<>();
            updates.put("nombre_ruches", rucher.getNombreRuches() + 1);
            firebaseService.updateDocument(COLLECTION_RUCHERS, rucherId, updates);
        }
    }

    /**
     * Décrémente le nombre de ruches d'un rucher
     */
    public void decrementerNombreRuches(String rucherId) throws ExecutionException, InterruptedException {
        Rucher rucher = getRucherById(rucherId);
        if (rucher != null && rucher.getNombreRuches() > 0) {
            Map<String, Object> updates = new HashMap<>();
            updates.put("nombre_ruches", rucher.getNombreRuches() - 1);
            firebaseService.updateDocument(COLLECTION_RUCHERS, rucherId, updates);
        }
    }

    /**
     * Convertit un document Firestore en objet Rucher
     */
    private Rucher documentToRucher(String id, Map<String, Object> data) {
        if (data == null) return null;

        Rucher rucher = new Rucher();
        rucher.setId(id);
        rucher.setNom((String) data.get("nom"));
        rucher.setApiculteurId((String) data.get("apiculteur_id"));
        rucher.setDescription((String) data.get("description"));
        rucher.setAdresse((String) data.get("adresse"));
        rucher.setVille((String) data.get("ville"));
        rucher.setCodePostal((String) data.get("code_postal"));
        rucher.setNotes((String) data.get("notes"));
        rucher.setActif((Boolean) data.getOrDefault("actif", true));

        // Position
        if (data.get("position_lat") instanceof Number) {
            rucher.setPositionLat(((Number) data.get("position_lat")).doubleValue());
        }
        if (data.get("position_lng") instanceof Number) {
            rucher.setPositionLng(((Number) data.get("position_lng")).doubleValue());
        }

        // Nombre de ruches
        if (data.get("nombre_ruches") instanceof Number) {
            rucher.setNombreRuches(((Number) data.get("nombre_ruches")).intValue());
        }

        // Gestion de la date de création
        Object dateCreation = data.get("date_creation");
        if (dateCreation instanceof com.google.cloud.Timestamp) {
            rucher.setDateCreation(((com.google.cloud.Timestamp) dateCreation).toDate().toInstant()
                    .atZone(java.time.ZoneId.systemDefault()).toLocalDateTime());
        }

        return rucher;
    }

    /**
     * Convertit un objet Rucher en Map pour Firestore
     */
    private Map<String, Object> rucherToMap(Rucher rucher) {
        Map<String, Object> data = new HashMap<>();
        data.put("nom", rucher.getNom());
        data.put("apiculteur_id", rucher.getApiculteurId());
        data.put("description", rucher.getDescription());
        data.put("adresse", rucher.getAdresse());
        data.put("ville", rucher.getVille());
        data.put("code_postal", rucher.getCodePostal());
        data.put("notes", rucher.getNotes());
        data.put("actif", rucher.isActif());
        data.put("position_lat", rucher.getPositionLat());
        data.put("position_lng", rucher.getPositionLng());
        data.put("nombre_ruches", rucher.getNombreRuches());

        if (rucher.getDateCreation() != null) {
            data.put("date_creation", com.google.cloud.Timestamp.of(
                    java.util.Date.from(rucher.getDateCreation().atZone(java.time.ZoneId.systemDefault()).toInstant())
            ));
        }

        return data;
    }
} 