package com.rucheconnectee.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.rucheconnectee.model.Ruche;
import com.rucheconnectee.model.Rucher;
import com.rucheconnectee.model.DonneesCapteur;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@Service
public class FirestoreService {

    private static final Logger logger = LoggerFactory.getLogger(FirestoreService.class);
    private final Firestore firestore;

    @Autowired
    public FirestoreService(Firestore firestore) {
        this.firestore = firestore;
    }

    /**
     * Récupère tous les ruchers d'un apiculteur
     */
    public List<Rucher> getRuchersByApiculteurId(String apiculteurId) {
        try {
            logger.info("Recherche des ruchers pour l'apiculteur: {}", apiculteurId);
            
            // Afficher tous les ruchers pour déboguer
            CollectionReference ruchersRef = firestore.collection("ruchers");
            ApiFuture<QuerySnapshot> allRuchersFuture = ruchersRef.get();
            QuerySnapshot allRuchers = allRuchersFuture.get();
            logger.info("Nombre total de ruchers dans la base: {}", allRuchers.size());
            for (QueryDocumentSnapshot doc : allRuchers) {
                logger.info("Rucher trouvé - ID: {}, idApiculteur: {}", 
                    doc.getId(), 
                    doc.getString("idApiculteur"));
            }

            // Recherche des ruchers de l'apiculteur
            ApiFuture<QuerySnapshot> future = firestore.collection("ruchers")
                    .whereEqualTo("idApiculteur", apiculteurId)
                    .get();

            List<Rucher> ruchers = new ArrayList<>();
            QuerySnapshot snapshots = future.get();

            logger.info("Nombre de ruchers trouvés pour l'apiculteur {}: {}", apiculteurId, snapshots.size());
            for (QueryDocumentSnapshot document : snapshots) {
                Map<String, Object> data = document.getData();
                logger.debug("Données du rucher: {}", data);
                
                Rucher rucher = new Rucher();
                rucher.setId(document.getId());
                rucher.setNom(document.getString("nom"));
                rucher.setDescription(document.getString("description"));
                rucher.setAdresse(document.getString("adresse"));
                rucher.setApiculteurId(document.getString("idApiculteur"));
                
                // Conversion des types numériques
                Long nombreRuches = document.getLong("nombre_ruches");
                if (nombreRuches != null) {
                    rucher.setNombreRuches(nombreRuches.intValue());
                }
                
                Double lat = document.getDouble("position_lat");
                Double lng = document.getDouble("position_lng");
                if (lat != null) rucher.setPositionLat(lat);
                if (lng != null) rucher.setPositionLng(lng);
                
                // Conversion des booléens
                Boolean actif = document.getBoolean("actif");
                if (actif != null) rucher.setActif(actif);
                
                // Conversion des dates
                com.google.cloud.Timestamp dateCreation = document.getTimestamp("dateCreation");
                if (dateCreation != null) {
                    rucher.setDateCreation(dateCreation.toDate().toInstant()
                            .atZone(java.time.ZoneId.systemDefault())
                            .toLocalDateTime());
                }
                
                ruchers.add(rucher);
                logger.info("Rucher ajouté: {}", rucher);
            }

            return ruchers;
        } catch (InterruptedException | ExecutionException e) {
            logger.error("Erreur lors de la récupération des ruchers", e);
            throw new RuntimeException("Erreur lors de la récupération des ruchers", e);
        }
    }

    /**
     * Récupère toutes les ruches d'un rucher
     */
    public List<Ruche> getRuchesByRucherId(String rucherId) {
        try {
            logger.info("Recherche des ruches pour le rucher: {}", rucherId);
            ApiFuture<QuerySnapshot> future = firestore.collection("ruches")
                    .whereEqualTo("rucher_id", rucherId)
                    .get();

            List<Ruche> ruches = new ArrayList<>();
            QuerySnapshot snapshots = future.get();

            logger.info("Nombre de ruches trouvées: {}", snapshots.size());
            for (QueryDocumentSnapshot document : snapshots) {
                logger.debug("Ruche trouvée - ID: {}, Données: {}", document.getId(), document.getData());
                Ruche ruche = document.toObject(Ruche.class);
                ruche.setId(document.getId());
                
                // Récupérer les dernières données des capteurs
                DonneesCapteur dernieresDonnees = getDernieresDonneesCapteur(ruche.getId());
                if (dernieresDonnees != null) {
                    ruche.setDernieresDonnees(dernieresDonnees);
                }
                
                ruches.add(ruche);
            }

            return ruches;
        } catch (InterruptedException | ExecutionException e) {
            logger.error("Erreur lors de la récupération des ruches pour le rucher {}: {}", rucherId, e.getMessage());
            throw new RuntimeException("Erreur lors de la récupération des ruches", e);
        }
    }

    /**
     * Récupère les dernières données des capteurs pour une ruche
     */
    public DonneesCapteur getDernieresDonneesCapteur(String rucheId) {
        try {
            ApiFuture<QuerySnapshot> future = firestore.collection("donnees_capteurs")
                    .whereEqualTo("rucheId", rucheId)
                    .orderBy("timestamp", Query.Direction.DESCENDING)
                    .limit(1)
                    .get();

            QuerySnapshot snapshots = future.get();
            
            if (!snapshots.isEmpty()) {
                return snapshots.getDocuments().get(0).toObject(DonneesCapteur.class);
            }
            
            return null;
        } catch (InterruptedException | ExecutionException e) {
            throw new RuntimeException("Erreur lors de la récupération des données capteurs", e);
        }
    }

    /**
     * Récupère l'historique des données des capteurs pour une ruche
     */
    public List<DonneesCapteur> getHistoriqueDonneesCapteur(String rucheId, int limit) {
        try {
            ApiFuture<QuerySnapshot> future = firestore.collection("donnees_capteurs")
                    .whereEqualTo("rucheId", rucheId)
                    .orderBy("timestamp", Query.Direction.DESCENDING)
                    .limit(limit)
                    .get();

            List<DonneesCapteur> donnees = new ArrayList<>();
            QuerySnapshot snapshots = future.get();

            for (QueryDocumentSnapshot document : snapshots) {
                donnees.add(document.toObject(DonneesCapteur.class));
            }

            return donnees;
        } catch (InterruptedException | ExecutionException e) {
            throw new RuntimeException("Erreur lors de la récupération de l'historique", e);
        }
    }

    /**
     * Récupère les statistiques globales pour un rucher
     */
    public Map<String, Object> getStatistiquesRucher(String rucherId) {
        try {
            List<Ruche> ruches = getRuchesByRucherId(rucherId);
            
            double temperatureMoyenne = ruches.stream()
                    .filter(r -> r.getDernieresDonnees() != null)
                    .mapToDouble(r -> r.getDernieresDonnees().getTemperature())
                    .average()
                    .orElse(0.0);
            
            double humiditeMoyenne = ruches.stream()
                    .filter(r -> r.getDernieresDonnees() != null)
                    .mapToDouble(r -> r.getDernieresDonnees().getHumidite())
                    .average()
                    .orElse(0.0);
            
            double poidsMoyen = ruches.stream()
                    .filter(r -> r.getDernieresDonnees() != null)
                    .mapToDouble(r -> r.getDernieresDonnees().getPoids())
                    .average()
                    .orElse(0.0);

            return Map.of(
                "nombreRuches", ruches.size(),
                "temperatureMoyenne", temperatureMoyenne,
                "humiditeMoyenne", humiditeMoyenne,
                "poidsMoyen", poidsMoyen
            );
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors du calcul des statistiques", e);
        }
    }

    /**
     * Récupère l'ID Firebase d'un apiculteur par son email
     */
    public String getApiculteurIdByEmail(String email) {
        try {
            logger.info("Recherche de l'apiculteur avec l'email: {}", email);
            
            // Afficher tous les apiculteurs pour déboguer
            CollectionReference apiculteursRef = firestore.collection("apiculteurs");
            ApiFuture<QuerySnapshot> allApiculteursFuture = apiculteursRef.get();
            QuerySnapshot allApiculteurs = allApiculteursFuture.get();
            logger.info("Nombre total d'apiculteurs dans la base: {}", allApiculteurs.size());
            for (QueryDocumentSnapshot doc : allApiculteurs) {
                logger.info("Apiculteur trouvé - ID: {}, email: {}", 
                    doc.getId(), 
                    doc.getString("email"));
            }

            // Recherche de l'apiculteur par email
            ApiFuture<QuerySnapshot> future = firestore.collection("apiculteurs")
                    .whereEqualTo("email", email)
                    .limit(1)
                    .get();

            QuerySnapshot snapshots = future.get();
            if (!snapshots.isEmpty()) {
                String apiculteurId = snapshots.getDocuments().get(0).getId();
                logger.info("ID de l'apiculteur trouvé: {}", apiculteurId);
                return apiculteurId;
            }

            logger.warn("Aucun apiculteur trouvé avec l'email: {}", email);
            return null;
        } catch (InterruptedException | ExecutionException e) {
            logger.error("Erreur lors de la recherche de l'apiculteur", e);
            throw new RuntimeException("Erreur lors de la recherche de l'apiculteur", e);
        }
    }
} 