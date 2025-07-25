package com.rucheconnectee.controller;

import com.rucheconnectee.model.Rucher;
import com.rucheconnectee.model.Ruche;
import com.rucheconnectee.model.DonneesCapteur;
import com.rucheconnectee.service.ApiculteurService;
import com.rucheconnectee.service.RucherService;
import com.rucheconnectee.service.RucheService;
import com.rucheconnectee.service.FirebaseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/ruchers")
public class RucherController {

    private static final Logger logger = LoggerFactory.getLogger(RucherController.class);
    
    @Autowired
    private ApiculteurService apiculteurService;
    
    @Autowired
    private RucherService rucherService;
    
    @Autowired
    private RucheService rucheService;
    


    @GetMapping
    public String listRuchers(Model model, Authentication authentication) {
        try {
            // Vérifier l'authentification
            if (authentication == null || !authentication.isAuthenticated()) {
                return "redirect:/login?error=notauthenticated";
            }
            
            String userEmail = authentication.getName();
            logger.info("🔍 Ruchers - Utilisateur connecté: {}", userEmail);
            
            // Essayer de récupérer l'apiculteur par email
            var apiculteur = apiculteurService.getApiculteurByEmail(userEmail);
            
            // Si pas trouvé avec l'email de connexion, essayer avec l'email par défaut
            if (apiculteur == null) {
                apiculteur = apiculteurService.getApiculteurByEmail("jean.dupont@email.com");
                logger.info("🔍 Fallback vers jean.dupont@email.com - Apiculteur trouvé: {}", (apiculteur != null));
            }
            
            if (apiculteur == null) {
                logger.warn("❌ Aucun apiculteur trouvé pour: {}", userEmail);
                model.addAttribute("ruchers", List.of());
                model.addAttribute("totalRuchers", 0);
                model.addAttribute("totalRuches", 0);
                model.addAttribute("message", "Aucun apiculteur trouvé pour votre compte.");
            } else {
                logger.info("✅ Apiculteur trouvé: {}", apiculteur.getNom());
                
                // Récupérer les ruchers de l'apiculteur
                List<Rucher> ruchers = rucherService.getRuchersByApiculteur(apiculteur.getId());
                logger.info("📍 Ruchers trouvés: {}", ruchers.size());
                
                // Récupérer toutes les ruches pour calculer les statistiques
                var ruches = rucheService.getRuchesByApiculteur(apiculteur.getId());
                
                // Calculer les statistiques pour chaque rucher
                for (Rucher rucher : ruchers) {
                    long ruchesCount = ruches.stream()
                        .filter(r -> r.getRucherId() != null && r.getRucherId().equals(rucher.getId()))
                        .count();
                    rucher.setNombreRuches((int) ruchesCount);
                }
                
                model.addAttribute("ruchers", ruchers);
                model.addAttribute("totalRuchers", ruchers.size());
                model.addAttribute("totalRuches", ruches.size());
                model.addAttribute("apiculteur", apiculteur);
            }
            
            // Définir les variables de layout
            model.addAttribute("currentPage", "ruchers");
            model.addAttribute("pageTitle", "Mes Ruchers");
            model.addAttribute("userRole", "Apiculteur");
            
            return "ruchers/liste";
        } catch (Exception e) {
            logger.error("❌ Erreur dans la liste des ruchers: {}", e.getMessage(), e);
            model.addAttribute("error", "Erreur lors du chargement des ruchers: " + e.getMessage());
            return "ruchers/liste";
        }
    }

    @GetMapping("/{rucherId}")
    public String detailRucher(@PathVariable String rucherId, Model model, Authentication authentication) {
        logger.info("Affichage du rucher: {}", rucherId);
        try {
            List<Ruche> ruches = rucheService.getRuchesByRucher(rucherId);
            
            // Calculer les statistiques basiques
            Map<String, Object> statistiques = Map.of(
                "totalRuches", ruches.size(),
                "temperatureMoyenne", ruches.stream()
                    .filter(r -> r.getTemperature() != null)
                    .mapToDouble(Ruche::getTemperature)
                    .average()
                    .orElse(0.0)
            );
            
            logger.info("Nombre de ruches trouvées: {}", ruches.size());
            logger.debug("Statistiques: {}", statistiques);
            
            model.addAttribute("ruches", ruches);
            model.addAttribute("statistiques", statistiques);
            return "ruchers/detail";
        } catch (Exception e) {
            logger.error("Erreur lors de la récupération du rucher: {}", e.getMessage(), e);
            model.addAttribute("error", "Erreur lors du chargement du rucher");
            return "ruchers/detail";
        }
    }

    @PostMapping
    public String ajouterRucher(@RequestParam String nom,
                               @RequestParam String adresse,
                               @RequestParam(required = false) String description,
                               @RequestParam(required = false) String surface,
                               Authentication authentication,
                               Model model) {
        try {
            String userEmail = authentication.getName();
            logger.info("🔍 Ajout rucher - Utilisateur: {}", userEmail);
            
            // Récupérer l'apiculteur
            var apiculteur = apiculteurService.getApiculteurByEmail(userEmail);
            if (apiculteur == null) {
                apiculteur = apiculteurService.getApiculteurByEmail("jean.dupont@email.com");
            }
            
            if (apiculteur == null) {
                logger.warn("❌ Aucun apiculteur trouvé pour créer le rucher");
                model.addAttribute("error", "Impossible de créer le rucher : apiculteur non trouvé");
                return "redirect:/ruchers?error=noapiculteur";
            }
            
            // Créer le nouveau rucher
            Rucher nouveauRucher = new Rucher();
            nouveauRucher.setNom(nom);
            nouveauRucher.setAdresse(adresse);
            
            // Ajouter la surface dans la description si fournie
            String descriptionComplete = description;
            if (surface != null && !surface.trim().isEmpty()) {
                descriptionComplete = (description != null ? description + "\n" : "") + "Surface: " + surface;
            }
            nouveauRucher.setDescription(descriptionComplete);
            
            nouveauRucher.setApiculteurId(apiculteur.getId());
            nouveauRucher.setDateCreation(java.time.LocalDateTime.now());
            nouveauRucher.setNombreRuches(0);
            nouveauRucher.setActif(true);
            
            // Sauvegarder le rucher
            Rucher rucherCree = rucherService.createRucher(nouveauRucher);
            String rucherId = rucherCree.getId();
            
            logger.info("✅ Rucher créé avec succès: {} (ID: {})", nom, rucherId);
            
            return "redirect:/ruchers?success=rucher-created";
            
        } catch (Exception e) {
            logger.error("❌ Erreur lors de la création du rucher: {}", e.getMessage(), e);
            model.addAttribute("error", "Erreur lors de la création du rucher: " + e.getMessage());
            return "redirect:/ruchers?error=creation-failed";
        }
    }

    @GetMapping("/{rucherId}/ruches/{rucheId}")
    public String detailRuche(@PathVariable String rucherId, 
                             @PathVariable String rucheId, 
                             Model model) {
        logger.info("Affichage de la ruche: {} du rucher: {}", rucheId, rucherId);
        try {
            List<Ruche> ruches = rucheService.getRuchesByRucher(rucherId);
            Ruche ruche = ruches.stream()
                               .filter(r -> r.getId().equals(rucheId))
                               .findFirst()
                               .orElseThrow(() -> new RuntimeException("Ruche non trouvée"));
                               
            List<DonneesCapteur> historique = rucheService.getHistoriqueDonnees(rucheId, 24); // 24 dernières mesures
            
            logger.info("Nombre de mesures dans l'historique: {}", historique.size());
            
            model.addAttribute("ruche", ruche);
            model.addAttribute("historique", historique);
            return "ruches/detail";
        } catch (Exception e) {
            logger.error("Erreur lors de la récupération de la ruche: {}", e.getMessage(), e);
            model.addAttribute("error", "Erreur lors du chargement de la ruche");
            return "ruches/detail";
        }
    }
} 