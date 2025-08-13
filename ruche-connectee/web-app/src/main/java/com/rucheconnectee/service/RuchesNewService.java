package com.rucheconnectee.service;

import com.rucheconnectee.model.RuchesNew;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeoutException;

/**
 * Service CRUD pour la collection "RuchesNew" dans Firebase Realtime Database.
 */
@Service
@ConditionalOnProperty(name = "firebase.project-id")
public class RuchesNewService {

    private static final String COLLECTION = "RuchesNew";

    @Autowired
    private FirebaseService firebaseService;

    public List<RuchesNew> findAll() {
        try {
            List<Map<String, Object>> docs = firebaseService.getAllDocuments(COLLECTION);
            List<RuchesNew> result = new ArrayList<>();
            for (Map<String, Object> doc : docs) {
                result.add(documentToModel((String) doc.get("id"), doc));
            }
            return result;
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la récupération de la liste RuchesNew", e);
        }
    }

    public RuchesNew findById(String id) {
        try {
            Map<String, Object> doc = firebaseService.getDocument(COLLECTION, id);
            if (doc == null) return null;
            return documentToModel(id, doc);
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la récupération RuchesNew", e);
        }
    }

    public RuchesNew create(RuchesNew ruche) {
        try {
            String id = firebaseService.addDocument(COLLECTION, modelToMap(ruche));
            ruche.setId(id);
            return ruche;
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la création RuchesNew", e);
        }
    }

    public RuchesNew update(String id, RuchesNew ruche) {
        try {
            firebaseService.updateDocument(COLLECTION, id, modelToMap(ruche));
            ruche.setId(id);
            return ruche;
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la mise à jour RuchesNew", e);
        }
    }

    public void delete(String id) {
        try {
            firebaseService.deleteDocument(COLLECTION, id);
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la suppression RuchesNew", e);
        }
    }

    private RuchesNew documentToModel(String id, Map<String, Object> doc) {
        RuchesNew m = new RuchesNew();
        m.setId(id);
        Object nom = doc.get("nom");
        Object ruchesid = doc.get("ruchesid");
        Object description = doc.get("description");
        Object rucherId = doc.get("rucherId");
        m.setNom(nom != null ? String.valueOf(nom) : null);
        m.setRuchesid(ruchesid != null ? String.valueOf(ruchesid) : null);
        m.setDescription(description != null ? String.valueOf(description) : null);
        m.setRucherId(rucherId != null ? String.valueOf(rucherId) : null);
        return m;
    }

    private Map<String, Object> modelToMap(RuchesNew m) {
        Map<String, Object> map = new HashMap<>();
        if (m.getNom() != null) map.put("nom", m.getNom());
        if (m.getRuchesid() != null) map.put("ruchesid", m.getRuchesid());
        if (m.getDescription() != null) map.put("description", m.getDescription());
        if (m.getRucherId() != null) map.put("rucherId", m.getRucherId());
        return map;
    }
}


