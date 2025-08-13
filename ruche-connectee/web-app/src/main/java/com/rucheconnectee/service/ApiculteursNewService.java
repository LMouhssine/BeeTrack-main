package com.rucheconnectee.service;

import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import com.rucheconnectee.model.ApiculteursNew;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.TimeoutException;

@Service
@ConditionalOnProperty(name = "firebase.project-id")
public class ApiculteursNewService {

    private static final String COLLECTION = "ApiculteursNew";

    @Autowired
    private FirebaseService firebaseService;

    public List<ApiculteursNew> findAll() {
        try {
            List<Map<String, Object>> docs = firebaseService.getAllDocuments(COLLECTION);
            List<ApiculteursNew> result = new ArrayList<>();
            for (Map<String, Object> doc : docs) {
                result.add(documentToModel((String) doc.get("id"), doc));
            }
            return result;
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la récupération des apiculteurs", e);
        }
    }

    public ApiculteursNew findById(String id) {
        try {
            Map<String, Object> doc = firebaseService.getDocument(COLLECTION, id);
            if (doc == null) return null;
            return documentToModel(id, doc);
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la récupération de l'apiculteur", e);
        }
    }

    public ApiculteursNew findByEmail(String email) {
        try {
            List<Map<String, Object>> docs = firebaseService.getDocuments(COLLECTION, "email", email);
            if (docs == null || docs.isEmpty()) return null;
            Map<String, Object> first = docs.get(0);
            return documentToModel((String) first.get("id"), first);
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la recherche par email", e);
        }
    }

    public ApiculteursNew create(ApiculteursNew user) {
        try {
            // Créer l'utilisateur dans Firebase Auth
            UserRecord record = firebaseService.createUser(
                    user.getEmail(),
                    user.getPassword(),
                    (user.getPrenom() != null ? user.getPrenom() : "") + " " + (user.getNom() != null ? user.getNom() : "")
            );

            // Sauvegarder dans Realtime DB
            user.setId(record.getUid());
            user.setCreatedAt(System.currentTimeMillis());
            Map<String, Object> map = modelToMap(user);
            firebaseService.setDocument(COLLECTION, user.getId(), map);
            // Ne pas retourner le password
            user.setPassword(null);
            return user;
        } catch (FirebaseAuthException | InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la création de l'utilisateur", e);
        }
    }

    public ApiculteursNew update(String id, ApiculteursNew user) {
        try {
            // Mise à jour côté Auth si email, displayName ou password changent
            Map<String, Object> updatesAuth = new HashMap<>();
            if (user.getEmail() != null) updatesAuth.put("email", user.getEmail());
            String displayName = ((user.getPrenom() != null ? user.getPrenom() : "") + " " + (user.getNom() != null ? user.getNom() : "")).trim();
            if (!displayName.isBlank()) updatesAuth.put("displayName", displayName);
            if (user.getPassword() != null && !user.getPassword().isBlank()) updatesAuth.put("password", user.getPassword());
            if (!updatesAuth.isEmpty()) {
                firebaseService.updateUser(id, updatesAuth);
            }

            // Mise à jour dans Realtime DB
            firebaseService.updateDocument(COLLECTION, id, modelToMap(user));
            user.setId(id);
            user.setPassword(null);
            return user;
        } catch (FirebaseAuthException | InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la mise à jour de l'utilisateur", e);
        }
    }

    public void delete(String id) {
        try {
            // Supprimer de la DB
            firebaseService.deleteDocument(COLLECTION, id);
            // Supprimer de l'Auth
            firebaseService.deleteUser(id);
        } catch (FirebaseAuthException | InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la suppression de l'utilisateur", e);
        }
    }

    private ApiculteursNew documentToModel(String id, Map<String, Object> doc) {
        ApiculteursNew u = new ApiculteursNew();
        u.setId(id);
        Object email = doc.get("email");
        Object prenom = doc.get("prenom");
        Object nom = doc.get("nom");
        Object role = doc.get("role");
        Object createdAt = doc.get("createdAt");
        u.setEmail(email != null ? String.valueOf(email) : null);
        u.setPrenom(prenom != null ? String.valueOf(prenom) : null);
        u.setNom(nom != null ? String.valueOf(nom) : null);
        u.setRole(role != null ? String.valueOf(role) : "apiculteur");
        if (createdAt instanceof Number) {
            u.setCreatedAt(((Number) createdAt).longValue());
        }
        return u;
    }

    private Map<String, Object> modelToMap(ApiculteursNew u) {
        Map<String, Object> map = new HashMap<>();
        if (u.getEmail() != null) map.put("email", u.getEmail());
        if (u.getPrenom() != null) map.put("prenom", u.getPrenom());
        if (u.getNom() != null) map.put("nom", u.getNom());
        if (u.getRole() != null) map.put("role", u.getRole());
        if (u.getCreatedAt() != null) map.put("createdAt", u.getCreatedAt());
        return map;
    }
}


