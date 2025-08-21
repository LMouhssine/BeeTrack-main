package com.rucheconnectee.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import com.google.firebase.database.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.CountDownLatch;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

/**
 * Service pour les opérations Firebase (Realtime Database et Authentication).
 * Remplace l'ancien service Firestore par Realtime Database.
 */
@Service
@ConditionalOnProperty(name = "app.use-mock-data", havingValue = "false", matchIfMissing = true)
public class FirebaseService {

    @Autowired
    private FirebaseDatabase firebaseDatabase;

    @Autowired
    private FirebaseAuth firebaseAuth;

    /**
     * Récupère un document par ID dans une collection
     */
    public Map<String, Object> getDocument(String collection, String documentId) throws InterruptedException, TimeoutException {
        DatabaseReference ref = firebaseDatabase.getReference(collection).child(documentId);
        CountDownLatch latch = new CountDownLatch(1);
        @SuppressWarnings("unchecked")
        final Map<String, Object>[] result = new Map[1];
        final RuntimeException[] error = new RuntimeException[1];
        
        ref.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                if (dataSnapshot.exists()) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("id", dataSnapshot.getKey());
                    @SuppressWarnings("unchecked")
                    Map<String, Object> value = (Map<String, Object>) dataSnapshot.getValue();
                    data.putAll(value);
                    result[0] = data;
                }
                latch.countDown();
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                error[0] = new RuntimeException("Erreur lors de la récupération du document: " + databaseError.getMessage());
                latch.countDown();
            }
        });
        
        if (!latch.await(30, TimeUnit.SECONDS)) {
            throw new TimeoutException("Timeout lors de la récupération du document");
        }
        
        if (error[0] != null) {
            throw error[0];
        }
        
        return result[0];
    }

    /**
     * Récupère tous les documents d'une collection avec un filtre
     */
    public List<Map<String, Object>> getDocuments(String collection, String field, Object value) throws InterruptedException, TimeoutException {
        DatabaseReference ref = firebaseDatabase.getReference(collection);
        CountDownLatch latch = new CountDownLatch(1);
        @SuppressWarnings("unchecked")
        final List<Map<String, Object>>[] result = new List[1];
        final RuntimeException[] error = new RuntimeException[1];
        
        ref.orderByChild(field).equalTo(value.toString()).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                List<Map<String, Object>> documents = new ArrayList<>();
                for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("id", snapshot.getKey());
                    @SuppressWarnings("unchecked")
                    Map<String, Object> value = (Map<String, Object>) snapshot.getValue();
                    data.putAll(value);
                    documents.add(data);
                }
                result[0] = documents;
                latch.countDown();
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                error[0] = new RuntimeException("Erreur lors de la récupération des documents: " + databaseError.getMessage());
                latch.countDown();
            }
        });
        
        if (!latch.await(30, TimeUnit.SECONDS)) {
            throw new TimeoutException("Timeout lors de la récupération des documents");
        }
        
        if (error[0] != null) {
            throw error[0];
        }
        
        return result[0];
    }

    /**
     * Récupère tous les documents d'une collection
     */
    public List<Map<String, Object>> getAllDocuments(String collection) throws InterruptedException, TimeoutException {
        DatabaseReference ref = firebaseDatabase.getReference(collection);
        CountDownLatch latch = new CountDownLatch(1);
        @SuppressWarnings("unchecked")
        final List<Map<String, Object>>[] result = new List[1];
        final RuntimeException[] error = new RuntimeException[1];
        
        ref.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                List<Map<String, Object>> documents = new ArrayList<>();
                for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("id", snapshot.getKey());
                    @SuppressWarnings("unchecked")
                    Map<String, Object> value = (Map<String, Object>) snapshot.getValue();
                    data.putAll(value);
                    documents.add(data);
                }
                result[0] = documents;
                latch.countDown();
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                error[0] = new RuntimeException("Erreur lors de la récupération des documents: " + databaseError.getMessage());
                latch.countDown();
            }
        });
        
        if (!latch.await(30, TimeUnit.SECONDS)) {
            throw new TimeoutException("Timeout lors de la récupération des documents");
        }
        
        if (error[0] != null) {
            throw error[0];
        }
        
        return result[0];
    }

    /**
     * Crée ou met à jour un document
     */
    public void setDocument(String collection, String documentId, Map<String, Object> data) throws InterruptedException, TimeoutException {
        DatabaseReference ref = firebaseDatabase.getReference(collection).child(documentId);
        CountDownLatch latch = new CountDownLatch(1);
        final RuntimeException[] error = new RuntimeException[1];
        
        ref.setValue(data, new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                if (databaseError != null) {
                    error[0] = new RuntimeException("Erreur lors de la sauvegarde: " + databaseError.getMessage());
                }
                latch.countDown();
            }
        });
        
        if (!latch.await(30, TimeUnit.SECONDS)) {
            throw new TimeoutException("Timeout lors de la sauvegarde");
        }
        
        if (error[0] != null) {
            throw error[0];
        }
    }

    /**
     * Met à jour partiellement un document
     */
    public void updateDocument(String collection, String documentId, Map<String, Object> updates) throws InterruptedException, TimeoutException {
        DatabaseReference ref = firebaseDatabase.getReference(collection).child(documentId);
        CountDownLatch latch = new CountDownLatch(1);
        final RuntimeException[] error = new RuntimeException[1];
        
        ref.updateChildren(updates, new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                if (databaseError != null) {
                    error[0] = new RuntimeException("Erreur lors de la mise à jour: " + databaseError.getMessage());
                }
                latch.countDown();
            }
        });
        
        if (!latch.await(30, TimeUnit.SECONDS)) {
            throw new TimeoutException("Timeout lors de la mise à jour");
        }
        
        if (error[0] != null) {
            throw error[0];
        }
    }

    /**
     * Supprime un document
     */
    public void deleteDocument(String collection, String documentId) throws InterruptedException, TimeoutException {
        DatabaseReference ref = firebaseDatabase.getReference(collection).child(documentId);
        CountDownLatch latch = new CountDownLatch(1);
        final RuntimeException[] error = new RuntimeException[1];
        
        ref.removeValue(new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                if (databaseError != null) {
                    error[0] = new RuntimeException("Erreur lors de la suppression: " + databaseError.getMessage());
                }
                latch.countDown();
            }
        });
        
        if (!latch.await(30, TimeUnit.SECONDS)) {
            throw new TimeoutException("Timeout lors de la suppression");
        }
        
        if (error[0] != null) {
            throw error[0];
        }
    }

    /**
     * Ajoute un document avec un ID généré automatiquement
     */
    public String addDocument(String collection, Map<String, Object> data) throws InterruptedException, TimeoutException {
        DatabaseReference ref = firebaseDatabase.getReference(collection).push();
        CountDownLatch latch = new CountDownLatch(1);
        final String[] result = new String[1];
        final RuntimeException[] error = new RuntimeException[1];
        
        ref.setValue(data, new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                if (databaseError != null) {
                    error[0] = new RuntimeException("Erreur lors de l'ajout: " + databaseError.getMessage());
                } else {
                    result[0] = databaseReference.getKey();
                }
                latch.countDown();
            }
        });
        
        if (!latch.await(30, TimeUnit.SECONDS)) {
            throw new TimeoutException("Timeout lors de l'ajout");
        }
        
        if (error[0] != null) {
            throw error[0];
        }
        
        return result[0];
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