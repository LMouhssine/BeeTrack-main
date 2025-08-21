package com.rucheconnectee.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Contrôleur pour les pages web manquantes
 */
@Controller
public class WebPagesController {

    @GetMapping("/alertes")
    public String alertes(Model model) {
        model.addAttribute("currentPage", "alertes");
        model.addAttribute("pageTitle", "Alertes");
        model.addAttribute("pageSubtitle", "Surveillance de vos ruches");
        return "alertes";
    }

    @GetMapping("/statistiques")
    public String statistiques(Model model) {
        model.addAttribute("currentPage", "statistiques");
        model.addAttribute("pageTitle", "Statistiques");
        model.addAttribute("pageSubtitle", "Analyse de vos données");
        return "statistiques";
    }

    @GetMapping("/profil")
    public String profil(Model model) {
        model.addAttribute("currentPage", "profil");
        model.addAttribute("pageTitle", "Mon Profil");
        model.addAttribute("pageSubtitle", "Gestion de votre compte");
        return "profil";
    }
}