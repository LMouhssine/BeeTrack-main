package com.rucheconnectee.service;

import com.rucheconnectee.model.Apiculteur;
import com.rucheconnectee.model.ApiculteursNew;
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

    @Autowired(required = false)
    private FirebaseAuthRestService firebaseAuthRestService;

    @Autowired(required = false)
    private ApiculteursNewService apiculteursNewService;

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        String email = authentication.getName();
        String password = authentication.getCredentials().toString();

        try {
            // 1) Vérification via Firebase REST si la clé API est configurée
            if (firebaseAuthRestService != null) {
                try {
                    var res = firebaseAuthRestService.signInWithEmailAndPassword(email, password);
                    if (!res.success) {
                        System.err.println("[LOGIN] ❌ Firebase signIn FAILED | email=" + email + " | error=" + res.error);
                        throw new BadCredentialsException("Invalid credentials: " + (res.error != null ? res.error : "AUTH_FAILED"));
                    }
                    System.out.println("[LOGIN] ✅ Firebase signIn OK | email=" + email + " | uid=" + res.uid);
                } catch (Exception ex) {
                    System.err.println("[LOGIN] ❌ Firebase signIn error: " + ex.getMessage());
                    throw ex;
                }
            } else {
                // 2) Fallback: légère vérification via service (ne vérifie pas réellement le mot de passe)
                Map<String, Object> validationResult = apiculteurService.authenticateWithPassword(email, password);
                if (validationResult.containsKey("error")) {
                    throw new BadCredentialsException("Invalid credentials: " + validationResult.get("error"));
                }
            }

            // Récupérer les informations de l'apiculteur pour les rôles
            // Récupérer les informations pour les rôles depuis la DB principale, sinon depuis ApiculteursNew
            String role = null;
            Apiculteur apiculteur = null;
            try {
                apiculteur = apiculteurService.getApiculteurByEmail(email);
            } catch (Exception ignored) {}

            if (apiculteur != null && apiculteur.isActif()) {
                role = apiculteur.getRole();
            } else if (apiculteursNewService != null) {
                ApiculteursNew alt = apiculteursNewService.findByEmail(email);
                if (alt != null) {
                    role = alt.getRole();
                }
            }

            if (role == null) {
                throw new BadCredentialsException("Compte utilisateur inactif ou inexistant");
            }

            // Créer les autorités (rôles)
            List<SimpleGrantedAuthority> authorities = new ArrayList<>();
            if ("admin".equalsIgnoreCase(role)) {
                authorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
            }
            authorities.add(new SimpleGrantedAuthority("ROLE_USER"));

            // Créer le token d'authentification réussi
            return new UsernamePasswordAuthenticationToken(email, null, authorities);

        } catch (Exception e) {
            throw new BadCredentialsException("Erreur lors de l'authentification: " + e.getMessage(), e);
        }
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return authentication.equals(UsernamePasswordAuthenticationToken.class);
    }
} 