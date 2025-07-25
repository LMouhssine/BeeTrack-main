package com.rucheconnectee.controller;

import com.rucheconnectee.model.Ruche;
import com.rucheconnectee.service.ApiculteurService;
import com.rucheconnectee.service.RucheService;
import com.rucheconnectee.service.RucherService;
import com.rucheconnectee.service.DashboardDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 * Contrôleur principal pour les pages web Thymeleaf avec services Firebase
 */
@Controller
public class WebController {

    @Autowired
    private ApiculteurService apiculteurService;
    
    @Autowired
    private RucheService rucheService;
    
    @Autowired
    private RucherService rucherService;
    
    @Autowired
    private DashboardDataService dashboardDataService;

    /**
     * Test endpoint simple
     */
    @GetMapping("/test")
    @ResponseBody
    public String test() {
        return "✅ BeeTrack Application: WebController ACTIF avec Firebase ! 🔥";
    }

    /**
     * Page d'accueil - redirige vers le dashboard si connecté, sinon vers login
     */
    @GetMapping("/")
    public String home(Authentication authentication) {
        if (authentication != null && authentication.isAuthenticated()) {
            return "redirect:/dashboard";
        }
        return "redirect:/login";
    }

    /**
     * Page de connexion
     */
    @GetMapping("/login")
    public String login(@RequestParam(value = "error", required = false) String error,
                       @RequestParam(value = "logout", required = false) String logout,
                       Model model,
                       Authentication authentication) {
        
        // Si déjà connecté, rediriger vers le dashboard
        if (authentication != null && authentication.isAuthenticated()) {
            return "redirect:/dashboard";
        }
        
        if (error != null) {
            switch (error) {
                case "notauthenticated":
                    model.addAttribute("error", "Veuillez vous connecter pour accéder à cette page.");
                    break;
                case "dashboard":
                    model.addAttribute("error", "Erreur lors du chargement du tableau de bord. Veuillez vous reconnecter.");
                    break;
                default:
                    model.addAttribute("error", "Les identifiants sont erronés. Utilisez admin@beetrackdemo.com / admin123 ou apiculteur@beetrackdemo.com / demo123");
                    break;
            }
        }
        
        if (logout != null) {
            model.addAttribute("message", "Vous avez été déconnecté avec succès.");
        }
        
        // Ajouter des informations pour le débogage
        model.addAttribute("debugInfo", "Utilisez les identifiants de démonstration ci-dessous pour vous connecter.");
        
        return "login";
    }

    /**
     * Dashboard principal
     */
    @GetMapping("/dashboard")
    public String dashboard(Model model, Authentication authentication) {
        try {
            // Vérifier l'authentification
            if (authentication == null || !authentication.isAuthenticated()) {
                return "redirect:/login?error=notauthenticated";
            }
            
            String userEmail = authentication.getName();
            System.out.println("🔍 Dashboard - Utilisateur connecté: " + userEmail);
            
            try {
                // Utiliser le nouveau service pour récupérer les données du dashboard
                Map<String, Object> stats = dashboardDataService.getDashboardStats();
                
                System.out.println("📊 Données récupérées depuis Firebase Realtime Database:");
                System.out.println("   - Ruches: " + stats.get("totalRuches"));
                System.out.println("   - Ruchers: " + stats.get("totalRuchers"));
                System.out.println("   - Ruches en service: " + stats.get("ruchesEnService"));
                System.out.println("   - Alertes: " + stats.get("alertesActives"));
                
                // Ajouter les données au modèle
                model.addAttribute("totalRuches", stats.get("totalRuches"));
                model.addAttribute("totalRuchers", stats.get("totalRuchers"));
                model.addAttribute("ruchesEnService", stats.get("ruchesEnService"));
                model.addAttribute("alertesActives", stats.get("alertesActives"));
                model.addAttribute("ruches", stats.get("ruches"));
                model.addAttribute("ruchesRecentes", stats.get("ruchesRecentes"));
                model.addAttribute("mesures", stats.get("mesures"));
                
                // Ajouter les moyennes si disponibles
                if (stats.containsKey("temperatureMoyenne")) {
                    model.addAttribute("temperatureMoyenne", stats.get("temperatureMoyenne"));
                }
                if (stats.containsKey("humiditeMoyenne")) {
                    model.addAttribute("humiditeMoyenne", stats.get("humiditeMoyenne"));
                }
                
                // Essayer de récupérer l'apiculteur pour les informations utilisateur
                try {
                    var apiculteur = apiculteurService.getApiculteurByEmail(userEmail);
                    if (apiculteur == null) {
                        apiculteur = apiculteurService.getApiculteurByEmail("jean.dupont@email.com");
                    }
                    model.addAttribute("apiculteur", apiculteur);
                } catch (Exception e) {
                    System.err.println("⚠️ Erreur récupération apiculteur: " + e.getMessage());
                    model.addAttribute("apiculteur", null);
                }
                
            } catch (Exception dataException) {
                System.err.println("⚠️ Erreur de récupération des données Firebase: " + dataException.getMessage());
                // Valeurs par défaut en cas d'erreur
                model.addAttribute("totalRuches", 0);
                model.addAttribute("totalRuchers", 0);
                model.addAttribute("ruchesEnService", 0);
                model.addAttribute("alertesActives", 0);
                model.addAttribute("ruches", List.of());
                model.addAttribute("ruchesRecentes", List.of());
                model.addAttribute("mesures", List.of());
                model.addAttribute("apiculteur", null);
                model.addAttribute("message", "Données en cours de chargement... (Erreur Firebase)");
            }
            
            // Définir les variables de layout
            model.addAttribute("currentPage", "dashboard");
            model.addAttribute("pageTitle", "Tableau de bord");
            model.addAttribute("userRole", "Apiculteur");
            
            return "dashboard";
        } catch (Exception e) {
            System.err.println("❌ Erreur critique dans le dashboard: " + e.getMessage());
            e.printStackTrace();
            
            // Au lieu de rediriger vers login, afficher le dashboard avec un message d'erreur
            model.addAttribute("totalRuches", 0);
            model.addAttribute("totalRuchers", 0);
            model.addAttribute("ruchesEnService", 0);
            model.addAttribute("alertesActives", 0);
            model.addAttribute("ruches", List.of());
            model.addAttribute("ruchesRecentes", List.of());
            model.addAttribute("apiculteur", null);
            model.addAttribute("currentPage", "dashboard");
            model.addAttribute("pageTitle", "Tableau de bord");
            model.addAttribute("userRole", "Apiculteur");
            model.addAttribute("error", "Erreur temporaire du système. Veuillez actualiser la page.");
            
            return "dashboard";
        }
    }

    /**
     * Page des ruches
     */
    @GetMapping("/ruches")
    public String ruches(Model model, Authentication authentication) {
        try {
            // Vérifier l'authentification
            if (authentication == null || !authentication.isAuthenticated()) {
                return "redirect:/login?error=notauthenticated";
            }
            
            String userEmail = authentication.getName();
            
            // Essayer de récupérer l'apiculteur par email
            var apiculteur = apiculteurService.getApiculteurByEmail(userEmail);
            
            // Si pas trouvé avec l'email de connexion, essayer avec l'email par défaut
            if (apiculteur == null) {
                apiculteur = apiculteurService.getApiculteurByEmail("jean.dupont@email.com");
            }
            
            if (apiculteur != null) {
                List<Ruche> ruches = rucheService.getRuchesByApiculteur(apiculteur.getId());
                var ruchers = rucherService.getRuchersByApiculteur(apiculteur.getId());
                
                // Calculer des statistiques pour les ruches
                long ruchesActives = ruches.stream().filter(r -> r.isActif()).count();
                long ruchesSaines = ruches.stream().filter(r -> r.isActif() && r.getTemperature() != null 
                    && r.getTemperature() >= 20 && r.getTemperature() <= 35).count();
                int alertesRuches = 0; // À implémenter avec un service d'alertes
                
                model.addAttribute("ruches", ruches);
                model.addAttribute("ruchers", ruchers);
                model.addAttribute("totalRuches", ruches.size());
                model.addAttribute("ruchesActives", ruchesActives);
                model.addAttribute("ruchesSaines", ruchesSaines);
                model.addAttribute("alertesRuches", alertesRuches);
                model.addAttribute("apiculteur", apiculteur);
            } else {
                // Données par défaut si aucun apiculteur trouvé
                model.addAttribute("ruches", List.of());
                model.addAttribute("ruchers", List.of());
                model.addAttribute("totalRuches", 0);
                model.addAttribute("ruchesActives", 0);
                model.addAttribute("ruchesSaines", 0);
                model.addAttribute("alertesRuches", 0);
                model.addAttribute("message", "Aucune ruche configurée pour votre compte.");
            }
            
            model.addAttribute("currentPage", "ruches");
            model.addAttribute("pageTitle", "Mes Ruches");
            
        } catch (Exception e) {
            model.addAttribute("error", "Erreur lors du chargement des ruches: " + e.getMessage());
        }
        
        return "ruches-list";
    }

    /**
     * Détails d'une ruche
     */
    @GetMapping("/ruches/{id}")
    public String rucheDetails(@PathVariable String id, Model model) {
        try {
            Ruche ruche = rucheService.getRucheById(id);
            
            if (ruche != null) {
                // Récupérer l'historique des données depuis Firebase
                var historique = rucheService.getHistoriqueDonnees(id, 50);
                
                model.addAttribute("ruche", ruche);
                model.addAttribute("historique", historique);
                model.addAttribute("currentPage", "ruches");
                model.addAttribute("pageTitle", "Détails - " + ruche.getNom());
                
                return "ruche-details";
            } else {
                model.addAttribute("error", "Ruche non trouvée");
                return "redirect:/ruches";
            }
            
        } catch (Exception e) {
            model.addAttribute("error", "Erreur lors du chargement des détails de la ruche: " + e.getMessage());
            return "redirect:/ruches";
        }
    }

    /**
     * Page des statistiques
     */
    @GetMapping("/statistiques")
    public String statistiques(Model model) {
        try {
            // Utiliser l'utilisateur existant dans Firebase
            var apiculteur = apiculteurService.getApiculteurByEmail("jean.dupont@email.com");
            
            if (apiculteur != null) {
                List<Ruche> ruches = rucheService.getRuchesByApiculteur(apiculteur.getId());
                model.addAttribute("ruches", ruches);
                
                // Calculer des statistiques avancées
                double temperatureMoyenne = ruches.stream()
                    .filter(r -> r.getTemperature() != null)
                    .mapToDouble(r -> r.getTemperature())
                    .average()
                    .orElse(0.0);
                
                double humiditeMoyenne = ruches.stream()
                    .filter(r -> r.getHumidite() != null)
                    .mapToDouble(r -> r.getHumidite())
                    .average()
                    .orElse(0.0);
                
                model.addAttribute("temperatureMoyenne", temperatureMoyenne);
                model.addAttribute("humiditeMoyenne", humiditeMoyenne);
            }
            
            model.addAttribute("currentPage", "statistiques");
            model.addAttribute("pageTitle", "Statistiques");
            
        } catch (Exception e) {
            model.addAttribute("error", "Erreur lors du chargement des statistiques: " + e.getMessage());
        }
        
        return "statistiques";
    }

    /**
     * Page de gestion des alertes
     */
    @GetMapping("/alertes")
    public String alertes(Model model, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/login";
        }

        String userEmail = authentication.getName();
        System.out.println("🚨 Alertes - Utilisateur connecté: " + userEmail);

        model.addAttribute("currentPage", "alertes");
        model.addAttribute("pageTitle", "Gestion des Alertes");
        
        return "alertes";
    }

    /**
     * Page de gestion des ruchers
     */


    /**
     * Page de profil utilisateur
     */
    @GetMapping("/profil")
    public String profil(Model model) {
        try {
            // Utiliser l'utilisateur existant dans Firebase
            var apiculteur = apiculteurService.getApiculteurByEmail("jean.dupont@email.com");
            
            if (apiculteur != null) {
                model.addAttribute("apiculteur", apiculteur);
            }
            
            model.addAttribute("currentPage", "profil");
            model.addAttribute("pageTitle", "Mon Profil");
            
        } catch (Exception e) {
            model.addAttribute("error", "Erreur lors du chargement du profil: " + e.getMessage());
        }
        
        return "profil";
    }

    /**
     * Création d'une nouvelle ruche (formulaire)
     */
    @GetMapping("/ruches/nouvelle")
    public String nouvelleRuche(Model model, Authentication authentication) {
        try {
            // Vérifier l'authentification
            if (authentication == null || !authentication.isAuthenticated()) {
                return "redirect:/login?error=notauthenticated";
            }
            
            String userEmail = authentication.getName();
            
            // Récupérer l'apiculteur
            var apiculteur = apiculteurService.getApiculteurByEmail(userEmail);
            if (apiculteur == null) {
                apiculteur = apiculteurService.getApiculteurByEmail("jean.dupont@email.com");
            }
            
            // Récupérer la liste des ruchers pour le select
            if (apiculteur != null) {
                var ruchers = rucherService.getRuchersByApiculteur(apiculteur.getId());
                model.addAttribute("ruchers", ruchers);
            } else {
                model.addAttribute("ruchers", List.of());
            }
            
            model.addAttribute("ruche", new Ruche());
            model.addAttribute("currentPage", "ruches");
            model.addAttribute("pageTitle", "Nouvelle Ruche");
            
        } catch (Exception e) {
            model.addAttribute("error", "Erreur lors du chargement du formulaire: " + e.getMessage());
            model.addAttribute("ruchers", List.of());
            model.addAttribute("ruche", new Ruche());
        }
        
        return "ruche-form";
    }

    /**
     * Traitement de la création d'une ruche
     */
    @PostMapping("/ruches/nouvelle")
    public String creerRuche(@ModelAttribute Ruche ruche,
                           @RequestParam(value = "rucherId", required = false) String rucherId,
                           RedirectAttributes redirectAttributes,
                           Authentication authentication) {
        try {
            // Vérifier l'authentification
            if (authentication == null || !authentication.isAuthenticated()) {
                return "redirect:/login?error=notauthenticated";
            }
            
            String userEmail = authentication.getName();
            
            // Récupérer l'apiculteur
            var apiculteur = apiculteurService.getApiculteurByEmail(userEmail);
            if (apiculteur == null) {
                apiculteur = apiculteurService.getApiculteurByEmail("jean.dupont@email.com");
            }
            
            if (apiculteur != null) {
                // Assigner l'apiculteur à la ruche
                ruche.setApiculteurId(apiculteur.getId());
                
                // Assigner le rucher si spécifié
                if (rucherId != null && !rucherId.isEmpty()) {
                    var rucher = rucherService.getRucherById(rucherId);
                    if (rucher != null) {
                        ruche.setRucherId(rucher.getId());
                        ruche.setRucherNom(rucher.getNom());
                    }
                }
                
                // Créer la ruche avec le service
                rucheService.createRuche(ruche);
                redirectAttributes.addFlashAttribute("message", "Ruche '" + ruche.getNom() + "' créée avec succès !");
                redirectAttributes.addFlashAttribute("messageType", "success");
                
                return "redirect:/ruches";
            } else {
                redirectAttributes.addFlashAttribute("error", "Impossible de créer la ruche : utilisateur non trouvé");
                redirectAttributes.addFlashAttribute("messageType", "danger");
            }
            
        } catch (Exception e) {
            System.err.println("Erreur lors de la création de la ruche: " + e.getMessage());
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "Erreur lors de la création de la ruche: " + e.getMessage());
            redirectAttributes.addFlashAttribute("messageType", "danger");
        }
        
        return "redirect:/ruches/nouvelle";
    }

    /**
     * Suppression d'une ruche
     */
    @PostMapping("/ruches/{id}/supprimer")
    public String supprimerRuche(@PathVariable String id, 
                                RedirectAttributes redirectAttributes) {
        try {
            // Désactiver la ruche avec le service
            rucheService.desactiverRuche(id);
            redirectAttributes.addFlashAttribute("message", "Ruche supprimée avec succès !");
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Erreur lors de la suppression de la ruche");
        }
        
        return "redirect:/ruches";
    }

}
