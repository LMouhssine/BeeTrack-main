package com.rucheconnectee.service;

import com.google.firebase.database.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

/**
 * Service spécialisé pour récupérer les données du dashboard depuis Firebase Realtime Database
 */
@Service
@ConditionalOnProperty(name = "firebase.project-id")
public class DashboardDataService {

    @Autowired
    private FirebaseDatabase firebaseDatabase;

    /**
     * Récupère les statistiques globales pour le dashboard
     */
    public Map<String, Object> getDashboardStats() throws InterruptedException, TimeoutException {
        Map<String, Object> stats = new HashMap<>();
        
        try {
            // Récupérer les données des ruches
            List<Map<String, Object>> ruches = getAllRuches();
            List<Map<String, Object>> ruchers = getAllRuchers();
            List<Map<String, Object>> mesures = getLatestMesures();
            
            // Calculer les statistiques
            stats.put("totalRuches", ruches.size());
            stats.put("totalRuchers", ruchers.size());
            stats.put("ruchesEnService", ruches.stream().filter(r -> Boolean.TRUE.equals(r.get("actif"))).count());
            stats.put("alertesActives", calculateAlertes(mesures));
            stats.put("ruches", ruches);
            stats.put("ruchesRecentes", ruches.stream().limit(5).toList());
            stats.put("mesures", mesures);
            
            // Calculer les moyennes des mesures
            if (!mesures.isEmpty()) {
                double tempMoyenne = mesures.stream()
                    .filter(m -> m.get("temperature") != null)
                    .mapToDouble(m -> ((Number) m.get("temperature")).doubleValue())
                    .average()
                    .orElse(0.0);
                
                double humiditeMoyenne = mesures.stream()
                    .filter(m -> m.get("humidite") != null)
                    .mapToDouble(m -> ((Number) m.get("humidite")).doubleValue())
                    .average()
                    .orElse(0.0);
                
                stats.put("temperatureMoyenne", tempMoyenne);
                stats.put("humiditeMoyenne", humiditeMoyenne);
            }
            
        } catch (Exception e) {
            System.err.println("Erreur lors de la récupération des statistiques: " + e.getMessage());
            // Valeurs par défaut en cas d'erreur
            stats.put("totalRuches", 0);
            stats.put("totalRuchers", 0);
            stats.put("ruchesEnService", 0);
            stats.put("alertesActives", 0);
            stats.put("ruches", new ArrayList<>());
            stats.put("ruchesRecentes", new ArrayList<>());
            stats.put("mesures", new ArrayList<>());
        }
        
        return stats;
    }

    /**
     * Récupère toutes les ruches
     */
    public List<Map<String, Object>> getAllRuches() throws InterruptedException, TimeoutException {
        DatabaseReference ref = firebaseDatabase.getReference("ruches");
        CountDownLatch latch = new CountDownLatch(1);
        @SuppressWarnings("unchecked")
        final List<Map<String, Object>>[] result = new List[1];
        final RuntimeException[] error = new RuntimeException[1];
        
        ref.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                List<Map<String, Object>> ruches = new ArrayList<>();
                for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
                    Map<String, Object> ruche = new HashMap<>();
                    ruche.put("id", snapshot.getKey());
                    @SuppressWarnings("unchecked")
                    Map<String, Object> value = (Map<String, Object>) snapshot.getValue();
                    ruche.putAll(value);
                    ruches.add(ruche);
                }
                result[0] = ruches;
                latch.countDown();
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                error[0] = new RuntimeException("Erreur lors de la récupération des ruches: " + databaseError.getMessage());
                latch.countDown();
            }
        });
        
        if (!latch.await(30, TimeUnit.SECONDS)) {
            throw new TimeoutException("Timeout lors de la récupération des ruches");
        }
        
        if (error[0] != null) {
            throw error[0];
        }
        
        return result[0];
    }

    /**
     * Récupère tous les ruchers
     */
    public List<Map<String, Object>> getAllRuchers() throws InterruptedException, TimeoutException {
        DatabaseReference ref = firebaseDatabase.getReference("ruchers");
        CountDownLatch latch = new CountDownLatch(1);
        @SuppressWarnings("unchecked")
        final List<Map<String, Object>>[] result = new List[1];
        final RuntimeException[] error = new RuntimeException[1];
        
        ref.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                List<Map<String, Object>> ruchers = new ArrayList<>();
                for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
                    Map<String, Object> rucher = new HashMap<>();
                    rucher.put("id", snapshot.getKey());
                    @SuppressWarnings("unchecked")
                    Map<String, Object> value = (Map<String, Object>) snapshot.getValue();
                    rucher.putAll(value);
                    ruchers.add(rucher);
                }
                result[0] = ruchers;
                latch.countDown();
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                error[0] = new RuntimeException("Erreur lors de la récupération des ruchers: " + databaseError.getMessage());
                latch.countDown();
            }
        });
        
        if (!latch.await(30, TimeUnit.SECONDS)) {
            throw new TimeoutException("Timeout lors de la récupération des ruchers");
        }
        
        if (error[0] != null) {
            throw error[0];
        }
        
        return result[0];
    }

    /**
     * Récupère les dernières mesures
     */
    public List<Map<String, Object>> getLatestMesures() throws InterruptedException, TimeoutException {
        DatabaseReference ref = firebaseDatabase.getReference("mesures");
        CountDownLatch latch = new CountDownLatch(1);
        @SuppressWarnings("unchecked")
        final List<Map<String, Object>>[] result = new List[1];
        final RuntimeException[] error = new RuntimeException[1];
        
        ref.orderByChild("timestamp").limitToLast(10).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                List<Map<String, Object>> mesures = new ArrayList<>();
                for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
                    Map<String, Object> mesure = new HashMap<>();
                    mesure.put("id", snapshot.getKey());
                    @SuppressWarnings("unchecked")
                    Map<String, Object> value = (Map<String, Object>) snapshot.getValue();
                    mesure.putAll(value);
                    mesures.add(mesure);
                }
                // Trier par timestamp décroissant
                mesures.sort((a, b) -> {
                    String timestampA = (String) a.get("timestamp");
                    String timestampB = (String) b.get("timestamp");
                    return timestampB.compareTo(timestampA);
                });
                result[0] = mesures;
                latch.countDown();
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                error[0] = new RuntimeException("Erreur lors de la récupération des mesures: " + databaseError.getMessage());
                latch.countDown();
            }
        });
        
        if (!latch.await(30, TimeUnit.SECONDS)) {
            throw new TimeoutException("Timeout lors de la récupération des mesures");
        }
        
        if (error[0] != null) {
            throw error[0];
        }
        
        return result[0];
    }

    /**
     * Calcule le nombre d'alertes actives basé sur les mesures
     */
    private int calculateAlertes(List<Map<String, Object>> mesures) {
        int alertes = 0;
        
        for (Map<String, Object> mesure : mesures) {
            // Vérifier la température
            if (mesure.get("temperature") != null) {
                double temp = ((Number) mesure.get("temperature")).doubleValue();
                if (temp < 15 || temp > 40) {
                    alertes++;
                }
            }
            
            // Vérifier l'humidité
            if (mesure.get("humidite") != null) {
                double humidite = ((Number) mesure.get("humidite")).doubleValue();
                if (humidite < 30 || humidite > 80) {
                    alertes++;
                }
            }
            
            // Vérifier le couvercle ouvert
            if (Boolean.TRUE.equals(mesure.get("couvercleOuvert"))) {
                alertes++;
            }
        }
        
        return alertes;
    }

    /**
     * Récupère les données pour les graphiques
     */
    public Map<String, Object> getChartData() throws InterruptedException, TimeoutException {
        Map<String, Object> chartData = new HashMap<>();
        
        try {
            List<Map<String, Object>> mesures = getLatestMesures();
            
            // Préparer les données pour les graphiques
            List<String> labels = new ArrayList<>();
            List<Double> temperatures = new ArrayList<>();
            List<Double> humidites = new ArrayList<>();
            
            for (Map<String, Object> mesure : mesures) {
                String timestamp = (String) mesure.get("timestamp");
                if (timestamp != null) {
                    // Extraire l'heure du timestamp
                    String heure = timestamp.substring(11, 16); // HH:mm
                    labels.add(heure);
                }
                
                if (mesure.get("temperature") != null) {
                    temperatures.add(((Number) mesure.get("temperature")).doubleValue());
                }
                
                if (mesure.get("humidite") != null) {
                    humidites.add(((Number) mesure.get("humidite")).doubleValue());
                }
            }
            
            chartData.put("labels", labels);
            chartData.put("temperatures", temperatures);
            chartData.put("humidites", humidites);
            
        } catch (Exception e) {
            System.err.println("Erreur lors de la récupération des données de graphiques: " + e.getMessage());
            chartData.put("labels", new ArrayList<>());
            chartData.put("temperatures", new ArrayList<>());
            chartData.put("humidites", new ArrayList<>());
        }
        
        return chartData;
    }
} 