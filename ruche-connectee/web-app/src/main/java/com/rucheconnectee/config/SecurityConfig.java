package com.rucheconnectee.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Configuration de sécurité simple pour BeeTrack
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authz -> authz
                .anyRequest().permitAll()  // Permettre l'accès libre temporairement
            )
            .csrf(csrf -> csrf.disable())  // Désactiver CSRF
            .headers(headers -> headers
                .frameOptions(frameOptions -> frameOptions.deny())
            );
            
        return http.build();
    }
} 