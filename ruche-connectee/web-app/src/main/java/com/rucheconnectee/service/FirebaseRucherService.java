package com.rucheconnectee.service;

import com.google.cloud.firestore.QueryDocumentSnapshot;
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
            if (document != null && document.exists()) {
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
            List<QueryDocumentSnapshot> documents = firebaseService.getDocuments(COLLECTION_RUCHERS, "apiculteur_id", apiculteurId);
            List<Rucher> ruchers = new ArrayList<>();
            
            System.out.println("📊 Nombre de documents trouvés: " + documents.size());
            
            for (QueryDocumentSnapshot document : documents) {
                try {
                    Rucher rucher = mapDocumentToRucher(document);
                    ruchers.add(rucher);
                    System.out.println("✅ Rucher mappé: " + rucher.getNom());
                } catch (Exception e) {
                    System.err.println("❌ Erreur lors du mapping du rucher " + document.getId() + ": " + e.getMessage());
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
     * Mappe manuellement un document Firestore vers un objet Rucher
     * pour éviter les problèmes de désérialisation automatique avec les timestamps
     */
    private Rucher mapDocumentToRucher(com.google.cloud.firestore.DocumentSnapshot document) {
        Rucher rucher = new Rucher();
        
        rucher.setId(document.getId());
        
        // Champs string
        if (document.contains("nom")) rucher.setNom(document.getString("nom"));
        if (document.contains("description")) rucher.setDescription(document.getString("description"));
        if (document.contains("adresse")) rucher.setAdresse(document.getString("adresse"));
        if (document.contains("ville")) rucher.setVille(document.getString("ville"));
        if (document.contains("code_postal")) rucher.setCodePostal(document.getString("code_postal"));
        if (document.contains("apiculteur_id")) rucher.setApiculteurId(document.getString("apiculteur_id"));
        if (document.contains("notes")) rucher.setNotes(document.getString("notes"));
        if (document.contains("coordonnees")) rucher.setCoordonnees(document.getString("coordonnees"));
        
        // Champs numériques
        if (document.contains("position_lat")) rucher.setPositionLat(document.getDouble("position_lat"));
        if (document.contains("position_lng")) rucher.setPositionLng(document.getDouble("position_lng"));
        if (document.contains("nombre_ruches")) {
            Long nombreRuches = document.getLong("nombre_ruches");
            rucher.setNombreRuches(nombreRuches != null ? nombreRuches.intValue() : 0);
        }
        
        // Champ boolean
        if (document.contains("actif")) {
            Boolean actif = document.getBoolean("actif");
            rucher.setActif(actif != null ? actif : true);
        }
        
        // Gestion spéciale pour les timestamps
        if (document.contains("date_creation")) {
            Timestamp timestamp = document.getTimestamp("date_creation");
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