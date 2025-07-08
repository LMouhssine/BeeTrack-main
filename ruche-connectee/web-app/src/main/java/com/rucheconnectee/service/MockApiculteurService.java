package com.rucheconnectee.service;

import com.rucheconnectee.model.Apiculteur;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.HashMap;

/**
 * Service mock pour les apiculteurs en mode développement
 */
@Service
@Primary
@ConditionalOnProperty(name = "app.use-mock-data", havingValue = "true")
public class MockApiculteurService implements ApiculteurService {

    private final Apiculteur mockApiculteur;

    public MockApiculteurService() {
        mockApiculteur = new Apiculteur();
        mockApiculteur.setId("mock-user-1");
        mockApiculteur.setEmail("jean.dupont@email.com");
        mockApiculteur.setNom("Dupont");
        mockApiculteur.setPrenom("Jean");
        mockApiculteur.setIdentifiant("JDUP001");
        mockApiculteur.setActif(true);
        mockApiculteur.setCreatedAt(LocalDateTime.now());
    }

    @Override
    public Apiculteur getApiculteurById(String id) throws Exception {
        if ("mock-user-1".equals(id)) {
            return mockApiculteur;
        }
        return null;
    }

    @Override
    public Apiculteur getApiculteurByEmail(String email) throws Exception {
        if ("jean.dupont@email.com".equals(email)) {
            return mockApiculteur;
        }
        return null;
    }

    @Override
    public Apiculteur getApiculteurByIdentifiant(String identifiant) throws Exception {
        if ("JDUP001".equals(identifiant)) {
            return mockApiculteur;
        }
        return null;
    }

    @Override
    public List<Apiculteur> getAllApiculteurs() throws Exception {
        List<Apiculteur> apiculteurs = new ArrayList<>();
        apiculteurs.add(mockApiculteur);
        return apiculteurs;
    }

    @Override
    public Apiculteur createApiculteur(Apiculteur apiculteur, String password) throws Exception {
        apiculteur.setId(UUID.randomUUID().toString());
        apiculteur.setCreatedAt(LocalDateTime.now());
        apiculteur.setActif(true);
        return apiculteur;
    }

    @Override
    public Apiculteur updateApiculteur(String id, Apiculteur apiculteur) throws Exception {
        if ("mock-user-1".equals(id)) {
            apiculteur.setId(id);
            return apiculteur;
        }
        return null;
    }

    @Override
    public void desactiverApiculteur(String id) throws Exception {
        // Ne rien faire en mode mock
    }

    @Override
    public void deleteApiculteur(String id) throws Exception {
        // Ne rien faire en mode mock
    }

    @Override
    public Apiculteur authenticateByEmail(String email) throws Exception {
        return getApiculteurByEmail(email);
    }

    @Override
    public String getEmailByIdentifiant(String identifiant) throws Exception {
        Apiculteur apiculteur = getApiculteurByIdentifiant(identifiant);
        return apiculteur != null ? apiculteur.getEmail() : null;
    }

    @Override
    public Map<String, Object> authenticateWithPassword(String email, String password) throws Exception {
        Map<String, Object> result = new HashMap<>();
        Apiculteur apiculteur = getApiculteurByEmail(email);
        if (apiculteur != null) {
            result.put("message", "Authentification réussie en mode mock");
            result.put("user", apiculteur);
            return result;
        } else {
            result.put("error", "Utilisateur non trouvé");
            return result;
        }
    }
} 