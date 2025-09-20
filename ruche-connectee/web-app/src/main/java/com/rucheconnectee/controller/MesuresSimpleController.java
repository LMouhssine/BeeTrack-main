package com.rucheconnectee.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Contrôleur simple pour tester la page mesures sans Firebase
 */
@Controller
public class MesuresSimpleController {

    /**
     * Page de test des mesures sans Firebase
     */
    @GetMapping("/mesures-test")
    public String mesuresTest(Model model) {
        model.addAttribute("currentPage", "mesures");
        model.addAttribute("pageTitle", "Test Mesures");
        model.addAttribute("pageSubtitle", "Page de test sans Firebase");
        
        // Données mockées simples
        model.addAttribute("hasGlobalData", true);
        model.addAttribute("totalRuches", 4);
        model.addAttribute("ruchesAvecDonnees", 2);
        model.addAttribute("temperatureMoyenne", 25.5);
        model.addAttribute("humiditeMoyenne", 65.0);
        model.addAttribute("totalMesures", 24);
        
        // Créer des ruches de test
        java.util.List<java.util.Map<String, Object>> ruchesData = new java.util.ArrayList<>();
        
        // Ruche avec données
        java.util.Map<String, Object> ruche1 = new java.util.HashMap<>();
        ruche1.put("id", "887D681C0610");
        ruche1.put("nom", "Ruche Principale");
        ruche1.put("hasData", true);
        ruche1.put("temperature", 28.8);
        ruche1.put("humidity", 56.6);
        ruche1.put("couvercleOuvert", true);
        ruche1.put("batterie", 85);
        ruche1.put("timestamp", java.time.LocalDateTime.now());
        ruchesData.add(ruche1);
        
        // Ruche avec données
        java.util.Map<String, Object> ruche2 = new java.util.HashMap<>();
        ruche2.put("id", "R001");
        ruche2.put("nom", "Ruche Jardin");
        ruche2.put("hasData", true);
        ruche2.put("temperature", 22.3);
        ruche2.put("humidity", 72.1);
        ruche2.put("couvercleOuvert", false);
        ruche2.put("batterie", 92);
        ruche2.put("timestamp", java.time.LocalDateTime.now().minusMinutes(5));
        ruchesData.add(ruche2);
        
        // Ruche sans données
        java.util.Map<String, Object> ruche3 = new java.util.HashMap<>();
        ruche3.put("id", "R002");
        ruche3.put("nom", "Ruche Verger");
        ruche3.put("hasData", false);
        ruche3.put("error", "Capteur déconnecté");
        ruchesData.add(ruche3);
        
        // Ruche sans données
        java.util.Map<String, Object> ruche4 = new java.util.HashMap<>();
        ruche4.put("id", "R003");
        ruche4.put("nom", "Ruche Prairie");
        ruche4.put("hasData", false);
        ruche4.put("error", "En attente de configuration");
        ruchesData.add(ruche4);
        
        model.addAttribute("ruches", ruchesData);
        
        return "mesures";
    }
}
