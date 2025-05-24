package com.rucheconnectee.service;

import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.rucheconnectee.model.Ruche;
import com.rucheconnectee.model.DonneesCapteur;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

/**
 * Service pour la gestion des ruches et de leurs données de capteurs.
 * Reproduit la logique de gestion des ruches de l'application mobile.
 */
@Service
public class RucheService {

    @Autowired
    private FirebaseService firebaseService;

    @Autowired
    private RucherService rucherService;

    private static final String COLLECTION_RUCHES = "ruches";
    private static final String COLLECTION_DONNEES = "donnees_capteurs";

    /**
     * Récupère une ruche par son ID
     */
    public Ruche getRucheById(String id) throws ExecutionException, InterruptedException {
        var document = firebaseService.getDocument(COLLECTION_RUCHES, id);
        if (document.exists()) {
            return documentToRuche(document.getId(), document.getData());
        }
        return null;
    }

    /**
     * Récupère toutes les ruches d'un apiculteur
     */
    public List<Ruche> getRuchesByApiculteur(String apiculteurId) throws ExecutionException, InterruptedException {
        List<QueryDocumentSnapshot> documents = firebaseService.getDocuments(COLLECTION_RUCHES, "apiculteur_id", apiculteurId);
        return documents.stream()
                .filter(doc -> (Boolean) doc.getData().getOrDefault("actif", true))
                .map(doc -> documentToRuche(doc.getId(), doc.getData()))
                .collect(Collectors.toList());
    }

    /**
     * Récupère toutes les ruches d'un rucher
     */
    public List<Ruche> getRuchesByRucher(String rucherId) throws ExecutionException, InterruptedException {
        List<QueryDocumentSnapshot> documents = firebaseService.getDocuments(COLLECTION_RUCHES, "rucher_id", rucherId);
        return documents.stream()
                .filter(doc -> (Boolean) doc.getData().getOrDefault("actif", true))
                .map(doc -> documentToRuche(doc.getId(), doc.getData()))
                .collect(Collectors.toList());
    }

    /**
     * Crée une nouvelle ruche
     */
    public Ruche createRuche(Ruche ruche) throws ExecutionException, InterruptedException {
        // Récupérer le nom du rucher
        if (ruche.getRucherId() != null) {
            var rucher = rucherService.getRucherById(ruche.getRucherId());
            if (rucher != null) {
                ruche.setRucherNom(rucher.getNom());
                // Incrémenter le nombre de ruches du rucher
                rucherService.incrementerNombreRuches(ruche.getRucherId());
            }
        }

        ruche.setDateInstallation(LocalDateTime.now());
        ruche.setActif(true);
        ruche.setDerniereMiseAJour(LocalDateTime.now());

        Map<String, Object> data = rucheToMap(ruche);
        String id = firebaseService.addDocument(COLLECTION_RUCHES, data);
        ruche.setId(id);

        return ruche;
    }

    /**
     * Met à jour une ruche
     */
    public Ruche updateRuche(String id, Ruche ruche) throws ExecutionException, InterruptedException {
        // Récupérer l'ancienne ruche pour vérifier le changement de rucher
        Ruche ancienneRuche = getRucheById(id);
        
        if (ancienneRuche != null && !ancienneRuche.getRucherId().equals(ruche.getRucherId())) {
            // Décrémenter l'ancien rucher
            if (ancienneRuche.getRucherId() != null) {
                rucherService.decrementerNombreRuches(ancienneRuche.getRucherId());
            }
            // Incrémenter le nouveau rucher
            if (ruche.getRucherId() != null) {
                rucherService.incrementerNombreRuches(ruche.getRucherId());
                var rucher = rucherService.getRucherById(ruche.getRucherId());
                if (rucher != null) {
                    ruche.setRucherNom(rucher.getNom());
                }
            }
        }

        Map<String, Object> updates = rucheToMap(ruche);
        firebaseService.updateDocument(COLLECTION_RUCHES, id, updates);
        
        ruche.setId(id);
        return ruche;
    }

    /**
     * Désactive une ruche (soft delete)
     */
    public void desactiverRuche(String id) throws ExecutionException, InterruptedException {
        Ruche ruche = getRucheById(id);
        if (ruche != null && ruche.getRucherId() != null) {
            rucherService.decrementerNombreRuches(ruche.getRucherId());
        }

        Map<String, Object> updates = new HashMap<>();
        updates.put("actif", false);
        firebaseService.updateDocument(COLLECTION_RUCHES, id, updates);
    }

    /**
     * Supprime définitivement une ruche
     */
    public void deleteRuche(String id) throws ExecutionException, InterruptedException {
        Ruche ruche = getRucheById(id);
        if (ruche != null && ruche.getRucherId() != null) {
            rucherService.decrementerNombreRuches(ruche.getRucherId());
        }

        firebaseService.deleteDocument(COLLECTION_RUCHES, id);
    }

    /**
     * Met à jour les données de capteurs d'une ruche (appelé par l'ESP32)
     */
    public void updateDonneesCapteurs(String rucheId, DonneesCapteur donnees) throws ExecutionException, InterruptedException {
        // Sauvegarder les données historiques
        Map<String, Object> donneesData = donneesToMap(donnees);
        firebaseService.addDocument(COLLECTION_DONNEES, donneesData);

        // Mettre à jour la ruche avec les dernières données
        Map<String, Object> updates = new HashMap<>();
        updates.put("temperature", donnees.getTemperature());
        updates.put("humidite", donnees.getHumidity());
        updates.put("couvercle_ouvert", donnees.getCouvercleOuvert());
        updates.put("niveau_batterie", donnees.getBatterie());
        updates.put("derniere_mise_a_jour", com.google.cloud.Timestamp.now());

        firebaseService.updateDocument(COLLECTION_RUCHES, rucheId, updates);
    }

    /**
     * Récupère l'historique des données d'une ruche
     */
    public List<DonneesCapteur> getHistoriqueDonnees(String rucheId, int limite) throws ExecutionException, InterruptedException {
        List<QueryDocumentSnapshot> documents = firebaseService.getDocuments(COLLECTION_DONNEES, "ruche_id", rucheId);
        return documents.stream()
                .limit(limite)
                .map(doc -> documentToDonnees(doc.getId(), doc.getData()))
                .collect(Collectors.toList());
    }

    /**
     * Vérifie les seuils d'alerte d'une ruche
     */
    public boolean verifierAlertes(Ruche ruche) {
        if (ruche.getTemperature() != null) {
            if (ruche.getTemperature() < ruche.getSeuilTempMin() || 
                ruche.getTemperature() > ruche.getSeuilTempMax()) {
                return true;
            }
        }
        
        if (ruche.getHumidite() != null) {
            if (ruche.getHumidite() < ruche.getSeuilHumiditeMin() || 
                ruche.getHumidite() > ruche.getSeuilHumiditeMax()) {
                return true;
            }
        }

        if (ruche.getNiveauBatterie() != null && ruche.getNiveauBatterie() < 20) {
            return true;
        }

        return false;
    }

    /**
     * Convertit un document Firestore en objet Ruche
     */
    private Ruche documentToRuche(String id, Map<String, Object> data) {
        if (data == null) return null;

        Ruche ruche = new Ruche();
        ruche.setId(id);
        ruche.setNom((String) data.get("nom"));
        ruche.setApiculteurId((String) data.get("apiculteur_id"));
        ruche.setRucherId((String) data.get("rucher_id"));
        ruche.setRucherNom((String) data.get("rucher_nom"));
        ruche.setDescription((String) data.get("description"));
        ruche.setTypeRuche((String) data.get("type_ruche"));
        ruche.setActif((Boolean) data.getOrDefault("actif", true));

        // Données des capteurs
        if (data.get("temperature") instanceof Number) {
            ruche.setTemperature(((Number) data.get("temperature")).doubleValue());
        }
        if (data.get("humidite") instanceof Number) {
            ruche.setHumidite(((Number) data.get("humidite")).doubleValue());
        }
        ruche.setCouvercleOuvert((Boolean) data.get("couvercle_ouvert"));
        if (data.get("niveau_batterie") instanceof Number) {
            ruche.setNiveauBatterie(((Number) data.get("niveau_batterie")).intValue());
        }

        // Position
        if (data.get("position_lat") instanceof Number) {
            ruche.setPositionLat(((Number) data.get("position_lat")).doubleValue());
        }
        if (data.get("position_lng") instanceof Number) {
            ruche.setPositionLng(((Number) data.get("position_lng")).doubleValue());
        }

        // Seuils
        if (data.get("seuil_temp_min") instanceof Number) {
            ruche.setSeuilTempMin(((Number) data.get("seuil_temp_min")).doubleValue());
        }
        if (data.get("seuil_temp_max") instanceof Number) {
            ruche.setSeuilTempMax(((Number) data.get("seuil_temp_max")).doubleValue());
        }
        if (data.get("seuil_humidite_min") instanceof Number) {
            ruche.setSeuilHumiditeMin(((Number) data.get("seuil_humidite_min")).doubleValue());
        }
        if (data.get("seuil_humidite_max") instanceof Number) {
            ruche.setSeuilHumiditeMax(((Number) data.get("seuil_humidite_max")).doubleValue());
        }

        // Gestion des dates
        Object dateInstallation = data.get("date_installation");
        if (dateInstallation instanceof com.google.cloud.Timestamp) {
            ruche.setDateInstallation(((com.google.cloud.Timestamp) dateInstallation).toDate().toInstant()
                    .atZone(java.time.ZoneId.systemDefault()).toLocalDateTime());
        }

        Object derniereMiseAJour = data.get("derniere_mise_a_jour");
        if (derniereMiseAJour instanceof com.google.cloud.Timestamp) {
            ruche.setDerniereMiseAJour(((com.google.cloud.Timestamp) derniereMiseAJour).toDate().toInstant()
                    .atZone(java.time.ZoneId.systemDefault()).toLocalDateTime());
        }

        return ruche;
    }

    /**
     * Convertit un objet Ruche en Map pour Firestore
     */
    private Map<String, Object> rucheToMap(Ruche ruche) {
        Map<String, Object> data = new HashMap<>();
        data.put("nom", ruche.getNom());
        data.put("apiculteur_id", ruche.getApiculteurId());
        data.put("rucher_id", ruche.getRucherId());
        data.put("rucher_nom", ruche.getRucherNom());
        data.put("description", ruche.getDescription());
        data.put("type_ruche", ruche.getTypeRuche());
        data.put("actif", ruche.isActif());
        data.put("temperature", ruche.getTemperature());
        data.put("humidite", ruche.getHumidite());
        data.put("couvercle_ouvert", ruche.getCouvercleOuvert());
        data.put("niveau_batterie", ruche.getNiveauBatterie());
        data.put("position_lat", ruche.getPositionLat());
        data.put("position_lng", ruche.getPositionLng());
        data.put("seuil_temp_min", ruche.getSeuilTempMin());
        data.put("seuil_temp_max", ruche.getSeuilTempMax());
        data.put("seuil_humidite_min", ruche.getSeuilHumiditeMin());
        data.put("seuil_humidite_max", ruche.getSeuilHumiditeMax());

        if (ruche.getDateInstallation() != null) {
            data.put("date_installation", com.google.cloud.Timestamp.of(
                    java.util.Date.from(ruche.getDateInstallation().atZone(java.time.ZoneId.systemDefault()).toInstant())
            ));
        }

        if (ruche.getDerniereMiseAJour() != null) {
            data.put("derniere_mise_a_jour", com.google.cloud.Timestamp.of(
                    java.util.Date.from(ruche.getDerniereMiseAJour().atZone(java.time.ZoneId.systemDefault()).toInstant())
            ));
        }

        return data;
    }

    /**
     * Convertit un document Firestore en objet DonneesCapteur
     */
    private DonneesCapteur documentToDonnees(String id, Map<String, Object> data) {
        if (data == null) return null;

        DonneesCapteur donnees = new DonneesCapteur();
        donnees.setId(id);
        donnees.setRucheId((String) data.get("ruche_id"));
        donnees.setCouvercleOuvert((Boolean) data.get("couvercle_ouvert"));
        donnees.setErreur((String) data.get("erreur"));

        if (data.get("temperature") instanceof Number) {
            donnees.setTemperature(((Number) data.get("temperature")).doubleValue());
        }
        if (data.get("humidity") instanceof Number) {
            donnees.setHumidity(((Number) data.get("humidity")).doubleValue());
        }
        if (data.get("batterie") instanceof Number) {
            donnees.setBatterie(((Number) data.get("batterie")).intValue());
        }
        if (data.get("signal_qualite") instanceof Number) {
            donnees.setSignalQualite(((Number) data.get("signal_qualite")).intValue());
        }

        Object timestamp = data.get("timestamp");
        if (timestamp instanceof com.google.cloud.Timestamp) {
            donnees.setTimestamp(((com.google.cloud.Timestamp) timestamp).toDate().toInstant()
                    .atZone(java.time.ZoneId.systemDefault()).toLocalDateTime());
        }

        return donnees;
    }

    /**
     * Convertit un objet DonneesCapteur en Map pour Firestore
     */
    private Map<String, Object> donneesToMap(DonneesCapteur donnees) {
        Map<String, Object> data = new HashMap<>();
        data.put("ruche_id", donnees.getRucheId());
        data.put("temperature", donnees.getTemperature());
        data.put("humidity", donnees.getHumidity());
        data.put("couvercle_ouvert", donnees.getCouvercleOuvert());
        data.put("batterie", donnees.getBatterie());
        data.put("signal_qualite", donnees.getSignalQualite());
        data.put("erreur", donnees.getErreur());

        if (donnees.getTimestamp() != null) {
            data.put("timestamp", com.google.cloud.Timestamp.of(
                    java.util.Date.from(donnees.getTimestamp().atZone(java.time.ZoneId.systemDefault()).toInstant())
            ));
        } else {
            data.put("timestamp", com.google.cloud.Timestamp.now());
        }

        return data;
    }
} 