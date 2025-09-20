package com.rucheconnectee.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * Contrôleur de test pour diagnostiquer les problèmes de routing
 */
@Controller
public class TestPageController {

    /**
     * Page de test simple
     */
    @GetMapping("/test-page")
    @ResponseBody
    public String testPage() {
        return "<h1>✅ Test Page Fonctionnelle!</h1>" +
               "<p>Le routing Spring Boot fonctionne correctement.</p>" +
               "<h3>🔗 Navigation :</h3>" +
               "<ul>" +
               "<li><a href='/dashboard-simple'>Dashboard Simple (sans Firebase)</a></li>" +
               "<li><a href='/mesures-statique'>Mesures Statiques</a></li>" +
               "<li><a href='/mesures-test'>Mesures avec données mockées</a></li>" +
               "<li><a href='/mesures'>Mesures complètes (avec Firebase)</a></li>" +
               "<li><a href='/dashboard'>Dashboard complet (avec Firebase)</a></li>" +
               "</ul>" +
               "<h3>⚠️ Solutions pour erreurs :</h3>" +
               "<p>Si vous avez l'erreur <code>Cannot render error page... response has already been committed</code> :</p>" +
               "<ol>" +
               "<li>Utilisez <strong>Dashboard Simple</strong> pour éviter Firebase</li>" +
               "<li>Vérifiez les logs Spring Boot dans la console</li>" +
               "<li>L'erreur vient généralement du service Firebase qui plante</li>" +
               "</ol>";
    }


    /**
     * Page HTML statique simple sans Spring Boot
     */
    @GetMapping("/mesures-statique")
    public String mesuresStatique() {
        return "mesures_simple";
    }

    /**
     * Test du service de mesures
     */
    @GetMapping("/test-mesures-simple")
    public String testMesuresSimple(Model model) {
        model.addAttribute("currentPage", "test");
        model.addAttribute("pageTitle", "Test Mesures");
        model.addAttribute("message", "Page de test des mesures");
        
        // Test avec des données simplifiées
        model.addAttribute("hasGlobalData", true);
        model.addAttribute("totalRuches", 1);
        model.addAttribute("ruchesAvecDonnees", 1);
        model.addAttribute("temperatureMoyenne", 25.5);
        model.addAttribute("humiditeMoyenne", 65.0);
        model.addAttribute("totalMesures", 10);
        
        java.util.List<java.util.Map<String, Object>> ruchesData = new java.util.ArrayList<>();
        java.util.Map<String, Object> rucheData = new java.util.HashMap<>();
        rucheData.put("id", "887D681C0610");
        rucheData.put("nom", "Ruche Test");
        rucheData.put("hasData", true);
        rucheData.put("temperature", 25.5);
        rucheData.put("humidity", 65.0);
        rucheData.put("couvercleOuvert", false);
        rucheData.put("batterie", 85);
        ruchesData.add(rucheData);
        
        model.addAttribute("ruches", ruchesData);
        
        return "mesures";
    }
}
