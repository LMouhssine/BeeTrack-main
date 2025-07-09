package com.rucheconnectee.service;

import com.rucheconnectee.model.Apiculteur;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

/**
 * Service d'authentification qui vérifie contre Firebase
 * Utilise les données Firebase pour l'authentification au lieu de données en mémoire
 */
@Service
@ConditionalOnProperty(name = "firebase.project-id")
public class FirebaseUserDetailsService implements UserDetailsService {

    @Autowired
    private ApiculteurService apiculteurService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        try {
            // Vérifier si l'utilisateur existe dans Firebase
            Apiculteur apiculteur = apiculteurService.getApiculteurByEmail(email);
            
            if (apiculteur == null) {
                throw new UsernameNotFoundException("Utilisateur non trouvé: " + email);
            }

            // Pour l'instant, on utilise un mot de passe par défaut car Firebase gère l'auth côté client
            // Dans une vraie implémentation, on utilisrait Firebase Admin SDK pour vérifier le token
            String defaultPassword = "password"; // Mot de passe temporaire
            
            return User.builder()
                .username(email)
                .password(passwordEncoder.encode(defaultPassword))
                .roles("USER")
                .build();
                
        } catch (Exception e) {
            throw new UsernameNotFoundException("Erreur lors de la vérification de l'utilisateur: " + email, e);
        }
    }
} 