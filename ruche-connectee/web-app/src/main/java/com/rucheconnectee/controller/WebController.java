package com.rucheconnectee.controller;

import com.rucheconnectee.model.Ruche;
import com.rucheconnectee.service.ApiculteurService;
import com.rucheconnectee.service.RucheService;
import com.rucheconnectee.service.RucherService;
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
            
            // Essayer de récupérer l'apiculteur par email
            var apiculteur = apiculteurService.getApiculteurByEmail(userEmail);
            
            // Si pas trouvé avec l'email de connexion, essayer avec l'email par défaut
            if (apiculteur == null) {
                apiculteur = apiculteurService.getApiculteurByEmail("jean.dupont@email.com");
                System.out.println("🔍 Fallback vers jean.dupont@email.com - Apiculteur trouvé: " + (apiculteur != null));
            }
            
            if (apiculteur == null) {
                System.out.println("❌ Aucun apiculteur trouvé pour: " + userEmail);
                // Si aucun apiculteur trouvé, créer des données de test
                model.addAttribute("totalRuches", 0);
                model.addAttribute("totalRuchers", 0);
                model.addAttribute("ruchesEnService", 0);
                model.addAttribute("alertesActives", 0);
                model.addAttribute("ruches", List.of());
                model.addAttribute("ruchesRecentes", List.of());
                model.addAttribute("message", "Bienvenue! Aucune ruche n'est encore configurée pour votre compte.");
            } else {
                System.out.println("✅ Apiculteur trouvé: " + apiculteur.getNom());
                var ruches = rucheService.getRuchesByApiculteur(apiculteur.getId());
                var ruchers = rucherService.getRuchersByApiculteur(apiculteur.getId());
                
                System.out.println("📊 Ruches trouvées: " + ruches.size());
                System.out.println("📍 Ruchers trouvés: " + ruchers.size());
                
                // Calculer les statistiques pour le dashboard
                model.addAttribute("totalRuches", ruches.size());
                model.addAttribute("totalRuchers", ruchers.size());
                model.addAttribute("ruchesEnService", ruches.stream().mapToInt(r -> r.isActif() ? 1 : 0).sum());
                model.addAttribute("alertesActives", 0); // À implémenter
                model.addAttribute("ruches", ruches); // Toutes les ruches pour le dashboard
                model.addAttribute("ruchesRecentes", ruches.stream().limit(5).toList()); // Limiter à 5 pour la sidebar
            }
            
            model.addAttribute("apiculteur", apiculteur);
            
            // Définir les variables de layout
            model.addAttribute("currentPage", "dashboard");
            model.addAttribute("pageTitle", "Tableau de bord");
            model.addAttribute("userRole", "Apiculteur");
            
            return "dashboard";
        } catch (Exception e) {
            System.err.println("❌ Erreur dans le dashboard: " + e.getMessage());
            e.printStackTrace();
            model.addAttribute("error", "Erreur lors du chargement du dashboard: " + e.getMessage());
            return "redirect:/login?error=dashboard";
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
     * Page des alertes
     */
    @GetMapping("/alertes")
    public String alertes(Model model) {
        try {
            // Utiliser l'utilisateur existant dans Firebase
            var apiculteur = apiculteurService.getApiculteurByEmail("jean.dupont@email.com");
            
            if (apiculteur != null) {
                List<Ruche> ruches = rucheService.getRuchesByApiculteur(apiculteur.getId());
                
                // Générer des alertes basées sur les données des ruches
                List<Map<String, Object>> alertes = new ArrayList<>();
                
                for (Ruche ruche : ruches) {
                    // Alerte batterie faible
                    if (ruche.getNiveauBatterie() != null && ruche.getNiveauBatterie() < 20) {
                        Map<String, Object> alerte = new HashMap<>();
                        alerte.put("type", "BATTERIE_FAIBLE");
                        alerte.put("severite", "CRITIQUE");
                        alerte.put("rucheId", ruche.getId());
                        alerte.put("rucheNom", ruche.getNom());
                        alerte.put("message", "Batterie faible (" + ruche.getNiveauBatterie() + "%)");
                        alerte.put("timestamp", LocalDateTime.now().minusMinutes(15));
                        alerte.put("couleur", "red");
                        alertes.add(alerte);
                    }
                    
                    // Alerte température anormale
                    if (ruche.getTemperature() != null) {
                        if (ruche.getTemperature() < 10 || ruche.getTemperature() > 40) {
                            Map<String, Object> alerte = new HashMap<>();
                            alerte.put("type", "TEMPERATURE_ANORMALE");
                            alerte.put("severite", "MOYENNE");
                            alerte.put("rucheId", ruche.getId());
                            alerte.put("rucheNom", ruche.getNom());
                            alerte.put("message", "Température anormale (" + ruche.getTemperature() + "°C)");
                            alerte.put("timestamp", LocalDateTime.now().minusHours(1));
                            alerte.put("couleur", "orange");
                            alertes.add(alerte);
                        }
                    }
                    
                    // Alerte humidité trop élevée
                    if (ruche.getHumidite() != null && ruche.getHumidite() > 80) {
                        Map<String, Object> alerte = new HashMap<>();
                        alerte.put("type", "HUMIDITE_ELEVEE");
                        alerte.put("severite", "FAIBLE");
                        alerte.put("rucheId", ruche.getId());
                        alerte.put("rucheNom", ruche.getNom());
                        alerte.put("message", "Humidité élevée (" + ruche.getHumidite() + "%)");
                        alerte.put("timestamp", LocalDateTime.now().minusHours(2));
                        alerte.put("couleur", "yellow");
                        alertes.add(alerte);
                    }
                    
                    // Alerte ruche inactive
                    if (!ruche.isActif()) {
                        Map<String, Object> alerte = new HashMap<>();
                        alerte.put("type", "RUCHE_INACTIVE");
                        alerte.put("severite", "MOYENNE");
                        alerte.put("rucheId", ruche.getId());
                        alerte.put("rucheNom", ruche.getNom());
                        alerte.put("message", "Ruche inactive - Pas de données reçues");
                        alerte.put("timestamp", LocalDateTime.now().minusHours(6));
                        alerte.put("couleur", "gray");
                        alertes.add(alerte);
                    }
                }
                
                // Ajouter une alerte de test si aucune alerte n'existe
                if (alertes.isEmpty()) {
                    Map<String, Object> alerte = new HashMap<>();
                    alerte.put("type", "SYSTEME_OK");
                    alerte.put("severite", "INFO");
                    alerte.put("rucheId", "system");
                    alerte.put("rucheNom", "Système");
                    alerte.put("message", "✅ Toutes les ruches fonctionnent normalement");
                    alerte.put("timestamp", LocalDateTime.now());
                    alerte.put("couleur", "green");
                    alertes.add(alerte);
                }
                
                model.addAttribute("alertes", alertes);
                model.addAttribute("nombreAlertes", alertes.size());
            }
            
        } catch (Exception e) {
            model.addAttribute("error", "Erreur lors du chargement des alertes: " + e.getMessage());
        }
        
        model.addAttribute("currentPage", "alertes");
        model.addAttribute("pageTitle", "Alertes");
        
        return "alertes";
    }

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
    public String nouvelleRuche(Model model) {
        model.addAttribute("ruche", new Ruche());
        model.addAttribute("currentPage", "ruches");
        model.addAttribute("pageTitle", "Nouvelle Ruche");
        
        return "ruche-form";
    }

    /**
     * Traitement de la création d'une ruche
     */
    @PostMapping("/ruches/nouvelle")
    public String creerRuche(@ModelAttribute Ruche ruche, 
                           RedirectAttributes redirectAttributes) {
        try {
            // Créer la ruche avec le service
            rucheService.createRuche(ruche);
            redirectAttributes.addFlashAttribute("message", "Ruche créée avec succès !");
            return "redirect:/ruches";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Erreur lors de la création de la ruche");
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
