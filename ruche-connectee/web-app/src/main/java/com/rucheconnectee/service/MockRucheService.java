package com.rucheconnectee.service;

import com.rucheconnectee.model.DonneesCapteur;
import com.rucheconnectee.model.Ruche;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

/**
 * Service mock pour les ruches en mode développement
 */
@Service
@Primary
@ConditionalOnProperty(name = "app.use-mock-data", havingValue = "true")
public class MockRucheService extends RucheService {

    private final Map<String, Ruche> ruches = new HashMap<>();
    private final Map<String, List<DonneesCapteur>> historiqueDonnees = new HashMap<>();

    public MockRucheService() {
        // Créer quelques ruches de test
        createMockRuche("R001", "Ruche 1", "mock-user-1", "RU001", true);
        createMockRuche("R002", "Ruche 2", "mock-user-1", "RU001", true);
        createMockRuche("R003", "Ruche 3", "mock-user-1", "RU002", false);
    }

    private void createMockRuche(String id, String nom, String apiculteurId, String rucherId, boolean actif) {
        Ruche ruche = new Ruche();
        ruche.setId(id);
        ruche.setNom(nom);
        ruche.setApiculteurId(apiculteurId);
        ruche.setRucherId(rucherId);
        ruche.setActif(actif);
        ruche.setCreatedAt(LocalDateTime.now().minusDays(30));
        ruche.setTemperature(25.5);
        ruche.setHumidite(65.0);
        ruche.setPoids(35.0);
        ruche.setDerniereSync(LocalDateTime.now());
        
        ruches.put(id, ruche);
        
        // Créer un historique de données mock
        List<DonneesCapteur> donnees = new ArrayList<>();
        for (int i = 0; i < 10; i++) {
            DonneesCapteur donnee = new DonneesCapteur();
            donnee.setRucheId(id);
            donnee.setTemperature(25.0 + Math.random() * 2);
            donnee.setHumidite(60.0 + Math.random() * 10);
            donnee.setPoids(35.0 + Math.random() * 5);
            donnee.setTimestamp(LocalDateTime.now().minusHours(i));
            donnees.add(donnee);
        }
        historiqueDonnees.put(id, donnees);
    }

    @Override
    public Ruche getRucheById(String id) throws ExecutionException, InterruptedException {
        return ruches.get(id);
    }

    @Override
    public List<Ruche> getRuchesByApiculteur(String apiculteurId) {
        return ruches.values().stream()
                .filter(r -> r.getApiculteurId().equals(apiculteurId))
                .toList();
    }

    @Override
    public List<DonneesCapteur> getHistoriqueDonnees(String rucheId, int limit) {
        List<DonneesCapteur> donnees = historiqueDonnees.get(rucheId);
        if (donnees == null) {
            return new ArrayList<>();
        }
        return donnees.stream().limit(limit).toList();
    }

    @Override
    public Ruche createRuche(Ruche ruche) {
        String id = "R" + (ruches.size() + 1);
        ruche.setId(id);
        ruche.setCreatedAt(LocalDateTime.now());
        ruches.put(id, ruche);
        return ruche;
    }

    @Override
    public Ruche updateRuche(String id, Ruche ruche) {
        if (ruches.containsKey(id)) {
            ruche.setId(id);
            ruches.put(id, ruche);
        }
        return ruche;
    }

    @Override
    public void deleteRuche(String id) {
        ruches.remove(id);
        historiqueDonnees.remove(id);
    }

    @Override
    public void desactiverRuche(String id) {
        Ruche ruche = ruches.get(id);
        if (ruche != null) {
            ruche.setActif(false);
            ruches.put(id, ruche);
        }
    }

    @Override
    public List<DonneesCapteur> getMesures7DerniersJours(String rucheId) throws ExecutionException, InterruptedException {
        List<DonneesCapteur> donnees = historiqueDonnees.get(rucheId);
        if (donnees == null) {
            return new ArrayList<>();
        }
        LocalDateTime dateLimite = LocalDateTime.now().minusDays(7);
        return donnees.stream()
                .filter(d -> d.getTimestamp().isAfter(dateLimite))
                .toList();
    }

    @Override
    public DonneesCapteur getDerniereMesure(String rucheId) throws ExecutionException, InterruptedException {
        List<DonneesCapteur> donnees = historiqueDonnees.get(rucheId);
        if (donnees == null || donnees.isEmpty()) {
            return null;
        }
        return donnees.get(0); // Les données sont déjà triées par date décroissante
    }
} 