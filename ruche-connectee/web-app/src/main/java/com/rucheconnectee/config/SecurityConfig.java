package com.rucheconnectee.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.beans.factory.annotation.Autowired;
import com.rucheconnectee.service.FirebaseAuthenticationProvider;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

/**
 * Configuration de sécurité simple pour BeeTrack
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {



    @Autowired(required = false)
    private FirebaseAuthenticationProvider firebaseAuthenticationProvider;
    @Autowired
    private AuthenticationSuccessHandler customAuthenticationSuccessHandler;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/login", "/css/**", "/js/**", "/images/**", "/webjars/**", "/logo.svg").permitAll()
                .requestMatchers("/test/**").permitAll()  // Permet l'accès aux endpoints de test Firebase
                .requestMatchers("/fix/**").permitAll()   // Permet l'accès aux endpoints de correction
                .requestMatchers("/debug", "/safe-login", "/force-logout", "/simple-dashboard").permitAll()  // Endpoints de débogage
                .requestMatchers("/ApiculteursNew/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            // Enregistrer le provider Firebase si disponible
            .authenticationProvider(firebaseAuthenticationProvider)
            .authenticationManager(authenticationManager(http))
            .formLogin(form -> form
                .loginPage("/login")
                .loginProcessingUrl("/login")
                .successHandler(customAuthenticationSuccessHandler)
                .failureUrl("/login?error=true")
                .permitAll()
            )
            .logout(logout -> logout
                .logoutSuccessUrl("/login?logout")
                .permitAll()
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                .maximumSessions(1)
                .maxSessionsPreventsLogin(false)
            )
            .csrf(csrf -> csrf.disable())
            .headers(headers -> headers
                .frameOptions(frameOptions -> frameOptions.deny())
            );
            
        return http.build();
    }

    @Bean
    public AuthenticationManager authenticationManager(HttpSecurity http) throws Exception {
        AuthenticationManagerBuilder authManagerBuilder = http.getSharedObject(AuthenticationManagerBuilder.class);
        // Préférer Firebase si disponible
        if (firebaseAuthenticationProvider != null) {
            authManagerBuilder.authenticationProvider(firebaseAuthenticationProvider);
        }
        // Fallback in-memory users
        authManagerBuilder.userDetailsService(fallbackUserDetailsService()).passwordEncoder(passwordEncoder());
        return authManagerBuilder.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public UserDetailsService fallbackUserDetailsService() {
        // Créer plusieurs utilisateurs de test qui correspondent aux identifiants de démonstration
        UserDetails admin = User.builder()
            .username("admin@beetrackdemo.com")
            .password(passwordEncoder().encode("admin123"))
            .roles("ADMIN", "USER")
            .build();

        UserDetails apiculteur = User.builder()
            .username("apiculteur@beetrackdemo.com")
            .password(passwordEncoder().encode("demo123"))
            .roles("USER")
            .build();

        // Garder l'utilisateur original pour la compatibilité
        UserDetails jeanDupont = User.builder()
            .username("jean.dupont@email.com")
            .password(passwordEncoder().encode("Azerty123"))
            .roles("USER")
            .build();

        return new InMemoryUserDetailsManager(admin, apiculteur, jeanDupont);
    }
} 