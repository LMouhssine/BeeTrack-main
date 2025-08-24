package com.rucheconnectee.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import jakarta.servlet.http.HttpSession;

/**
 * Contrôleur pour le tableau de bord principal
 */
@Controller
public class DashboardController {

    @GetMapping("/dashboard")
    public String dashboard(Model model, HttpSession session) {
        // Vérifier l'authentification Firebase
        Boolean authenticated = (Boolean) session.getAttribute("authenticated");
        if (authenticated == null || !authenticated) {
            return "redirect:/login";
        }
        
        model.addAttribute("currentPage", "dashboard");
        model.addAttribute("pageTitle", "Tableau de bord");
        
        // Ajouter les informations de l'utilisateur Firebase
        model.addAttribute("userEmail", session.getAttribute("userEmail"));
        model.addAttribute("firebaseUserId", session.getAttribute("firebaseUserId"));
        model.addAttribute("authType", "Firebase");
        
        return "dashboard";
    }
}