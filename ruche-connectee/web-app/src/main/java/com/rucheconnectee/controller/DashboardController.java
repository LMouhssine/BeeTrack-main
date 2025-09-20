package com.rucheconnectee.controller;

import com.rucheconnectee.model.DonneesCapteur;
import com.rucheconnectee.service.MesuresService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import jakarta.servlet.http.HttpSession;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Contrôleur pour le tableau de bord principal
 */
@Controller
public class DashboardController {

    @Autowired
    private MesuresService mesuresService;

    @GetMapping("/dashboard")
    public String dashboard(Model model, HttpSession session) {
        try {
            // Temporairement désactiver l'authentification pour debug
            // Boolean authenticated = (Boolean) session.getAttribute("authenticated");
            // if (authenticated == null || !authenticated) {
            //     return "redirect:/login";
            // }
            
            model.addAttribute("currentPage", "dashboard");
            model.addAttribute("pageTitle", "Tableau de bord");
            
            // Ajouter les informations de l'utilisateur (avec valeurs par défaut)
            model.addAttribute("userEmail", session.getAttribute("userEmail") != null ? 
                session.getAttribute("userEmail") : "demo@beetrck.com");
            model.addAttribute("firebaseUserId", session.getAttribute("firebaseUserId") != null ? 
                session.getAttribute("firebaseUserId") : "demo-user");
            model.addAttribute("authType", "Demo");
            
            // Charger les données des mesures avec gestion d'erreur robuste
            try {
                loadDashboardDataSafe(model);
            } catch (Exception e) {
                System.err.println("Erreur lors du chargement des données dashboard: " + e.getMessage());
                e.printStackTrace();
                loadMockData(model);
            }
            
            return "dashboard";
            
        } catch (Exception e) {
            System.err.println("Erreur critique dans dashboard: " + e.getMessage());
            e.printStackTrace();
            
            // En cas d'erreur critique, rediriger vers une page simple
            return "redirect:/test-page";
        }
    }
    
    /**
     * Charge les données de manière sécurisée
     */
    private void loadDashboardDataSafe(Model model) {
        try {
            // Vérifier d'abord si le service existe
            if (mesuresService == null) {
                System.err.println("MesuresService n'est pas disponible");
                loadMockData(model);
                return;
            }
            
            loadDashboardData(model);
        } catch (Exception e) {
            System.err.println("Erreur dans loadDashboardDataSafe: " + e.getMessage());
            loadMockData(model);
        }
    }
    
    /**
     * Charge les vraies données depuis Firebase
     */
    private void loadDashboardData(Model model) {
        // IDs des ruches d'exemple (vous pouvez adapter selon vos ruches)
        List<String> rucheIds = List.of("887D681C0610", "R001", "R002", "R003");

        List<Map<String, Object>> ruchesData = new ArrayList<>();
        double temperatureTotal = 0;
        int ruchesActives = 0;
        int totalMesures = 0;
        boolean hasErrors = false;

        for (String rucheId : rucheIds) {
            try {
                DonneesCapteur derniereMesure = null;
                Map<String, Object> statistiques = new HashMap<>();

                // Appel sécurisé pour récupérer la dernière mesure
                try {
                    derniereMesure = mesuresService.getDerniereMesure(rucheId);
                } catch (Exception e) {
                    System.err.println("Erreur lors de la récupération de la dernière mesure pour " + rucheId + ": " + e.getMessage());
                    hasErrors = true;
                }

                // Appel sécurisé pour récupérer les statistiques
                try {
                    statistiques = mesuresService.getStatistiquesMesures(rucheId, 7);
                } catch (Exception e) {
                    System.err.println("Erreur lors de la récupération des statistiques pour " + rucheId + ": " + e.getMessage());
                    hasErrors = true;
                    statistiques.put("nombreMesures", 0);
                }

                Map<String, Object> rucheData = new HashMap<>();
                rucheData.put("id", rucheId);
                rucheData.put("nom", "Ruche " + rucheId.substring(0, Math.min(rucheId.length(), 8)));
                rucheData.put("rucherNom", "Rucher Principal");
                rucheData.put("actif", derniereMesure != null);

                if (derniereMesure != null) {
                    rucheData.put("temperature", derniereMesure.getTemperature());
                    rucheData.put("humidity", derniereMesure.getHumidity());
                    rucheData.put("couvercleOuvert", derniereMesure.getCouvercleOuvert());
                    rucheData.put("batterie", derniereMesure.getBatterie());
                    rucheData.put("derniereMesure", derniereMesure.getTimestamp());

                    if (derniereMesure.getTemperature() != null) {
                        temperatureTotal += derniereMesure.getTemperature();
                        ruchesActives++;
                    }
                } else {
                    // Données par défaut si pas de mesure
                    rucheData.put("temperature", null);
                    rucheData.put("humidity", null);
                    rucheData.put("couvercleOuvert", false);
                    rucheData.put("batterie", null);
                    rucheData.put("derniereMesure", null);
                }

                ruchesData.add(rucheData);

                // Ajouter le nombre de mesures
                if (statistiques.get("nombreMesures") != null) {
                    totalMesures += (Integer) statistiques.get("nombreMesures");
                }

            } catch (Exception e) {
                // Si une ruche pose problème, continuer avec les autres
                System.err.println("Erreur générale pour ruche " + rucheId + ": " + e.getMessage());
                hasErrors = true;

                // Ajouter une entrée vide pour cette ruche
                Map<String, Object> rucheData = new HashMap<>();
                rucheData.put("id", rucheId);
                rucheData.put("nom", "Ruche " + rucheId.substring(0, Math.min(rucheId.length(), 8)));
                rucheData.put("rucherNom", "Rucher Principal");
                rucheData.put("actif", false);
                rucheData.put("temperature", null);
                rucheData.put("humidity", null);
                rucheData.put("couvercleOuvert", false);
                rucheData.put("batterie", null);
                rucheData.put("derniereMesure", null);
                ruchesData.add(rucheData);
            }
        }

        // Calculer les statistiques
        model.addAttribute("totalRuches", rucheIds.size());
        model.addAttribute("ruchesActives", ruchesActives);
        model.addAttribute("temperatureMoyenne", ruchesActives > 0 ? Math.round(temperatureTotal / ruchesActives * 10.0) / 10.0 : null);
        model.addAttribute("totalMesures", totalMesures);
        model.addAttribute("ruches", ruchesData);

        // Message selon le statut
        if (hasErrors) {
            model.addAttribute("dataSource", "Firebase (avec erreurs partielles)");
            model.addAttribute("hasErrors", true);
        } else {
            model.addAttribute("dataSource", "Firebase Realtime Database");
            model.addAttribute("hasErrors", false);
        }
    }
    
    /**
     * Charge des données mockées en cas de problème
     */
    private void loadMockData(Model model) {
        model.addAttribute("totalRuches", 4);
        model.addAttribute("ruchesActives", 3);
        model.addAttribute("temperatureMoyenne", 25.2);
        model.addAttribute("totalMesures", 0);
        model.addAttribute("ruches", new ArrayList<>());
        model.addAttribute("dataSource", "Données mockées (erreur Firebase)");
    }
}