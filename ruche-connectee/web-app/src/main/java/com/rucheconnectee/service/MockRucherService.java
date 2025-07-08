package com.rucheconnectee.service;

import com.rucheconnectee.model.Rucher;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service mock pour les ruchers en mode développement
 */
@Service
@Primary
@ConditionalOnProperty(name = "app.use-mock-data", havingValue = "true")
public class MockRucherService extends RucherService {

    private final Map<String, Rucher> ruchers = new HashMap<>();

    public MockRucherService() {
        // Créer quelques ruchers de test
        createMockRucher("RU001", "Rucher Principal", "mock-user-1", "48.8566,2.3522");
        createMockRucher("RU002", "Rucher Secondaire", "mock-user-1", "48.8534,2.3488");
    }

    private void createMockRucher(String id, String nom, String apiculteurId, String coordonnees) {
        Rucher rucher = new Rucher();
        rucher.setId(id);
        rucher.setNom(nom);
        rucher.setApiculteurId(apiculteurId);
        rucher.setCoordonnees(coordonnees);
        rucher.setActif(true);
        ruchers.put(id, rucher);
    }

    @Override
    public Rucher getRucherById(String id) {
        return ruchers.get(id);
    }

    @Override
    public List<Rucher> getRuchersByApiculteur(String apiculteurId) {
        return ruchers.values().stream()
                .filter(r -> r.getApiculteurId().equals(apiculteurId))
                .toList();
    }

    @Override
    public Rucher createRucher(Rucher rucher) {
        String id = "RU" + (ruchers.size() + 1);
        rucher.setId(id);
        ruchers.put(id, rucher);
        return rucher;
    }

    @Override
    public Rucher updateRucher(String id, Rucher rucher) {
        if (ruchers.containsKey(id)) {
            rucher.setId(id);
            ruchers.put(id, rucher);
        }
        return rucher;
    }

    @Override
    public void deleteRucher(String id) {
        ruchers.remove(id);
    }
} 