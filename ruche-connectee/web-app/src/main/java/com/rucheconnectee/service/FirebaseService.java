package com.rucheconnectee.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

/**
 * Service pour les opérations Firebase (Firestore et Authentication).
 * Reproduit la logique du FirebaseService de l'application mobile.
 */
@Service
public class FirebaseService {

    @Autowired
    private Firestore firestore;

    @Autowired
    private FirebaseAuth firebaseAuth;

    /**
     * Récupère un document par ID dans une collection
     */
    public DocumentSnapshot getDocument(String collection, String documentId) throws ExecutionException, InterruptedException {
        DocumentReference docRef = firestore.collection(collection).document(documentId);
        ApiFuture<DocumentSnapshot> future = docRef.get();
        return future.get();
    }

    /**
     * Récupère tous les documents d'une collection avec un filtre
     */
    public List<QueryDocumentSnapshot> getDocuments(String collection, String field, Object value) throws ExecutionException, InterruptedException {
        CollectionReference colRef = firestore.collection(collection);
        Query query = colRef.whereEqualTo(field, value);
        ApiFuture<QuerySnapshot> future = query.get();
        QuerySnapshot querySnapshot = future.get();
        return querySnapshot.getDocuments();
    }

    /**
     * Récupère tous les documents d'une collection
     */
    public List<QueryDocumentSnapshot> getAllDocuments(String collection) throws ExecutionException, InterruptedException {
        CollectionReference colRef = firestore.collection(collection);
        ApiFuture<QuerySnapshot> future = colRef.get();
        QuerySnapshot querySnapshot = future.get();
        return querySnapshot.getDocuments();
    }

    /**
     * Exécute une requête complexe avec filtres de date et tri
     * @param collection Nom de la collection
     * @param filterField Champ pour le filtre d'égalité
     * @param filterValue Valeur pour le filtre d'égalité
     * @param dateField Champ de date pour le filtre temporel
     * @param dateLimit Date limite (les documents doivent avoir une date supérieure)
     * @param orderByField Champ pour le tri
     * @param ascending True pour tri croissant, false pour décroissant
     * @return Liste des documents correspondant aux critères
     */
    public List<QueryDocumentSnapshot> getDocumentsWithDateFilter(
            String collection, 
            String filterField, 
            Object filterValue,
            String dateField,
            com.google.cloud.Timestamp dateLimit,
            String orderByField,
            boolean ascending) throws ExecutionException, InterruptedException {
        
        CollectionReference colRef = firestore.collection(collection);
        Query query = colRef
            .whereEqualTo(filterField, filterValue)
            .whereGreaterThan(dateField, dateLimit)
            .orderBy(dateField, ascending ? Query.Direction.ASCENDING : Query.Direction.DESCENDING);
        
        ApiFuture<QuerySnapshot> future = query.get();
        QuerySnapshot querySnapshot = future.get();
        return querySnapshot.getDocuments();
    }

    /**
     * Crée ou met à jour un document
     */
    public void setDocument(String collection, String documentId, Map<String, Object> data) throws ExecutionException, InterruptedException {
        DocumentReference docRef = firestore.collection(collection).document(documentId);
        ApiFuture<WriteResult> future = docRef.set(data);
        future.get();
    }

    /**
     * Met à jour partiellement un document
     */
    public void updateDocument(String collection, String documentId, Map<String, Object> updates) throws ExecutionException, InterruptedException {
        DocumentReference docRef = firestore.collection(collection).document(documentId);
        ApiFuture<WriteResult> future = docRef.update(updates);
        future.get();
    }

    /**
     * Supprime un document
     */
    public void deleteDocument(String collection, String documentId) throws ExecutionException, InterruptedException {
        DocumentReference docRef = firestore.collection(collection).document(documentId);
        ApiFuture<WriteResult> future = docRef.delete();
        future.get();
    }

    /**
     * Ajoute un document avec un ID généré automatiquement
     */
    public String addDocument(String collection, Map<String, Object> data) throws ExecutionException, InterruptedException {
        CollectionReference colRef = firestore.collection(collection);
        ApiFuture<DocumentReference> future = colRef.add(data);
        DocumentReference docRef = future.get();
        return docRef.getId();
    }

    /**
     * Vérifie si un utilisateur existe dans Firebase Auth
     */
    public UserRecord getUserByEmail(String email) throws FirebaseAuthException {
        return firebaseAuth.getUserByEmail(email);
    }

    /**
     * Crée un utilisateur dans Firebase Auth
     */
    public UserRecord createUser(String email, String password, String displayName) throws FirebaseAuthException {
        UserRecord.CreateRequest request = new UserRecord.CreateRequest()
                .setEmail(email)
                .setPassword(password)
                .setDisplayName(displayName)
                .setEmailVerified(false);
        
        return firebaseAuth.createUser(request);
    }

    /**
     * Met à jour un utilisateur dans Firebase Auth
     */
    public UserRecord updateUser(String uid, Map<String, Object> updates) throws FirebaseAuthException {
        UserRecord.UpdateRequest request = new UserRecord.UpdateRequest(uid);
        
        if (updates.containsKey("email")) {
            request.setEmail((String) updates.get("email"));
        }
        if (updates.containsKey("displayName")) {
            request.setDisplayName((String) updates.get("displayName"));
        }
        if (updates.containsKey("password")) {
            request.setPassword((String) updates.get("password"));
        }
        
        return firebaseAuth.updateUser(request);
    }

    /**
     * Supprime un utilisateur de Firebase Auth
     */
    public void deleteUser(String uid) throws FirebaseAuthException {
        firebaseAuth.deleteUser(uid);
    }

    /**
     * Vérifie un token Firebase et retourne l'UID de l'utilisateur
     */
    public String verifyIdToken(String idToken) throws FirebaseAuthException {
        return firebaseAuth.verifyIdToken(idToken).getUid();
    }
} 