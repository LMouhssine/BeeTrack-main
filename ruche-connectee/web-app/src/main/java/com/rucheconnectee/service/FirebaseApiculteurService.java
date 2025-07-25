package com.rucheconnectee.service;


import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import com.rucheconnectee.model.Apiculteur;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeoutException;
import java.util.stream.Collectors;

/**
 * Service pour la gestion des apiculteurs avec Firebase.
 * Reproduit la logique de l'AuthService de l'application mobile.
 * Désactivé en mode développement sans Firebase
 */
@Service
@ConditionalOnProperty(name = "firebase.project-id")
public class FirebaseApiculteurService implements ApiculteurService {

    @Autowired
    private FirebaseService firebaseService;

    private static final String COLLECTION_APICULTEURS = "apiculteurs";

    @Override
    public Apiculteur getApiculteurById(String id) throws ExecutionException, InterruptedException {
        try {
            var document = firebaseService.getDocument(COLLECTION_APICULTEURS, id);
            if (document != null) {
                return documentToApiculteur((String) document.get("id"), document);
            }
            return null;
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la récupération de l'apiculteur", e);
        }
    }

    @Override
    public Apiculteur getApiculteurByEmail(String email) throws ExecutionException, InterruptedException {
        try {
            List<Map<String, Object>> documents = firebaseService.getDocuments(COLLECTION_APICULTEURS, "email", email);
            if (!documents.isEmpty()) {
                Map<String, Object> doc = documents.get(0);
                return documentToApiculteur((String) doc.get("id"), doc);
            }
            return null;
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la récupération de l'apiculteur par email", e);
        }
    }

    @Override
    public Apiculteur getApiculteurByIdentifiant(String identifiant) throws ExecutionException, InterruptedException {
        try {
            List<Map<String, Object>> documents = firebaseService.getDocuments(COLLECTION_APICULTEURS, "identifiant", identifiant);
            if (!documents.isEmpty()) {
                Map<String, Object> doc = documents.get(0);
                return documentToApiculteur((String) doc.get("id"), doc);
            }
            return null;
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la récupération de l'apiculteur par identifiant", e);
        }
    }

    @Override
    public List<Apiculteur> getAllApiculteurs() throws ExecutionException, InterruptedException {
        try {
            List<Map<String, Object>> documents = firebaseService.getDocuments(COLLECTION_APICULTEURS, "actif", true);
            return documents.stream()
                    .map(doc -> documentToApiculteur((String) doc.get("id"), doc))
                    .collect(Collectors.toList());
        } catch (Exception e) {
            throw new RuntimeException("Erreur lors de la récupération des apiculteurs", e);
        }
    }

    @Override
    public Apiculteur createApiculteur(Apiculteur apiculteur, String password) throws ExecutionException, InterruptedException, FirebaseAuthException, TimeoutException {
        // Créer l'utilisateur dans Firebase Auth
        UserRecord userRecord = firebaseService.createUser(
                apiculteur.getEmail(),
                password,
                apiculteur.getPrenom() + " " + apiculteur.getNom()
        );

        // Préparer les données pour Firestore
        apiculteur.setId(userRecord.getUid());
        apiculteur.setCreatedAt(LocalDateTime.now());
        apiculteur.setActif(true);

        Map<String, Object> data = apiculteurToMap(apiculteur);

        // Sauvegarder dans Firestore
        firebaseService.setDocument(COLLECTION_APICULTEURS, userRecord.getUid(), data);

        return apiculteur;
    }

    @Override
    public Apiculteur updateApiculteur(String id, Apiculteur apiculteur) throws ExecutionException, InterruptedException, TimeoutException {
        Map<String, Object> updates = apiculteurToMap(apiculteur);
        firebaseService.updateDocument(COLLECTION_APICULTEURS, id, updates);
        
        apiculteur.setId(id);
        return apiculteur;
    }

    @Override
    public void desactiverApiculteur(String id) throws ExecutionException, InterruptedException, TimeoutException {
        Map<String, Object> updates = new HashMap<>();
        updates.put("actif", false);
        firebaseService.updateDocument(COLLECTION_APICULTEURS, id, updates);
    }

    @Override
    public void deleteApiculteur(String id) throws ExecutionException, InterruptedException, FirebaseAuthException, TimeoutException {
        // Supprimer de Firestore
        firebaseService.deleteDocument(COLLECTION_APICULTEURS, id);
        
        // Supprimer de Firebase Auth
        firebaseService.deleteUser(id);
    }

    @Override
    public Apiculteur authenticateByEmail(String email) throws ExecutionException, InterruptedException {
        return getApiculteurByEmail(email);
    }

    @Override
    public String getEmailByIdentifiant(String identifiant) throws ExecutionException, InterruptedException {
        Apiculteur apiculteur = getApiculteurByIdentifiant(identifiant);
        return apiculteur != null ? apiculteur.getEmail() : null;
    }

    @Override
    public Map<String, Object> authenticateWithPassword(String email, String password) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // Vérifier d'abord si l'utilisateur existe dans Firestore
            Apiculteur apiculteur = getApiculteurByEmail(email);
            if (apiculteur == null) {
                result.put("error", "Aucun utilisateur trouvé avec cet email");
                return result;
            }
            
            // Tenter de récupérer l'utilisateur dans Firebase Auth
            UserRecord existingUser = null;
            try {
                existingUser = firebaseService.getUserByEmail(email);
            } catch (FirebaseAuthException e) {
                if (!"user-not-found".equals(e.getErrorCode().toString())) {
                    // Si ce n'est pas une erreur "utilisateur non trouvé", c'est une vraie erreur
                    result.put("error", "Erreur Firebase Auth: " + e.getMessage());
                    return result;
                }
            }
            
            if (existingUser != null) {
                // L'utilisateur existe dans Firebase Auth
                // Note: Firebase Admin SDK ne permet pas de vérifier le mot de passe directement
                // La vérification du mot de passe doit se faire côté client avec Firebase Auth
                result.put("message", "L'utilisateur existe dans Firebase Auth");
                result.put("user", apiculteur);
                result.put("firebaseUid", existingUser.getUid());
                result.put("note", "Vérification du mot de passe requise côté client");
                return result;
            } else {
                // L'utilisateur n'existe pas dans Firebase Auth mais existe dans Firestore
                // Cela peut arriver si l'utilisateur a été créé manuellement dans Firestore
                result.put("message", "Utilisateur trouvé dans Firestore mais absent de Firebase Auth");
                result.put("user", apiculteur);
                result.put("suggestion", "Créer l'utilisateur dans Firebase Auth côté client");
                return result;
            }
            
        } catch (ExecutionException | InterruptedException e) {
            result.put("error", "Erreur lors de l'accès à Firestore: " + e.getMessage());
            return result;
        } catch (Exception e) {
            result.put("error", "Erreur inattendue: " + e.getMessage());
            return result;
        }
    }

    /**
     * Convertit un document Firestore en objet Apiculteur
     */
    private Apiculteur documentToApiculteur(String id, Map<String, Object> data) {
        if (data == null) return null;

        Apiculteur apiculteur = new Apiculteur();
        apiculteur.setId(id);
        apiculteur.setEmail((String) data.get("email"));
        apiculteur.setNom((String) data.get("nom"));
        apiculteur.setPrenom((String) data.get("prenom"));
        apiculteur.setIdentifiant((String) data.get("identifiant"));
        apiculteur.setRole((String) data.getOrDefault("role", "apiculteur"));
        apiculteur.setTelephone((String) data.get("telephone"));
        apiculteur.setAdresse((String) data.get("adresse"));
        apiculteur.setVille((String) data.get("ville"));
        apiculteur.setCodePostal((String) data.get("codePostal"));
        apiculteur.setActif((Boolean) data.getOrDefault("actif", true));

        // Gestion de la date de création
        Object createdAt = data.get("createdAt");
        if (createdAt instanceof com.google.cloud.Timestamp) {
            apiculteur.setCreatedAt(((com.google.cloud.Timestamp) createdAt).toDate().toInstant()
                    .atZone(java.time.ZoneId.systemDefault()).toLocalDateTime());
        }

        return apiculteur;
    }

    /**
     * Convertit un objet Apiculteur en Map pour Firestore
     */
    private Map<String, Object> apiculteurToMap(Apiculteur apiculteur) {
        Map<String, Object> data = new HashMap<>();
        data.put("email", apiculteur.getEmail());
        data.put("nom", apiculteur.getNom());
        data.put("prenom", apiculteur.getPrenom());
        data.put("identifiant", apiculteur.getIdentifiant());
        data.put("role", apiculteur.getRole());
        data.put("telephone", apiculteur.getTelephone());
        data.put("adresse", apiculteur.getAdresse());
        data.put("ville", apiculteur.getVille());
        data.put("codePostal", apiculteur.getCodePostal());
        data.put("actif", apiculteur.isActif());
        
        if (apiculteur.getCreatedAt() != null) {
            data.put("createdAt", com.google.cloud.Timestamp.of(
                    java.util.Date.from(apiculteur.getCreatedAt().atZone(java.time.ZoneId.systemDefault()).toInstant())
            ));
        }

        return data;
    }
} 