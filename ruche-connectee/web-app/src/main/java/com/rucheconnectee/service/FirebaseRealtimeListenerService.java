package com.rucheconnectee.service;

import com.google.firebase.database.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Service de surveillance en temps réel des données Firebase Realtime Database
 */
@Service
@ConditionalOnProperty(name = "firebase.project-id")
public class FirebaseRealtimeListenerService {

    @Autowired
    private FirebaseDatabase firebaseDatabase;

    @Autowired
    private NotificationService notificationService;

    // Map des listeners actifs par ruche
    private final Map<String, ValueEventListener> listeners = new ConcurrentHashMap<>();

    @PostConstruct
    public void initialize() {
        System.out.println("🚀 Initialisation du service de surveillance Firebase Realtime Database");
        demarrerSurveillanceGenerale();
    }

    @PreDestroy
    public void cleanup() {
        System.out.println("🛑 Arrêt du service de surveillance Firebase");
        arreterToutesSurveillances();
    }

    /**
     * Démarre la surveillance générale des mesures
     */
    public void demarrerSurveillanceGenerale() {
        DatabaseReference mesuresRef = firebaseDatabase.getReference("mesures");
        
        ValueEventListener listener = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                for (DataSnapshot mesureSnapshot : dataSnapshot.getChildren()) {
                    Map<String, Object> mesure = (Map<String, Object>) mesureSnapshot.getValue();
                    if (mesure != null) {
                        traiterNouvelleMesure(mesureSnapshot.getKey(), mesure);
                    }
                }
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                System.err.println("❌ Erreur de surveillance Firebase: " + databaseError.getMessage());
            }
        };

        mesuresRef.addValueEventListener(listener);
        listeners.put("mesures_generales", listener);
        
        System.out.println("✅ Surveillance générale des mesures démarrée");
    }

    /**
     * Démarre la surveillance spécifique d'une ruche
     */
    public void demarrerSurveillanceRuche(String rucheId) {
        if (listeners.containsKey(rucheId)) {
            System.out.println("⚠️ Surveillance déjà active pour la ruche: " + rucheId);
            return;
        }

        Query rucheRef = firebaseDatabase.getReference("mesures")
                .orderByChild("rucheId")
                .equalTo(rucheId);

        ValueEventListener listener = new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                for (DataSnapshot mesureSnapshot : dataSnapshot.getChildren()) {
                    Map<String, Object> mesure = (Map<String, Object>) mesureSnapshot.getValue();
                    if (mesure != null) {
                        traiterNouvelleMesure(rucheId, mesure);
                    }
                }
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                System.err.println("❌ Erreur de surveillance pour la ruche " + rucheId + ": " + databaseError.getMessage());
            }
        };

        rucheRef.addValueEventListener(listener);
        listeners.put(rucheId, listener);
        
        System.out.println("✅ Surveillance démarrée pour la ruche: " + rucheId);
    }

    /**
     * Arrête la surveillance d'une ruche spécifique
     */
    public void arreterSurveillanceRuche(String rucheId) {
        ValueEventListener listener = listeners.remove(rucheId);
        if (listener != null) {
            Query query = firebaseDatabase.getReference("mesures")
                    .orderByChild("rucheId")
                    .equalTo(rucheId);
            query.removeEventListener(listener);
            System.out.println("🛑 Surveillance arrêtée pour la ruche: " + rucheId);
        }
    }

    /**
     * Arrête toutes les surveillances
     */
    public void arreterToutesSurveillances() {
        for (Map.Entry<String, ValueEventListener> entry : listeners.entrySet()) {
            String key = entry.getKey();
            ValueEventListener listener = entry.getValue();
            
            if (key.equals("mesures_generales")) {
                firebaseDatabase.getReference("mesures").removeEventListener(listener);
            } else {
                Query query = firebaseDatabase.getReference("mesures")
                        .orderByChild("rucheId")
                        .equalTo(key);
                query.removeEventListener(listener);
            }
        }
        
        listeners.clear();
        System.out.println("🛑 Toutes les surveillances arrêtées");
    }

    /**
     * Traite une nouvelle mesure reçue
     */
    private void traiterNouvelleMesure(String mesureId, Map<String, Object> mesure) {
        try {
            // Vérifier si c'est un couvercle ouvert
            Boolean couvercleOuvert = (Boolean) mesure.get("couvercleOuvert");
            if (Boolean.TRUE.equals(couvercleOuvert)) {
                String rucheId = (String) mesure.get("rucheId");
                if (rucheId != null) {
                    System.out.println("🚨 Couvercle ouvert détecté pour la ruche: " + rucheId);
                    
                    // Envoyer la notification email
                    notificationService.envoyerAlerteCouvercleOuvert(rucheId, mesure);
                }
            }

            // Vérifier les seuils de température
            Double temperature = (Double) mesure.get("temperature");
            if (temperature != null) {
                String rucheId = (String) mesure.get("rucheId");
                if (rucheId != null) {
                    verifierSeuilsTemperature(rucheId, temperature, mesure);
                }
            }

            // Vérifier les seuils d'humidité
            Double humidite = (Double) mesure.get("humidite");
            if (humidite != null) {
                String rucheId = (String) mesure.get("rucheId");
                if (rucheId != null) {
                    verifierSeuilsHumidite(rucheId, humidite, mesure);
                }
            }

        } catch (Exception e) {
            System.err.println("❌ Erreur lors du traitement de la mesure: " + e.getMessage());
        }
    }

    /**
     * Vérifie les seuils de température
     */
    private void verifierSeuilsTemperature(String rucheId, Double temperature, Map<String, Object> mesure) {
        // Seuils par défaut (peuvent être configurés par ruche)
        double seuilMin = 15.0;
        double seuilMax = 35.0;

        if (temperature < seuilMin || temperature > seuilMax) {
            System.out.println("🌡️ Alerte température pour la ruche " + rucheId + 
                              ": " + temperature + "°C (seuils: " + seuilMin + "-" + seuilMax + ")");
            
            // Ici on pourrait envoyer une notification spécifique pour la température
            // notificationService.envoyerAlerteTemperature(rucheId, temperature, mesure);
        }
    }

    /**
     * Vérifie les seuils d'humidité
     */
    private void verifierSeuilsHumidite(String rucheId, Double humidite, Map<String, Object> mesure) {
        // Seuils par défaut (peuvent être configurés par ruche)
        double seuilMin = 40.0;
        double seuilMax = 70.0;

        if (humidite < seuilMin || humidite > seuilMax) {
            System.out.println("💧 Alerte humidité pour la ruche " + rucheId + 
                              ": " + humidite + "% (seuils: " + seuilMin + "-" + seuilMax + ")");
            
            // Ici on pourrait envoyer une notification spécifique pour l'humidité
            // notificationService.envoyerAlerteHumidite(rucheId, humidite, mesure);
        }
    }

    /**
     * Obtient la liste des ruches surveillées
     */
    public java.util.Set<String> obtenirRuchesSurveillees() {
        return listeners.keySet();
    }

    /**
     * Vérifie si une ruche est surveillée
     */
    public boolean estRucheSurveillee(String rucheId) {
        return listeners.containsKey(rucheId);
    }

    /**
     * Obtient le nombre de ruches surveillées
     */
    public int obtenirNombreRuchesSurveillees() {
        return listeners.size();
    }
} 