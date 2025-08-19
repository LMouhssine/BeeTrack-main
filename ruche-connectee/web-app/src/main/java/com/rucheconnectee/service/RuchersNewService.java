package com.rucheconnectee.service;

import com.rucheconnectee.model.RuchersNew;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeoutException;

@Service
@ConditionalOnProperty(name = "firebase.project-id")
public class RuchersNewService {

    private static final String COLLECTION = "RuchersNew";

    @Autowired
    private FirebaseService firebaseService;

    public List<RuchersNew> findAll() {
        try {
            List<Map<String, Object>> docs = firebaseService.getAllDocuments(COLLECTION);
            List<RuchersNew> result = new ArrayList<>();
            for (Map<String, Object> doc : docs) {
                result.add(documentToModel((String) doc.get("id"), doc));
            }
            return result;
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la récupération des ruchers", e);
        }
    }

    public RuchersNew findById(String id) {
        try {
            Map<String, Object> doc = firebaseService.getDocument(COLLECTION, id);
            if (doc == null) return null;
            return documentToModel(id, doc);
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la récupération du rucher", e);
        }
    }

    public RuchersNew create(RuchersNew rucher) {
        try {
            String id = firebaseService.addDocument(COLLECTION, modelToMap(rucher));
            rucher.setId(id);
            return rucher;
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la création du rucher", e);
        }
    }

    public RuchersNew update(String id, RuchersNew rucher) {
        try {
            firebaseService.updateDocument(COLLECTION, id, modelToMap(rucher));
            rucher.setId(id);
            return rucher;
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la mise à jour du rucher", e);
        }
    }

    public void delete(String id) {
        try {
            firebaseService.deleteDocument(COLLECTION, id);
        } catch (InterruptedException | TimeoutException e) {
            throw new RuntimeException("Erreur lors de la suppression du rucher", e);
        }
    }

    private RuchersNew documentToModel(String id, Map<String, Object> doc) {
        RuchersNew m = new RuchersNew();
        m.setId(id);
        Object nom = doc.get("nom");
        Object description = doc.get("description");
        m.setNom(nom != null ? String.valueOf(nom) : null);
        m.setDescription(description != null ? String.valueOf(description) : null);
        return m;
    }

    private Map<String, Object> modelToMap(RuchersNew m) {
        Map<String, Object> map = new HashMap<>();
        if (m.getNom() != null) map.put("nom", m.getNom());
        if (m.getDescription() != null) map.put("description", m.getDescription());
        return map;
    }
}







