package com.rucheconnectee.controller;

import com.rucheconnectee.service.FirebaseAuthRestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

/**
 * Contrôleur pour la gestion de la page de connexion avec Firebase
 */
@Controller
public class LoginController {

    @Autowired(required = false)
    private FirebaseAuthRestService firebaseAuthService;

    @GetMapping("/login")
    public String login(
            @RequestParam(value = "error", required = false) String error,
            @RequestParam(value = "logout", required = false) String logout,
            Model model) {
        
        if (error != null) {
            model.addAttribute("error", "Nom d'utilisateur ou mot de passe incorrect");
        }
        
        if (logout != null) {
            model.addAttribute("message", "Vous avez été déconnecté avec succès");
        }
        
        // Vérifier si Firebase est configuré
        model.addAttribute("firebaseEnabled", firebaseAuthService != null);
        
        return "login";
    }

    @PostMapping("/api/firebase-auth")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> firebaseAuth(
            @RequestParam String email,
            @RequestParam String password,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        if (firebaseAuthService == null) {
            response.put("success", false);
            response.put("message", "Firebase non configuré");
            return ResponseEntity.badRequest().body(response);
        }
        
        try {
            FirebaseAuthRestService.AuthResult authResult = 
                firebaseAuthService.signInWithEmailAndPassword(email, password);
            
            if (authResult != null && authResult.success) {
                // Stocker les informations de session
                session.setAttribute("firebaseToken", authResult.idToken);
                session.setAttribute("firebaseUserId", authResult.uid);
                session.setAttribute("userEmail", email);
                session.setAttribute("authenticated", true);
                
                response.put("success", true);
                response.put("message", "Connexion réussie");
                response.put("redirectUrl", "/dashboard");
                
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", authResult != null ? authResult.error : "Échec de l'authentification");
                return ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Erreur d'authentification: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    @PostMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login?logout=true";
    }

    @GetMapping("/")
    public String home() {
        return "redirect:/login";
    }
}