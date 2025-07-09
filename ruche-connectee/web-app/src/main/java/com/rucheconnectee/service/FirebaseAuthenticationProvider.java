package com.rucheconnectee.service;

import com.rucheconnectee.model.Apiculteur;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Fournisseur d'authentification personnalisé qui vérifie contre Firebase
 */
@Component
@ConditionalOnProperty(name = "firebase.project-id")
public class FirebaseAuthenticationProvider implements AuthenticationProvider {

    @Autowired
    private ApiculteurService apiculteurService;

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        String email = authentication.getName();
        String password = authentication.getCredentials().toString();

        try {
            // Valider l'utilisateur contre Firebase
            Map<String, Object> validationResult = apiculteurService.authenticateWithPassword(email, password);
            
            if (validationResult.containsKey("error")) {
                throw new BadCredentialsException("Invalid credentials: " + validationResult.get("error"));
            }

            // Récupérer les informations de l'apiculteur
            Apiculteur apiculteur = apiculteurService.getApiculteurByEmail(email);
            
            if (apiculteur == null || !apiculteur.isActif()) {
                throw new BadCredentialsException("Compte utilisateur inactif ou inexistant");
            }

            // Créer les autorités (rôles)
            List<SimpleGrantedAuthority> authorities = new ArrayList<>();
            authorities.add(new SimpleGrantedAuthority("ROLE_USER"));

            // Créer le token d'authentification réussi
            return new UsernamePasswordAuthenticationToken(email, password, authorities);
            
        } catch (Exception e) {
            throw new BadCredentialsException("Erreur lors de l'authentification: " + e.getMessage(), e);
        }
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return authentication.equals(UsernamePasswordAuthenticationToken.class);
    }
} 