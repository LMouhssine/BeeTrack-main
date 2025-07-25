package com.rucheconnectee.service;


import com.google.cloud.Timestamp;
import com.rucheconnectee.model.Rucher;
import com.rucheconnectee.config.FirebaseTimestampConverter;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;

@Service
@ConditionalOnProperty(name = "firebase.project-id")
public class FirebaseRucherService extends RucherService {

    @Autowired
    private FirebaseService firebaseService;

    private static final String COLLECTION_RUCHERS = "ruchers";

    @Override
    public Rucher getRucherById(String id) {
        try {
            var document = firebaseService.getDocument(COLLECTION_RUCHERS, id);
            if (document != null) {
                Rucher rucher = mapDocumentToRucher(document);
                return rucher;
            }
            return null;
        } catch (Exception e) {
            System.err.println("❌ Erreur lors de la récupération du rucher " + id + ": " + e.getMessage());
            throw new RuntimeException("Erreur lors de la récupération du rucher", e);
        }
    }

    @Override
    public List<Rucher> getRuchersByApiculteur(String apiculteurId) {
        try {
            System.out.println("🔍 Récupération des ruchers pour l'apiculteur: " + apiculteurId);
            List<Map<String, Object>> documents = firebaseService.getDocuments(COLLECTION_RUCHERS, "apiculteur_id", apiculteurId);
            List<Rucher> ruchers = new ArrayList<>();
            
            System.out.println("📊 Nombre de documents trouvés: " + documents.size());
            
            for (Map<String, Object> document : documents) {
                try {
                    Rucher rucher = mapDocumentToRucher(document);
                    ruchers.add(rucher);
                    System.out.println("✅ Rucher mappé: " + rucher.getNom());
                } catch (Exception e) {
                    System.err.println("❌ Erreur lors du mapping du rucher " + document.get("id") + ": " + e.getMessage());
                    // Continuer avec les autres documents au lieu de tout arrêter
                }
            }
            
            System.out.println("✅ Total ruchers récupérés: " + ruchers.size());
            return ruchers;
        } catch (Exception e) {
            System.err.println("❌ Erreur lors de la récupération des ruchers: " + e.getMessage());
            throw new RuntimeException("Erreur lors de la récupération des ruchers", e);
        }
    }

    /**
     * Mappe manuellement un document Map vers un objet Rucher
     * pour éviter les problèmes de désérialisation automatique avec les timestamps
     */
    private Rucher mapDocumentToRucher(Map<String, Object> document) {
        Rucher rucher = new Rucher();
        
        rucher.setId((String) document.get("id"));
        
        // Champs string
        if (document.containsKey("nom")) rucher.setNom((String) document.get("nom"));
        if (document.containsKey("description")) rucher.setDescription((String) document.get("description"));
        if (document.containsKey("adresse")) rucher.setAdresse((String) document.get("adresse"));
        if (document.containsKey("ville")) rucher.setVille((String) document.get("ville"));
        if (document.containsKey("code_postal")) rucher.setCodePostal((String) document.get("code_postal"));
        if (document.containsKey("apiculteur_id")) rucher.setApiculteurId((String) document.get("apiculteur_id"));
        if (document.containsKey("notes")) rucher.setNotes((String) document.get("notes"));
        if (document.containsKey("coordonnees")) rucher.setCoordonnees((String) document.get("coordonnees"));
        
        // Champs numériques
        if (document.containsKey("position_lat") && document.get("position_lat") instanceof Number) {
            rucher.setPositionLat(((Number) document.get("position_lat")).doubleValue());
        }
        if (document.containsKey("position_lng") && document.get("position_lng") instanceof Number) {
            rucher.setPositionLng(((Number) document.get("position_lng")).doubleValue());
        }
        if (document.containsKey("nombre_ruches") && document.get("nombre_ruches") instanceof Number) {
            rucher.setNombreRuches(((Number) document.get("nombre_ruches")).intValue());
        }
        
        // Champ boolean
        if (document.containsKey("actif")) {
            Boolean actif = (Boolean) document.get("actif");
            rucher.setActif(actif != null ? actif : true);
        }
        
        // Gestion spéciale pour les timestamps
        if (document.containsKey("date_creation") && document.get("date_creation") instanceof com.google.cloud.Timestamp) {
            Timestamp timestamp = (com.google.cloud.Timestamp) document.get("date_creation");
            if (timestamp != null) {
                rucher.setDateCreation(FirebaseTimestampConverter.timestampToLocalDateTime(timestamp));
            }
        }
        
        return rucher;
    }

    @Override
    public Rucher createRucher(Rucher rucher) {
        try {
            Map<String, Object> data = new HashMap<>();
            data.put("nom", rucher.getNom());
            data.put("description", rucher.getDescription());
            data.put("adresse", rucher.getAdresse());
            data.put("apiculteur_id", rucher.getApiculteurId());
            data.put("nombre_ruches", 0);
            data.put("actif", true);
            data.put("date_creation", com.google.cloud.Timestamp.now());
            
            if (rucher.getPositionLat() != null) data.put("position_lat", rucher.getPositionLat());
            if (rucher.getPositionLng() != null) data.put("position_lng", rucher.getPositionLng());
            
            String id = firebaseService.addDocument(COLLECTION_RUCHERS, data);
            rucher.setId(id);
            return rucher;
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la création du rucher", e);
        }
    }

    @Override
    public Rucher updateRucher(String id, Rucher rucher) {
        try {
            Map<String, Object> data = new HashMap<>();
            data.put("nom", rucher.getNom());
            data.put("description", rucher.getDescription());
            data.put("adresse", rucher.getAdresse());
            
            if (rucher.getPositionLat() != null) data.put("position_lat", rucher.getPositionLat());
            if (rucher.getPositionLng() != null) data.put("position_lng", rucher.getPositionLng());
            
            firebaseService.updateDocument(COLLECTION_RUCHERS, id, data);
            rucher.setId(id);
            return rucher;
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la mise à jour du rucher", e);
        }
    }

    @Override
    public void deleteRucher(String id) {
        try {
            firebaseService.deleteDocument(COLLECTION_RUCHERS, id);
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la suppression du rucher", e);
        }
    }
} 