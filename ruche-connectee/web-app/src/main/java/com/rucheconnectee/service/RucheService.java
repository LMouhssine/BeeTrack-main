package com.rucheconnectee.service;

import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.rucheconnectee.model.Ruche;
import com.rucheconnectee.model.DonneesCapteur;
import com.rucheconnectee.model.CreateRucheRequest;
import com.rucheconnectee.model.RucheResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
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
@ConditionalOnProperty(name = "firebase.project-id")
public abstract class RucheService {

    @Autowired
    private FirebaseService firebaseService;

    @Autowired
    private RucherService rucherService;

    private static final String COLLECTION_RUCHES = "ruches";
    private static final String COLLECTION_DONNEES = "donnees_capteurs";

    public abstract Ruche getRucheById(String id) throws ExecutionException, InterruptedException;
    public abstract List<Ruche> getRuchesByApiculteur(String apiculteurId);
    public abstract List<DonneesCapteur> getHistoriqueDonnees(String rucheId, int limit);
    public abstract Ruche createRuche(Ruche ruche);
    public abstract Ruche updateRuche(String id, Ruche ruche);
    public abstract void deleteRuche(String id);
    public abstract void desactiverRuche(String id);

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
     * Récupère les mesures des 7 derniers jours d'une ruche
     * @param rucheId ID de la ruche
     * @return Liste des mesures triées par date croissante
     */
    public List<DonneesCapteur> getMesures7DerniersJours(String rucheId) throws ExecutionException, InterruptedException {
        // Calculer la date limite (maintenant - 7 jours)
        LocalDateTime dateLimite = LocalDateTime.now().minusDays(7);
        
        // Convertir en Timestamp Firebase pour la comparaison
        com.google.cloud.Timestamp timestampLimite = com.google.cloud.Timestamp.of(
            java.util.Date.from(dateLimite.atZone(java.time.ZoneId.systemDefault()).toInstant())
        );
        
        // Utiliser le FirebaseService pour exécuter la requête complexe
        List<QueryDocumentSnapshot> documents = firebaseService.getDocumentsWithDateFilter(
            "donneesCapteurs",    // collection (utilisation de la convention camelCase)
            "rucheId",            // filterField (utilisation de la convention camelCase)
            rucheId,              // filterValue
            "timestamp",          // dateField
            timestampLimite,      // dateLimit
            "timestamp",          // orderByField
            true                  // ascending = true pour tri croissant
        );
        
        // Convertir les résultats en objets DonneesCapteur
        return documents.stream()
                .map(doc -> documentToDonnees(doc.getId(), doc.getData()))
                .collect(Collectors.toList());
    }

    /**
     * Récupère la dernière mesure d'une ruche
     * @param rucheId ID de la ruche
     * @return La dernière mesure ou null si aucune mesure trouvée
     */
    public DonneesCapteur getDerniereMesure(String rucheId) throws ExecutionException, InterruptedException {
        // Utiliser le FirebaseService pour récupérer la dernière mesure
        List<QueryDocumentSnapshot> documents = firebaseService.getDocumentsWithFilter(
            "donneesCapteurs",    // collection
            "rucheId",            // filterField
            rucheId,              // filterValue
            "timestamp",          // orderByField
            false,                // ascending = false pour tri décroissant (plus récent en premier)
            1                     // limit = 1 pour récupérer seulement la dernière mesure
        );
        
        // Retourner la première (et unique) mesure si elle existe
        if (!documents.isEmpty()) {
            return documentToDonnees(documents.get(0).getId(), documents.get(0).getData());
        }
        
        return null; // Aucune mesure trouvée
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
    protected Ruche documentToRuche(String id, Map<String, Object> data) {
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
     * Convertit un document Firestore en objet DonneesCapteur
     */
    protected DonneesCapteur documentToDonnees(String id, Map<String, Object> data) {
        if (data == null) return null;

        DonneesCapteur donnees = new DonneesCapteur();
        donnees.setId(id);
        donnees.setRucheId((String) data.get("rucheId"));
        
        if (data.get("temperature") instanceof Number) {
            donnees.setTemperature(((Number) data.get("temperature")).doubleValue());
        }
        if (data.get("humidity") instanceof Number) {
            donnees.setHumidity(((Number) data.get("humidity")).doubleValue());
        }
        if (data.get("batterie") instanceof Number) {
            donnees.setBatterie(((Number) data.get("batterie")).intValue());
        }
        
        donnees.setCouvercleOuvert((Boolean) data.getOrDefault("couvercleOuvert", false));
        
        // Gestion du timestamp
        if (data.get("timestamp") instanceof com.google.cloud.Timestamp) {
            donnees.setTimestamp(((com.google.cloud.Timestamp) data.get("timestamp")).toDate().toInstant()
                    .atZone(java.time.ZoneId.systemDefault()).toLocalDateTime());
        }

        return donnees;
    }

    /**
     * Convertit un objet DonneesCapteur en Map pour Firestore
     */
    private Map<String, Object> donneesToMap(DonneesCapteur donnees) {
        Map<String, Object> data = new HashMap<>();
        data.put("rucheId", donnees.getRucheId());
        data.put("temperature", donnees.getTemperature());
        data.put("humidity", donnees.getHumidity());
        data.put("batterie", donnees.getBatterie());
        data.put("couvercleOuvert", donnees.getCouvercleOuvert());
        data.put("timestamp", com.google.cloud.Timestamp.now());
        return data;
    }

    /**
     * Ajouter une nouvelle ruche avec validation de l'apiculteur
     * @param request Données de création de la ruche
     * @param apiculteurId ID de l'apiculteur
     * @return RucheResponse
     */
    public RucheResponse ajouterRuche(CreateRucheRequest request, String apiculteurId) 
            throws ExecutionException, InterruptedException {
        // Convertir la requête en objet Ruche
        Ruche ruche = request.toRuche(apiculteurId);
        
        // Créer la ruche
        Ruche rucheCreee = createRuche(ruche);
        
        // Retourner la réponse
        return RucheResponse.fromRuche(rucheCreee);
    }

    /**
     * Obtenir toutes les ruches d'un utilisateur
     * @param apiculteurId ID de l'apiculteur
     * @return Liste des ruches
     */
    public List<RucheResponse> obtenirRuchesUtilisateur(String apiculteurId) 
            throws ExecutionException, InterruptedException {
        List<Ruche> ruches = getRuchesByApiculteur(apiculteurId);
        return ruches.stream()
                .map(RucheResponse::fromRuche)
                .collect(java.util.stream.Collectors.toList());
    }

    /**
     * Obtenir les ruches d'un rucher spécifique
     * @param rucherId ID du rucher
     * @param apiculteurId ID de l'apiculteur (pour validation)
     * @return Liste des ruches du rucher triées par nom croissant
     */
    public List<RucheResponse> obtenirRuchesParRucher(String rucherId, String apiculteurId) 
            throws ExecutionException, InterruptedException {
        List<Ruche> ruches = getRuchesByRucher(rucherId);
        
        // Filtrer par apiculteur pour sécurité et trier par nom croissant
        return ruches.stream()
                .filter(ruche -> ruche.getApiculteurId().equals(apiculteurId))
                .sorted((r1, r2) -> {
                    // Tri par nom croissant, gérer les cas null
                    String nom1 = r1.getNom() != null ? r1.getNom() : "";
                    String nom2 = r2.getNom() != null ? r2.getNom() : "";
                    return nom1.compareToIgnoreCase(nom2);
                })
                .map(RucheResponse::fromRuche)
                .collect(java.util.stream.Collectors.toList());
    }

    /**
     * Supprimer une ruche avec validation de l'apiculteur
     * @param rucheId ID de la ruche à supprimer
     * @param apiculteurId ID de l'apiculteur (pour validation)
     */
    public void supprimerRuche(String rucheId, String apiculteurId) 
            throws ExecutionException, InterruptedException {
        // Récupérer la ruche pour validation
        Ruche ruche = getRucheById(rucheId);
        if (ruche == null) {
            throw new IllegalArgumentException("Ruche introuvable");
        }
        
        // Vérifier les permissions
        if (!ruche.getApiculteurId().equals(apiculteurId)) {
            throw new IllegalArgumentException("Accès non autorisé à cette ruche");
        }
        
        // Effectuer une suppression logique (désactivation)
        Map<String, Object> updates = new HashMap<>();
        updates.put("actif", false);
        updates.put("derniere_mise_a_jour", com.google.cloud.Timestamp.now());
        
        firebaseService.updateDocument(COLLECTION_RUCHES, rucheId, updates);
        
        // Optionnel : décrémenter le nombre de ruches dans le rucher
        if (ruche.getRucherId() != null) {
            rucherService.decrementerNombreRuches(ruche.getRucherId());
        }
    }

    /**
     * Méthode utilitaire pour créer des données de test pour les capteurs
     * @param rucheId ID de la ruche
     * @param nombreJours Nombre de jours de données à créer (rétroactivement)
     * @param mesuresParJour Nombre de mesures par jour
     * @return Nombre de mesures créées
     */
    public int creerDonneesTest(String rucheId, int nombreJours, int mesuresParJour) 
            throws ExecutionException, InterruptedException {
        int totalMesures = 0;
        LocalDateTime maintenant = LocalDateTime.now();
        
        for (int jour = 0; jour < nombreJours; jour++) {
            for (int mesure = 0; mesure < mesuresParJour; mesure++) {
                // Calculer le timestamp pour cette mesure
                LocalDateTime timestampMesure = maintenant
                    .minusDays(jour)
                    .minusHours(mesure * (24 / mesuresParJour));
                
                // Créer des données simulées
                DonneesCapteur donnees = new DonneesCapteur();
                donnees.setRucheId(rucheId);
                donnees.setTimestamp(timestampMesure);
                donnees.setTemperature(15.0 + Math.random() * 20.0); // 15-35°C
                donnees.setHumidity(40.0 + Math.random() * 30.0);   // 40-70%
                donnees.setCouvercleOuvert(Math.random() < 0.1);    // 10% de chance d'être ouvert
                donnees.setBatterie(80 + (int)(Math.random() * 20)); // 80-100%
                
                // Sauvegarder la mesure
                Map<String, Object> donneesData = donneesToMap(donnees);
                firebaseService.addDocument(COLLECTION_DONNEES, donneesData);
                totalMesures++;
            }
        }
        
        return totalMesures;
    }
} 