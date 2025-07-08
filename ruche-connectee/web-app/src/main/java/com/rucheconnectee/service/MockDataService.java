package com.rucheconnectee.service;

import com.rucheconnectee.model.Apiculteur;
import com.rucheconnectee.model.Ruche;
import com.rucheconnectee.model.Rucher;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Service de données mockées pour les tests et le développement
 * Remplace temporairement Firebase/Firestore
 */
@Service
public class MockDataService {

    private final Map<String, Apiculteur> apiculteurs = new ConcurrentHashMap<>();
    private final Map<String, Ruche> ruches = new ConcurrentHashMap<>();
    private final Map<String, Rucher> ruchers = new ConcurrentHashMap<>();

    public MockDataService() {
        initializeMockData();
    }

    private void initializeMockData() {
        // Créer des apiculteurs de test
        Apiculteur demo = new Apiculteur();
        demo.setId("demo-id");
        demo.setEmail("demo@beetrack.com");
        demo.setPrenom("Demo");
        demo.setNom("User");
        demo.setTelephone("0123456789");
        demo.setCreatedAt(LocalDateTime.now().minusMonths(6));
        demo.setActif(true);
        apiculteurs.put("demo@beetrack.com", demo);

        Apiculteur admin = new Apiculteur();
        admin.setId("admin-id");
        admin.setEmail("admin@beetrack.com");
        admin.setPrenom("Admin");
        admin.setNom("Administrator");
        admin.setTelephone("0987654321");
        admin.setCreatedAt(LocalDateTime.now().minusMonths(12));
        admin.setActif(true);
        apiculteurs.put("admin@beetrack.com", admin);

        // Créer des ruchers de test
        Rucher rucher1 = new Rucher();
        rucher1.setId("rucher-1");
        rucher1.setNom("Rucher des Tilleuls");
        rucher1.setAdresse("Route de la Forêt");
        rucher1.setVille("Fontainebleau");
        rucher1.setCodePostal("77300");
        rucher1.setApiculteurId("demo-id");
        rucher1.setDateCreation(LocalDateTime.now().minusMonths(3));
        rucher1.setNombreRuches(3);
        ruchers.put("rucher-1", rucher1);

        Rucher rucher2 = new Rucher();
        rucher2.setId("rucher-2");
        rucher2.setNom("Rucher de la Prairie");
        rucher2.setAdresse("Chemin des Près");
        rucher2.setVille("Chevreuse");
        rucher2.setCodePostal("78460");
        rucher2.setApiculteurId("demo-id");
        rucher2.setDateCreation(LocalDateTime.now().minusMonths(2));
        rucher2.setNombreRuches(2);
        ruchers.put("rucher-2", rucher2);

        // Créer des ruches de test
        createMockRuche("ruche-1", "Ruche Alpha", "rucher-1", "demo-id", 22.5, 65.0, 85, true);
        createMockRuche("ruche-2", "Ruche Beta", "rucher-1", "demo-id", 24.0, 58.0, 92, true);
        createMockRuche("ruche-3", "Ruche Gamma", "rucher-2", "demo-id", 21.8, 72.0, 78, false);
        createMockRuche("ruche-4", "Ruche Delta", "rucher-2", "demo-id", 23.2, 61.0, 88, true);
        createMockRuche("ruche-5", "Ruche Epsilon", "rucher-1", "demo-id", 25.1, 55.0, 95, true);
    }

    private void createMockRuche(String id, String nom, String rucherId, String apiculteurId, 
                                 double temperature, double humidite, int batterie, boolean actif) {
        Ruche ruche = new Ruche();
        ruche.setId(id);
        ruche.setNom(nom);
        ruche.setRucherId(rucherId);
        ruche.setApiculteurId(apiculteurId);
        ruche.setTemperature(temperature);
        ruche.setHumidite(humidite);
        ruche.setNiveauBatterie(batterie);
        ruche.setActif(actif);
        ruche.setDateInstallation(LocalDateTime.now().minusWeeks(4));
        ruche.setDerniereMiseAJour(LocalDateTime.now().minusMinutes((long) (Math.random() * 120)));
        ruche.setTypeRuche("Dadant");
        ruche.setDescription("Ruche de test avec capteurs IoT");
        ruches.put(id, ruche);
    }

    // Méthodes pour récupérer les données mockées
    public Apiculteur getApiculteurByEmail(String email) {
        return apiculteurs.get(email);
    }

    public List<Ruche> getRuchesByApiculteur(String apiculteurId) {
        return ruches.values().stream()
                .filter(ruche -> apiculteurId.equals(ruche.getApiculteurId()))
                .toList();
    }

    public List<Rucher> getRuchersByApiculteur(String apiculteurId) {
        return ruchers.values().stream()
                .filter(rucher -> apiculteurId.equals(rucher.getApiculteurId()))
                .toList();
    }

    public Ruche getRucheById(String id) {
        return ruches.get(id);
    }

    public Rucher getRucherById(String id) {
        return ruchers.get(id);
    }

    public List<Map<String, Object>> getHistoriqueDonnees(String rucheId, int limit) {
        // Simuler un historique de données
        List<Map<String, Object>> historique = new ArrayList<>();
        for (int i = 0; i < limit; i++) {
            Map<String, Object> donnee = Map.of(
                "timestamp", LocalDateTime.now().minusHours(i),
                "temperature", 20.0 + Math.random() * 10,
                "humidite", 50.0 + Math.random() * 30,
                "poids", 40.0 + Math.random() * 15
            );
            historique.add(donnee);
        }
        return historique;
    }

    // Méthodes CRUD supplémentaires
    public void createRuche(Ruche ruche) {
        if (ruche.getId() == null) {
            ruche.setId("ruche-" + System.currentTimeMillis());
        }
        ruche.setDateInstallation(LocalDateTime.now());
        ruche.setDerniereMiseAJour(LocalDateTime.now());
        ruches.put(ruche.getId(), ruche);
    }

    public void desactiverRuche(String id) {
        Ruche ruche = ruches.get(id);
        if (ruche != null) {
            ruche.setActif(false);
            ruche.setDerniereMiseAJour(LocalDateTime.now());
        }
    }

    public void updateRuche(String id, Ruche ruche) {
        ruche.setId(id);
        ruche.setDerniereMiseAJour(LocalDateTime.now());
        ruches.put(id, ruche);
    }
} 