package com.rucheconnectee.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Configuration pour le mode développement sans Firebase
 * Provides des beans mockés pour remplacer les services Firebase
 */
@Configuration
@ConditionalOnProperty(name = "app.use-mock-data", havingValue = "true")
public class DevelopmentConfig {

    /**
     * Message de confirmation que le mode développement est activé
     */
    @Bean
    public String developmentMode() {
        System.out.println("🔧 Mode développement activé - Utilisation de données mockées");
        System.out.println("🚫 Firebase désactivé pour cette session");
        return "development";
    }
} 