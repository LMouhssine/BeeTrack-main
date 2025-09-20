package com.rucheconnectee.controller;

import com.rucheconnectee.model.DonneesCapteur;
import com.rucheconnectee.service.MesuresService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import jakarta.servlet.http.HttpSession;

import java.util.List;
import java.util.Map;

/**
 * Contrôleur web pour l'affichage des mesures dans l'interface utilisateur
 */
@Controller
public class MesuresWebController {

    @Autowired
    private MesuresService mesuresService;

    /**
     * Page principale des mesures
     */
    @GetMapping("/mesures")
    public String mesures(@RequestParam(value = "esp", required = false) String espId,
                         Model model, HttpSession session) {
        try {
            // Temporairement désactivé pour test
            // Boolean authenticated = (Boolean) session.getAttribute("authenticated");
            // if (authenticated == null || !authenticated) {
            //     return "redirect:/login";
            // }

            model.addAttribute("currentPage", "mesures");
            model.addAttribute("pageTitle", "Mesures des capteurs");
            model.addAttribute("pageSubtitle", "Surveillance en temps réel de vos ruches");

            // Ajouter les informations de l'utilisateur Firebase
            model.addAttribute("userEmail", session.getAttribute("userEmail"));
            model.addAttribute("firebaseUserId", session.getAttribute("firebaseUserId"));

            // ESP sélectionné (par défaut le principal)
            String selectedEsp = espId != null ? espId : "887D681C0610";
            model.addAttribute("selectedEsp", selectedEsp);

            // Charger les mesures pour l'ESP sélectionné ou toutes les ruches
            if (espId != null) {
                loadMesuresForSpecificEsp(model, espId);
            } else {
                loadMesuresData(model);
            }

            return "mesures";

        } catch (Exception e) {
            // En cas d'erreur critique, rediriger vers une page simple
            System.err.println("Erreur critique dans mesures: " + e.getMessage());
            e.printStackTrace();
            return "redirect:/mesures-test";
        }
    }

    /**
     * Page de détail des mesures pour une ruche spécifique
     */
    @GetMapping("/mesures/ruche/{rucheId}")
    public String mesuresRuche(@PathVariable String rucheId, 
                              @RequestParam(defaultValue = "24") int heures,
                              @RequestParam(defaultValue = "7") int jours,
                              Model model, HttpSession session) {
        // Temporairement désactivé pour test
        // Boolean authenticated = (Boolean) session.getAttribute("authenticated");
        // if (authenticated == null || !authenticated) {
        //     return "redirect:/login";
        // }
        
        model.addAttribute("currentPage", "mesures");
        model.addAttribute("pageTitle", "Mesures - Ruche " + rucheId);
        model.addAttribute("pageSubtitle", "Détail des capteurs");
        model.addAttribute("rucheId", rucheId);
        
        // Ajouter les informations de l'utilisateur Firebase
        model.addAttribute("userEmail", session.getAttribute("userEmail"));
        model.addAttribute("firebaseUserId", session.getAttribute("firebaseUserId"));
        
        try {
            DonneesCapteur derniereMesure = null;
            List<DonneesCapteur> mesuresRecentes = null;
            Map<String, Object> statistiques = new java.util.HashMap<>();
            boolean hasData = false;

            // Charger la dernière mesure de manière sécurisée
            try {
                derniereMesure = mesuresService.getDerniereMesure(rucheId);
                if (derniereMesure != null) {
                    hasData = true;
                }
            } catch (Exception e) {
                System.err.println("Erreur lors de la récupération de la dernière mesure pour " + rucheId + ": " + e.getMessage());
            }
            model.addAttribute("derniereMesure", derniereMesure);

            // Charger les mesures récentes de manière sécurisée
            try {
                mesuresRecentes = mesuresService.getMesuresRecentes(rucheId, heures);
                if (mesuresRecentes != null && !mesuresRecentes.isEmpty()) {
                    hasData = true;
                }
            } catch (Exception e) {
                System.err.println("Erreur lors de la récupération des mesures récentes pour " + rucheId + ": " + e.getMessage());
                mesuresRecentes = new java.util.ArrayList<>();
            }
            model.addAttribute("mesuresRecentes", mesuresRecentes);
            model.addAttribute("nombreHeures", heures);

            // Charger les statistiques de manière sécurisée
            try {
                statistiques = mesuresService.getStatistiquesMesures(rucheId, jours);
            } catch (Exception e) {
                System.err.println("Erreur lors de la récupération des statistiques pour " + rucheId + ": " + e.getMessage());
                statistiques.put("nombreMesures", 0);
                statistiques.put("temperatureMoyenne", null);
                statistiques.put("humiditeMoyenne", null);
            }
            model.addAttribute("statistiques", statistiques);
            model.addAttribute("nombreJours", jours);

            model.addAttribute("hasData", hasData);

        } catch (Exception e) {
            model.addAttribute("hasData", false);
            model.addAttribute("errorMessage", "Erreur lors du chargement des données: " + e.getMessage());
            model.addAttribute("derniereMesure", null);
            model.addAttribute("mesuresRecentes", new java.util.ArrayList<>());
            model.addAttribute("statistiques", new java.util.HashMap<>());
        }
        
        return "mesures_detail";
    }

    /**
     * Charge les données de mesures pour le dashboard
     */
    private void loadMesuresData(Model model) {
        // IDs des ruches connues (vous pouvez adapter cette liste)
        List<String> rucheIds = List.of("887D681C0610", "R001", "R002", "R003");
        
        try {
            // Statistiques globales
            int totalRuches = rucheIds.size();
            int ruchesAvecDonnees = 0;
            double temperatureMoyenne = 0;
            double humiditeMoyenne = 0;
            int totalMesures = 0;
            
            java.util.List<java.util.Map<String, Object>> ruchesData = new java.util.ArrayList<>();
            
            for (String rucheId : rucheIds) {
                try {
                    DonneesCapteur derniereMesure = null;
                    Map<String, Object> statistiques = new java.util.HashMap<>();

                    // Appel sécurisé pour récupérer la dernière mesure
                    try {
                        derniereMesure = mesuresService.getDerniereMesure(rucheId);
                    } catch (Exception e) {
                        System.err.println("Erreur lors de la récupération de la dernière mesure pour " + rucheId + ": " + e.getMessage());
                    }

                    // Appel sécurisé pour récupérer les statistiques
                    try {
                        statistiques = mesuresService.getStatistiquesMesures(rucheId, 7);
                    } catch (Exception e) {
                        System.err.println("Erreur lors de la récupération des statistiques pour " + rucheId + ": " + e.getMessage());
                        statistiques.put("nombreMesures", 0);
                    }

                    java.util.Map<String, Object> rucheData = new java.util.HashMap<>();
                    rucheData.put("id", rucheId);
                    rucheData.put("nom", "Ruche " + rucheId.substring(0, Math.min(rucheId.length(), 8)));
                    rucheData.put("hasData", derniereMesure != null);

                    if (derniereMesure != null) {
                        rucheData.put("temperature", derniereMesure.getTemperature());
                        rucheData.put("humidity", derniereMesure.getHumidity());
                        rucheData.put("couvercleOuvert", derniereMesure.getCouvercleOuvert());
                        rucheData.put("batterie", derniereMesure.getBatterie());
                        rucheData.put("timestamp", derniereMesure.getTimestamp());

                        if (derniereMesure.getTemperature() != null) {
                            temperatureMoyenne += derniereMesure.getTemperature();
                            ruchesAvecDonnees++;
                        }
                        if (derniereMesure.getHumidity() != null) {
                            humiditeMoyenne += derniereMesure.getHumidity();
                        }
                    } else {
                        // Données par défaut si pas de mesure
                        rucheData.put("temperature", null);
                        rucheData.put("humidity", null);
                        rucheData.put("couvercleOuvert", false);
                        rucheData.put("batterie", null);
                        rucheData.put("timestamp", null);
                    }

                    if (statistiques.get("nombreMesures") != null) {
                        rucheData.put("nombreMesures", statistiques.get("nombreMesures"));
                        totalMesures += (Integer) statistiques.get("nombreMesures");
                    } else {
                        rucheData.put("nombreMesures", 0);
                    }

                    ruchesData.add(rucheData);

                } catch (Exception e) {
                    // Ajouter la ruche même en cas d'erreur
                    System.err.println("Erreur générale pour ruche " + rucheId + ": " + e.getMessage());
                    java.util.Map<String, Object> rucheData = new java.util.HashMap<>();
                    rucheData.put("id", rucheId);
                    rucheData.put("nom", "Ruche " + rucheId.substring(0, Math.min(rucheId.length(), 8)));
                    rucheData.put("hasData", false);
                    rucheData.put("error", e.getMessage());
                    rucheData.put("temperature", null);
                    rucheData.put("humidity", null);
                    rucheData.put("couvercleOuvert", false);
                    rucheData.put("batterie", null);
                    rucheData.put("timestamp", null);
                    rucheData.put("nombreMesures", 0);
                    ruchesData.add(rucheData);
                }
            }
            
            // Calculer les moyennes
            if (ruchesAvecDonnees > 0) {
                temperatureMoyenne /= ruchesAvecDonnees;
                humiditeMoyenne /= ruchesAvecDonnees;
            }
            
            model.addAttribute("totalRuches", totalRuches);
            model.addAttribute("ruchesAvecDonnees", ruchesAvecDonnees);
            model.addAttribute("temperatureMoyenne", Math.round(temperatureMoyenne * 10.0) / 10.0);
            model.addAttribute("humiditeMoyenne", Math.round(humiditeMoyenne * 10.0) / 10.0);
            model.addAttribute("totalMesures", totalMesures);
            model.addAttribute("ruches", ruchesData);
            model.addAttribute("hasGlobalData", true);
            
        } catch (Exception e) {
            model.addAttribute("hasGlobalData", false);
            model.addAttribute("globalErrorMessage", "Erreur lors du chargement des données: " + e.getMessage());
        }
    }
    
    /**
     * Charge des données par défaut en cas d'erreur Firebase
     */
    private void loadDefaultData(Model model) {
        model.addAttribute("hasGlobalData", true);
        model.addAttribute("totalRuches", 4);
        model.addAttribute("ruchesAvecDonnees", 2);
        model.addAttribute("temperatureMoyenne", 25.5);
        model.addAttribute("humiditeMoyenne", 65.0);
        model.addAttribute("totalMesures", 0);
        
        // Créer des ruches par défaut
        java.util.List<java.util.Map<String, Object>> ruchesData = new java.util.ArrayList<>();
        
        java.util.Map<String, Object> ruche1 = new java.util.HashMap<>();
        ruche1.put("id", "887D681C0610");
        ruche1.put("nom", "Ruche 887D681");
        ruche1.put("hasData", false);
        ruche1.put("error", "En attente de données Firebase");
        ruchesData.add(ruche1);
        
        java.util.Map<String, Object> ruche2 = new java.util.HashMap<>();
        ruche2.put("id", "R001");
        ruche2.put("nom", "Ruche R001");
        ruche2.put("hasData", false);
        ruche2.put("error", "Configuration Firebase requise");
        ruchesData.add(ruche2);
        
        model.addAttribute("ruches", ruchesData);
        model.addAttribute("dataSource", "Données par défaut (erreur Firebase)");
    }
    
    /**
     * Charge les mesures pour un ESP32 spécifique
     */
    private void loadMesuresForSpecificEsp(Model model, String espId) {
        try {
            DonneesCapteur derniereMesure = null;
            Map<String, Object> statistiques = new java.util.HashMap<>();

            // Charger la dernière mesure de manière sécurisée
            try {
                derniereMesure = mesuresService.getDerniereMesure(espId);
            } catch (Exception e) {
                System.err.println("Erreur lors de la récupération de la dernière mesure pour ESP " + espId + ": " + e.getMessage());
            }

            // Charger les statistiques de manière sécurisée
            try {
                if (derniereMesure != null) {
                    statistiques = mesuresService.getStatistiquesMesures(espId, 7);
                } else {
                    statistiques.put("nombreMesures", 0);
                }
            } catch (Exception e) {
                System.err.println("Erreur lors de la récupération des statistiques pour ESP " + espId + ": " + e.getMessage());
                statistiques.put("nombreMesures", 0);
            }

            if (derniereMesure != null) {
                model.addAttribute("totalRuches", 1);
                model.addAttribute("ruchesAvecDonnees", 1);
                model.addAttribute("temperatureMoyenne", derniereMesure.getTemperature());
                model.addAttribute("humiditeMoyenne", derniereMesure.getHumidity());
                model.addAttribute("totalMesures", statistiques.get("nombreMesures"));

                // Créer les données pour cet ESP
                java.util.List<java.util.Map<String, Object>> ruchesData = new java.util.ArrayList<>();
                java.util.Map<String, Object> espData = new java.util.HashMap<>();
                espData.put("id", espId);
                espData.put("nom", "ESP32 " + espId.substring(0, Math.min(espId.length(), 8)));
                espData.put("hasData", true);
                espData.put("temperature", derniereMesure.getTemperature());
                espData.put("humidity", derniereMesure.getHumidity());
                espData.put("couvercleOuvert", derniereMesure.getCouvercleOuvert());
                espData.put("batterie", derniereMesure.getBatterie());
                espData.put("timestamp", derniereMesure.getTimestamp());
                espData.put("nombreMesures", statistiques.get("nombreMesures"));
                ruchesData.add(espData);

                model.addAttribute("ruches", ruchesData);
                model.addAttribute("hasGlobalData", true);
                model.addAttribute("dataSource", "ESP32 " + espId);
            } else {
                // Aucune mesure pour cet ESP
                model.addAttribute("totalRuches", 1);
                model.addAttribute("ruchesAvecDonnees", 0);
                model.addAttribute("temperatureMoyenne", null);
                model.addAttribute("humiditeMoyenne", null);
                model.addAttribute("totalMesures", 0);

                java.util.List<java.util.Map<String, Object>> ruchesData = new java.util.ArrayList<>();
                java.util.Map<String, Object> espData = new java.util.HashMap<>();
                espData.put("id", espId);
                espData.put("nom", "ESP32 " + espId.substring(0, Math.min(espId.length(), 8)));
                espData.put("hasData", false);
                espData.put("error", "Aucune mesure trouvée");
                espData.put("temperature", null);
                espData.put("humidity", null);
                espData.put("couvercleOuvert", false);
                espData.put("batterie", null);
                espData.put("timestamp", null);
                espData.put("nombreMesures", 0);
                ruchesData.add(espData);

                model.addAttribute("ruches", ruchesData);
                model.addAttribute("hasGlobalData", true);
                model.addAttribute("dataSource", "ESP32 " + espId + " (aucune donnée)");
            }

        } catch (Exception e) {
            System.err.println("Erreur générale lors du chargement pour ESP " + espId + ": " + e.getMessage());
            // Ne pas re-throw l'exception, mais plutôt fournir des données par défaut
            model.addAttribute("totalRuches", 1);
            model.addAttribute("ruchesAvecDonnees", 0);
            model.addAttribute("temperatureMoyenne", null);
            model.addAttribute("humiditeMoyenne", null);
            model.addAttribute("totalMesures", 0);

            java.util.List<java.util.Map<String, Object>> ruchesData = new java.util.ArrayList<>();
            java.util.Map<String, Object> espData = new java.util.HashMap<>();
            espData.put("id", espId);
            espData.put("nom", "ESP32 " + espId.substring(0, Math.min(espId.length(), 8)));
            espData.put("hasData", false);
            espData.put("error", "Erreur lors du chargement: " + e.getMessage());
            espData.put("temperature", null);
            espData.put("humidity", null);
            espData.put("couvercleOuvert", false);
            espData.put("batterie", null);
            espData.put("timestamp", null);
            espData.put("nombreMesures", 0);
            ruchesData.add(espData);

            model.addAttribute("ruches", ruchesData);
            model.addAttribute("hasGlobalData", true);
            model.addAttribute("dataSource", "ESP32 " + espId + " (erreur)");
        }
    }
}
