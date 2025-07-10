package com.rucheconnectee.controller;

import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.Map;

/**
 * Contrôleur de débogage pour résoudre les problèmes de redirection
 */
@Controller
public class DebugController {

    /**
     * Page de débogage qui évite les redirections
     */
    @GetMapping("/debug")
    @ResponseBody
    public Map<String, Object> debug(Authentication authentication) {
        Map<String, Object> debug = new HashMap<>();
        
        debug.put("status", "OK");
        debug.put("message", "Page de débogage accessible");
        
        if (authentication != null) {
            debug.put("authenticated", authentication.isAuthenticated());
            debug.put("username", authentication.getName());
            debug.put("authorities", authentication.getAuthorities().toString());
        } else {
            debug.put("authenticated", false);
            debug.put("message", "Utilisateur non authentifié");
        }
        
        return debug;
    }

    /**
     * Dashboard simplifié sans services Firebase pour éviter les erreurs
     */
    @GetMapping("/simple-dashboard")
    public String simpleDashboard(Model model, Authentication authentication) {
        // Vérification simple de l'authentification
        if (authentication == null || !authentication.isAuthenticated()) {
            model.addAttribute("error", "Non authentifié");
            return "login";
        }
        
        // Données statiques pour éviter les problèmes Firebase
        model.addAttribute("totalRuches", 2);
        model.addAttribute("totalRuchers", 1);
        model.addAttribute("ruchesEnService", 1);
        model.addAttribute("alertesActives", 0);
        model.addAttribute("currentPage", "dashboard");
        model.addAttribute("pageTitle", "Dashboard Simple");
        model.addAttribute("userRole", "Apiculteur");
        model.addAttribute("message", "Dashboard simplifié - Firebase désactivé pour ce test");
        
        // Ajouter des données mock simples
        model.addAttribute("ruches", java.util.List.of());
        model.addAttribute("ruchesRecentes", java.util.List.of());
        
        return "dashboard";
    }

    /**
     * Login sécurisé qui évite les boucles de redirection
     */
    @GetMapping("/safe-login")
    public String safeLogin(Model model, Authentication authentication) {
        // Ne pas rediriger si déjà connecté, juste afficher un message
        if (authentication != null && authentication.isAuthenticated()) {
            model.addAttribute("message", "Vous êtes déjà connecté en tant que: " + authentication.getName());
            model.addAttribute("showLogout", true);
        }
        
        model.addAttribute("debugInfo", "Page de connexion sécurisée sans redirection automatique");
        return "login";
    }

    /**
     * Endpoint pour forcer la déconnexion
     */
    @GetMapping("/force-logout")
    @ResponseBody
    public String forceLogout() {
        return "Cliquez sur ce lien pour vous déconnecter: <a href='/logout'>Se déconnecter</a>";
    }
} 