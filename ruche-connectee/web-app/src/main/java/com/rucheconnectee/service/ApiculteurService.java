package com.rucheconnectee.service;

import com.rucheconnectee.model.Apiculteur;
import java.util.List;
import java.util.Map;

/**
 * Interface pour la gestion des apiculteurs
 */
public interface ApiculteurService {
    
    /**
     * Récupère un apiculteur par son ID
     */
    Apiculteur getApiculteurById(String id) throws Exception;

    /**
     * Récupère un apiculteur par son email
     */
    Apiculteur getApiculteurByEmail(String email) throws Exception;

    /**
     * Récupère un apiculteur par son identifiant
     */
    Apiculteur getApiculteurByIdentifiant(String identifiant) throws Exception;

    /**
     * Récupère tous les apiculteurs actifs
     */
    List<Apiculteur> getAllApiculteurs() throws Exception;

    /**
     * Crée un nouvel apiculteur
     */
    Apiculteur createApiculteur(Apiculteur apiculteur, String password) throws Exception;

    /**
     * Met à jour un apiculteur
     */
    Apiculteur updateApiculteur(String id, Apiculteur apiculteur) throws Exception;

    /**
     * Désactive un apiculteur (soft delete)
     */
    void desactiverApiculteur(String id) throws Exception;

    /**
     * Supprime définitivement un apiculteur
     */
    void deleteApiculteur(String id) throws Exception;

    /**
     * Authentifie un apiculteur avec email/mot de passe
     * Note: Cette méthode vérifie seulement l'existence dans Firestore
     * L'authentification réelle se fait côté client avec Firebase Auth
     */
    Apiculteur authenticateByEmail(String email) throws Exception;

    /**
     * Authentifie un apiculteur avec identifiant
     * Retourne l'email pour permettre la connexion Firebase Auth côté client
     */
    String getEmailByIdentifiant(String identifiant) throws Exception;

    /**
     * Authentifie un apiculteur avec email et mot de passe côté backend
     * Note: Cette méthode crée temporairement un utilisateur pour tester les identifiants
     * puis le supprime si nécessaire, ou retourne les informations si l'utilisateur existe
     */
    Map<String, Object> authenticateWithPassword(String email, String password) throws Exception;
} 