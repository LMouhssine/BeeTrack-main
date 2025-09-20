package com.rucheconnectee.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import jakarta.servlet.http.HttpSession;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Contrôleur dashboard simplifié sans Firebase
 */
@Controller
public class DashboardSimpleController {

    @GetMapping("/dashboard-simple")
    public String dashboardSimple(Model model, HttpSession session) {
        try {
            model.addAttribute("currentPage", "dashboard");
            model.addAttribute("pageTitle", "Tableau de bord - Mode Simple");
            
            // Informations utilisateur par défaut
            model.addAttribute("userEmail", "demo@beetrck.com");
            model.addAttribute("firebaseUserId", "demo-user");
            model.addAttribute("authType", "Demo");
            
            // Données mockées pour éviter Firebase
            loadSimpleMockData(model);
            
            return "dashboard";
            
        } catch (Exception e) {
            System.err.println("Erreur dans dashboard simple: " + e.getMessage());
            e.printStackTrace();
            return "redirect:/test-page";
        }
    }
    
    /**
     * Charge des données mockées réalistes
     */
    private void loadSimpleMockData(Model model) {
        // Statistiques globales
        model.addAttribute("totalRuches", 4);
        model.addAttribute("ruchesActives", 2);
        model.addAttribute("temperatureMoyenne", 25.5);
        model.addAttribute("totalMesures", 48);
        model.addAttribute("dataSource", "Mode démo - Données simulées");
        
        // Créer des ruches avec des données réalistes
        List<Map<String, Object>> ruchesData = new ArrayList<>();
        
        // Ruche principale avec votre ID
        Map<String, Object> ruche1 = new HashMap<>();
        ruche1.put("id", "887D681C0610");
        ruche1.put("nom", "ESP32 Principal");
        ruche1.put("rucherNom", "Rucher Principal");
        ruche1.put("actif", true);
        ruche1.put("temperature", 28.8);
        ruche1.put("humidity", 56.6);
        ruche1.put("couvercleOuvert", true);
        ruche1.put("batterie", 85);
        ruche1.put("derniereMesure", java.time.LocalDateTime.now().minusMinutes(5));
        ruchesData.add(ruche1);
        
        // Ruche secondaire active
        Map<String, Object> ruche2 = new HashMap<>();
        ruche2.put("id", "R001");
        ruche2.put("nom", "ESP32 Jardin");
        ruche2.put("rucherNom", "Rucher Secondaire");
        ruche2.put("actif", true);
        ruche2.put("temperature", 22.3);
        ruche2.put("humidity", 72.1);
        ruche2.put("couvercleOuvert", false);
        ruche2.put("batterie", 92);
        ruche2.put("derniereMesure", java.time.LocalDateTime.now().minusMinutes(12));
        ruchesData.add(ruche2);
        
        // Ruches inactives
        Map<String, Object> ruche3 = new HashMap<>();
        ruche3.put("id", "R002");
        ruche3.put("nom", "ESP32 Verger");
        ruche3.put("rucherNom", "Rucher Verger");
        ruche3.put("actif", false);
        ruche3.put("temperature", null);
        ruche3.put("humidity", null);
        ruche3.put("derniereMesure", null);
        ruchesData.add(ruche3);
        
        Map<String, Object> ruche4 = new HashMap<>();
        ruche4.put("id", "R003");
        ruche4.put("nom", "ESP32 Prairie");
        ruche4.put("rucherNom", "Rucher Prairie");
        ruche4.put("actif", false);
        ruche4.put("temperature", null);
        ruche4.put("humidity", null);
        ruche4.put("derniereMesure", null);
        ruchesData.add(ruche4);
        
        model.addAttribute("ruches", ruchesData);
    }
}
