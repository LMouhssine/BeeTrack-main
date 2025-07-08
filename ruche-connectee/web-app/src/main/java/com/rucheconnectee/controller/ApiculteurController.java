package com.rucheconnectee.controller;

import com.google.firebase.auth.FirebaseAuthException;
import com.rucheconnectee.model.Apiculteur;
import com.rucheconnectee.service.ApiculteurService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

/**
 * Contrôleur REST pour la gestion des apiculteurs.
 * Désactivé en mode développement sans Firebase.
 */
@RestController
@RequestMapping("/api/apiculteurs")
@ConditionalOnProperty(name = "firebase.project-id")
@CrossOrigin(origins = "*")
public class ApiculteurController {

    @Autowired
    private ApiculteurService apiculteurService;

    /**
     * Récupère un apiculteur par son ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<Apiculteur> getApiculteur(@PathVariable String id) {
        try {
            Apiculteur apiculteur = apiculteurService.getApiculteurById(id);
            if (apiculteur != null) {
                return ResponseEntity.ok(apiculteur);
            }
            return ResponseEntity.notFound().build();
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Récupère un apiculteur par son email
     */
    @GetMapping("/email/{email}")
    public ResponseEntity<Apiculteur> getApiculteurByEmail(@PathVariable String email) {
        try {
            Apiculteur apiculteur = apiculteurService.getApiculteurByEmail(email);
            if (apiculteur != null) {
                return ResponseEntity.ok(apiculteur);
            }
            return ResponseEntity.notFound().build();
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Récupère tous les apiculteurs actifs
     */
    @GetMapping
    public ResponseEntity<List<Apiculteur>> getAllApiculteurs() {
        try {
            List<Apiculteur> apiculteurs = apiculteurService.getAllApiculteurs();
            return ResponseEntity.ok(apiculteurs);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Crée un nouvel apiculteur
     */
    @PostMapping
    public ResponseEntity<Apiculteur> createApiculteur(@Valid @RequestBody CreateApiculteurRequest request) {
        try {
            Apiculteur apiculteur = new Apiculteur();
            apiculteur.setEmail(request.getEmail());
            apiculteur.setNom(request.getNom());
            apiculteur.setPrenom(request.getPrenom());
            apiculteur.setIdentifiant(request.getIdentifiant());
            apiculteur.setTelephone(request.getTelephone());
            apiculteur.setAdresse(request.getAdresse());
            apiculteur.setVille(request.getVille());
            apiculteur.setCodePostal(request.getCodePostal());

            Apiculteur nouvelApiculteur = apiculteurService.createApiculteur(apiculteur, request.getPassword());
            return ResponseEntity.status(HttpStatus.CREATED).body(nouvelApiculteur);
        } catch (ExecutionException | InterruptedException | FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Met à jour un apiculteur
     */
    @PutMapping("/{id}")
    public ResponseEntity<Apiculteur> updateApiculteur(@PathVariable String id, @Valid @RequestBody Apiculteur apiculteur) {
        try {
            Apiculteur apiculteurMisAJour = apiculteurService.updateApiculteur(id, apiculteur);
            return ResponseEntity.ok(apiculteurMisAJour);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Désactive un apiculteur
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> desactiverApiculteur(@PathVariable String id) {
        try {
            apiculteurService.desactiverApiculteur(id);
            return ResponseEntity.noContent().build();
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Authentification par email (vérification existence)
     */
    @PostMapping("/auth/email")
    public ResponseEntity<Apiculteur> authenticateByEmail(@RequestBody Map<String, String> request) {
        try {
            String email = request.get("email");
            Apiculteur apiculteur = apiculteurService.authenticateByEmail(email);
            if (apiculteur != null) {
                return ResponseEntity.ok(apiculteur);
            }
            return ResponseEntity.notFound().build();
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Récupère l'email par identifiant (pour connexion avec identifiant)
     */
    @PostMapping("/auth/identifiant")
    public ResponseEntity<Map<String, String>> getEmailByIdentifiant(@RequestBody Map<String, String> request) {
        try {
            String identifiant = request.get("identifiant");
            String email = apiculteurService.getEmailByIdentifiant(identifiant);
            if (email != null) {
                return ResponseEntity.ok(Map.of("email", email));
            }
            return ResponseEntity.notFound().build();
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Authentification complète par email et mot de passe
     * Vérifie les identifiants avec Firebase Auth
     */
    @PostMapping("/auth/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> request) {
        try {
            String email = request.get("email");
            String password = request.get("password");
            
            if (email == null || password == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "Email et mot de passe requis"));
            }
            
            // Vérifier les identifiants avec Firebase Auth côté backend
            Map<String, Object> result = apiculteurService.authenticateWithPassword(email, password);
            
            if (result.containsKey("error")) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Les identifiants sont erronés."));
            }
            
            return ResponseEntity.ok(result);
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Erreur d'authentification"));
        }
    }

    /**
     * Classe pour la requête de création d'apiculteur
     */
    public static class CreateApiculteurRequest {
        private String email;
        private String password;
        private String nom;
        private String prenom;
        private String identifiant;
        private String telephone;
        private String adresse;
        private String ville;
        private String codePostal;

        // Getters et setters
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
        
        public String getNom() { return nom; }
        public void setNom(String nom) { this.nom = nom; }
        
        public String getPrenom() { return prenom; }
        public void setPrenom(String prenom) { this.prenom = prenom; }
        
        public String getIdentifiant() { return identifiant; }
        public void setIdentifiant(String identifiant) { this.identifiant = identifiant; }
        
        public String getTelephone() { return telephone; }
        public void setTelephone(String telephone) { this.telephone = telephone; }
        
        public String getAdresse() { return adresse; }
        public void setAdresse(String adresse) { this.adresse = adresse; }
        
        public String getVille() { return ville; }
        public void setVille(String ville) { this.ville = ville; }
        
        public String getCodePostal() { return codePostal; }
        public void setCodePostal(String codePostal) { this.codePostal = codePostal; }
    }
} 