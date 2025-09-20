package com.rucheconnectee.service;

import com.rucheconnectee.model.DonneesCapteur;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.TimeoutException;
import java.util.stream.Collectors;

/**
 * Service pour la gestion des mesures des capteurs IoT.
 * Correspond à la structure Firebase : ruche/{rucheId}/historique
 */
@Service
public class MesuresService {
    
    @Autowired
    private FirebaseService firebaseService;
    
    /**
     * Récupère la dernière mesure d'une ruche
     */
    public DonneesCapteur getDerniereMesure(String rucheId) {
        try {
            String path = "ruche/" + rucheId + "/historique";
            List<Map<String, Object>> mesures = firebaseService.getAllDocuments(path);
            
            if (mesures.isEmpty()) {
                return null;
            }
            
            // Trier par timestamp et prendre la plus récente
            Optional<Map<String, Object>> derniereMesure = mesures.stream()
                .max(Comparator.comparing(mesure -> parseDateTime(mesure)));
            
            if (derniereMesure.isPresent()) {
                return convertToDonneesCapteur(derniereMesure.get(), rucheId);
            }
            
            return null;
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la récupération de la dernière mesure", e);
        }
    }
    
    /**
     * Récupère toutes les mesures d'une ruche
     */
    public List<DonneesCapteur> getMesuresRuche(String rucheId) {
        try {
            String path = "ruche/" + rucheId + "/historique";
            List<Map<String, Object>> mesures = firebaseService.getAllDocuments(path);
            
            return mesures.stream()
                .map(mesure -> convertToDonneesCapteur(mesure, rucheId))
                .sorted(Comparator.comparing(DonneesCapteur::getTimestamp).reversed())
                .collect(Collectors.toList());
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la récupération des mesures", e);
        }
    }
    
    /**
     * Récupère les mesures d'une ruche pour une période donnée
     */
    public List<DonneesCapteur> getMesuresParPeriode(String rucheId, LocalDateTime debut, LocalDateTime fin) {
        List<DonneesCapteur> toutesMesures = getMesuresRuche(rucheId);
        
        return toutesMesures.stream()
            .filter(mesure -> mesure.getTimestamp().isAfter(debut) && mesure.getTimestamp().isBefore(fin))
            .collect(Collectors.toList());
    }
    
    /**
     * Récupère les mesures des dernières heures
     */
    public List<DonneesCapteur> getMesuresRecentes(String rucheId, int nombreHeures) {
        LocalDateTime maintenant = LocalDateTime.now();
        LocalDateTime debut = maintenant.minusHours(nombreHeures);
        
        return getMesuresParPeriode(rucheId, debut, maintenant);
    }
    
    /**
     * Ajoute une nouvelle mesure pour une ruche
     */
    public DonneesCapteur ajouterMesure(String rucheId, DonneesCapteur nouvelleMesure) {
        try {
            // Générer un ID unique pour la mesure
            String mesureId = UUID.randomUUID().toString();
            
            // Préparer les données au format Firebase
            Map<String, Object> mesureData = new HashMap<>();
            mesureData.put("date", nouvelleMesure.getTimestamp().toLocalDate().toString());
            mesureData.put("heure", nouvelleMesure.getTimestamp().toLocalTime().format(DateTimeFormatter.ofPattern("HH:mm:ss")));
            mesureData.put("temperature", nouvelleMesure.getTemperature());
            mesureData.put("humidity", nouvelleMesure.getHumidity());
            mesureData.put("couvercle", nouvelleMesure.getCouvercleOuvert() ? "OUVERT" : "FERME");
            
            if (nouvelleMesure.getBatterie() != null) {
                mesureData.put("batterie", nouvelleMesure.getBatterie());
            }
            if (nouvelleMesure.getSignalQualite() != null) {
                mesureData.put("signalQualite", nouvelleMesure.getSignalQualite());
            }
            
            // Sauvegarder dans Firebase
            firebaseService.setDocument("ruche/" + rucheId + "/historique", mesureId, mesureData);
            
            // Retourner la mesure créée avec l'ID
            nouvelleMesure.setId(mesureId);
            nouvelleMesure.setRucheId(rucheId);
            
            return nouvelleMesure;
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de l'ajout de la mesure", e);
        }
    }
    
    /**
     * Récupère des statistiques sur les mesures d'une ruche
     */
    public Map<String, Object> getStatistiquesMesures(String rucheId, int nombreJours) {
        LocalDateTime maintenant = LocalDateTime.now();
        LocalDateTime debut = maintenant.minusDays(nombreJours);
        
        List<DonneesCapteur> mesures = getMesuresParPeriode(rucheId, debut, maintenant);
        
        Map<String, Object> statistiques = new HashMap<>();
        statistiques.put("nombreMesures", mesures.size());
        
        if (!mesures.isEmpty()) {
            // Statistiques de température
            OptionalDouble tempMoyenne = mesures.stream()
                .filter(m -> m.getTemperature() != null)
                .mapToDouble(DonneesCapteur::getTemperature)
                .average();
            
            OptionalDouble tempMin = mesures.stream()
                .filter(m -> m.getTemperature() != null)
                .mapToDouble(DonneesCapteur::getTemperature)
                .min();
                
            OptionalDouble tempMax = mesures.stream()
                .filter(m -> m.getTemperature() != null)
                .mapToDouble(DonneesCapteur::getTemperature)
                .max();
            
            // Statistiques d'humidité
            OptionalDouble humMoyenne = mesures.stream()
                .filter(m -> m.getHumidity() != null)
                .mapToDouble(DonneesCapteur::getHumidity)
                .average();
            
            OptionalDouble humMin = mesures.stream()
                .filter(m -> m.getHumidity() != null)
                .mapToDouble(DonneesCapteur::getHumidity)
                .min();
                
            OptionalDouble humMax = mesures.stream()
                .filter(m -> m.getHumidity() != null)
                .mapToDouble(DonneesCapteur::getHumidity)
                .max();
            
            // Ajouter aux statistiques
            if (tempMoyenne.isPresent()) {
                statistiques.put("temperatureMoyenne", Math.round(tempMoyenne.getAsDouble() * 10.0) / 10.0);
                statistiques.put("temperatureMin", Math.round(tempMin.getAsDouble() * 10.0) / 10.0);
                statistiques.put("temperatureMax", Math.round(tempMax.getAsDouble() * 10.0) / 10.0);
            }
            
            if (humMoyenne.isPresent()) {
                statistiques.put("humiditeMoyenne", Math.round(humMoyenne.getAsDouble() * 10.0) / 10.0);
                statistiques.put("humiditeMin", Math.round(humMin.getAsDouble() * 10.0) / 10.0);
                statistiques.put("humiditeMax", Math.round(humMax.getAsDouble() * 10.0) / 10.0);
            }
            
            // Statistiques sur le couvercle
            long ouverturesCouvercle = mesures.stream()
                .filter(m -> m.getCouvercleOuvert() != null && m.getCouvercleOuvert())
                .count();
            
            statistiques.put("ouverturesCouvercle", ouverturesCouvercle);
            statistiques.put("pourcentageOuvertures", Math.round((double) ouverturesCouvercle / mesures.size() * 100.0));
        }
        
        return statistiques;
    }
    
    /**
     * Convertit une mesure Firebase en objet DonneesCapteur
     */
    private DonneesCapteur convertToDonneesCapteur(Map<String, Object> mesure, String rucheId) {
        DonneesCapteur donnees = new DonneesCapteur();
        donnees.setId((String) mesure.get("id"));
        donnees.setRucheId(rucheId);
        
        // Parser le timestamp depuis date et heure
        LocalDateTime timestamp = parseDateTime(mesure);
        donnees.setTimestamp(timestamp);
        
        // Convertir les valeurs
        if (mesure.get("temperature") != null) {
            donnees.setTemperature(((Number) mesure.get("temperature")).doubleValue());
        }
        
        if (mesure.get("humidity") != null) {
            donnees.setHumidity(((Number) mesure.get("humidity")).doubleValue());
        }
        
        if (mesure.get("couvercle") != null) {
            String couvercle = (String) mesure.get("couvercle");
            donnees.setCouvercleOuvert("OUVERT".equals(couvercle));
        }
        
        if (mesure.get("batterie") != null) {
            donnees.setBatterie(((Number) mesure.get("batterie")).intValue());
        }
        
        if (mesure.get("signalQualite") != null) {
            donnees.setSignalQualite(((Number) mesure.get("signalQualite")).intValue());
        }
        
        return donnees;
    }
    
    /**
     * Parse la date et l'heure depuis les champs Firebase
     */
    private LocalDateTime parseDateTime(Map<String, Object> mesure) {
        try {
            String date = (String) mesure.get("date");
            String heure = (String) mesure.get("heure");
            
            if (date != null && heure != null) {
                return LocalDateTime.parse(date + "T" + heure);
            }
            
            // Fallback pour d'anciens formats
            return LocalDateTime.now();
        } catch (Exception e) {
            return LocalDateTime.now();
        }
    }
}
