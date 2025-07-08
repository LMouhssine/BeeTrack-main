package com.rucheconnectee.service;

import com.rucheconnectee.model.Rucher;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

/**
 * Service pour la gestion des ruchers.
 * Désactivé en mode développement sans Firebase.
 */
@Service
@ConditionalOnProperty(name = "firebase.project-id")
public abstract class RucherService {

    @Autowired
    private FirebaseService firebaseService;

    private static final String COLLECTION_RUCHERS = "ruchers";

    /**
     * Récupère un rucher par son ID
     */
    public abstract Rucher getRucherById(String id);

    /**
     * Récupère tous les ruchers d'un apiculteur
     * Compatible avec les formats mobile (idApiculteur) et web (apiculteur_id)
     */
    public abstract List<Rucher> getRuchersByApiculteur(String apiculteurId);

    /**
     * Crée un nouveau rucher
     */
    public abstract Rucher createRucher(Rucher rucher);

    /**
     * Met à jour un rucher
     */
    public abstract Rucher updateRucher(String id, Rucher rucher);

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
    public abstract void deleteRucher(String id);

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
} 