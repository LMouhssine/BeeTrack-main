package com.rucheconnectee.service;


import com.rucheconnectee.model.Ruche;
import com.rucheconnectee.model.DonneesCapteur;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;

import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;
import java.util.Map;
import java.util.HashMap;

@Service
@ConditionalOnProperty(name = "firebase.project-id")
public class FirebaseRucheService extends RucheService {

    @Autowired
    private FirebaseService firebaseService;

    @Override
    public Ruche getRucheById(String id) throws ExecutionException, InterruptedException {
        try {
            var document = firebaseService.getDocument("ruches", id);
            if (document != null) {
                return documentToRuche((String) document.get("id"), document);
            }
            return null;
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la récupération de la ruche", e);
        }
    }

    @Override
    public List<Ruche> getRuchesByApiculteur(String apiculteurId) {
        try {
            // Supporter les deux conventions de champs: apiculteur_id et apiculteurId
            List<Map<String, Object>> snakeCase = firebaseService.getDocuments("ruches", "apiculteur_id", apiculteurId);
            List<Map<String, Object>> camelCase = firebaseService.getDocuments("ruches", "apiculteurId", apiculteurId);

            List<Map<String, Object>> merged = new java.util.ArrayList<>();
            if (snakeCase != null) merged.addAll(snakeCase);
            if (camelCase != null) merged.addAll(camelCase);

            // Dédupliquer par id si présent
            java.util.Map<String, Map<String, Object>> idToDoc = new java.util.LinkedHashMap<>();
            for (Map<String, Object> doc : merged) {
                String id = (String) doc.get("id");
                if (id != null) {
                    idToDoc.put(id, doc);
                } else {
                    // Pas d'id? on garde quand même
                    idToDoc.put(java.util.UUID.randomUUID().toString(), doc);
                }
            }

            return idToDoc.values().stream()
                    .map(doc -> documentToRuche((String) doc.get("id"), doc))
                    .collect(Collectors.toList());
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la récupération des ruches", e);
        }
    }

    @Override
    public List<DonneesCapteur> getHistoriqueDonnees(String rucheId, int limit) {
        try {
            List<Map<String, Object>> documents = firebaseService.getDocuments("donnees_capteurs", "rucheId", rucheId);
            return documents.stream()
                    .sorted((a, b) -> {
                        Object aTime = a.get("timestamp");
                        Object bTime = b.get("timestamp");
                        if (aTime instanceof Long && bTime instanceof Long) {
                            return Long.compare((Long) bTime, (Long) aTime); // Décroissant
                        }
                        return 0;
                    })
                    .limit(limit)
                    .map(doc -> documentToDonnees((String) doc.get("id"), doc))
                    .collect(Collectors.toList());
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la récupération de l'historique", e);
        }
    }

    @Override
    public Ruche createRuche(Ruche ruche) {
        try {
            String id = firebaseService.addDocument("ruches", rucheToMap(ruche));
            ruche.setId(id);
            return ruche;
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la création de la ruche", e);
        }
    }

    @Override
    public Ruche updateRuche(String id, Ruche ruche) {
        try {
            firebaseService.updateDocument("ruches", id, rucheToMap(ruche));
            ruche.setId(id);
            return ruche;
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la mise à jour de la ruche", e);
        }
    }

    @Override
    public void deleteRuche(String id) {
        try {
            firebaseService.deleteDocument("ruches", id);
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la suppression de la ruche", e);
        }
    }

    @Override
    public void desactiverRuche(String id) {
        try {
            firebaseService.updateDocument("ruches", id, Map.of("actif", false));
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la désactivation de la ruche", e);
        }
    }

    private Map<String, Object> rucheToMap(Ruche ruche) {
        Map<String, Object> data = new HashMap<>();
        data.put("nom", ruche.getNom());
        data.put("apiculteur_id", ruche.getApiculteurId());
        data.put("rucher_id", ruche.getRucherId());
        data.put("description", ruche.getDescription());
        data.put("type_ruche", ruche.getTypeRuche());
        data.put("actif", ruche.isActif());
        
        if (ruche.getTemperature() != null) data.put("temperature", ruche.getTemperature());
        if (ruche.getHumidite() != null) data.put("humidite", ruche.getHumidite());
        if (ruche.getCouvercleOuvert() != null) data.put("couvercle_ouvert", ruche.getCouvercleOuvert());
        if (ruche.getNiveauBatterie() != null) data.put("niveau_batterie", ruche.getNiveauBatterie());
        
        if (ruche.getPositionLat() != null) data.put("position_lat", ruche.getPositionLat());
        if (ruche.getPositionLng() != null) data.put("position_lng", ruche.getPositionLng());
        
        if (ruche.getSeuilTempMin() != null) data.put("seuil_temp_min", ruche.getSeuilTempMin());
        if (ruche.getSeuilTempMax() != null) data.put("seuil_temp_max", ruche.getSeuilTempMax());
        if (ruche.getSeuilHumiditeMin() != null) data.put("seuil_humidite_min", ruche.getSeuilHumiditeMin());
        if (ruche.getSeuilHumiditeMax() != null) data.put("seuil_humidite_max", ruche.getSeuilHumiditeMax());
        
        if (ruche.getDateInstallation() != null) {
            data.put("date_installation", com.google.cloud.Timestamp.of(
                java.sql.Timestamp.valueOf(ruche.getDateInstallation())
            ));
        }
        
        if (ruche.getDerniereMiseAJour() != null) {
            data.put("derniere_mise_a_jour", com.google.cloud.Timestamp.of(
                java.sql.Timestamp.valueOf(ruche.getDerniereMiseAJour())
            ));
        }
        
        return data;
    }
} 