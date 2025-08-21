package com.rucheconnectee.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.FirebaseDatabase;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.io.InputStream;

/**
 * Configuration Firebase pour l'authentification et Realtime Database.
 * S'active uniquement si Firebase est configuré (mode production).
 * En mode développement, utilise les services mockés.
 */
@Configuration
@ConditionalOnProperty(name = "app.use-mock-data", havingValue = "false", matchIfMissing = true)
public class FirebaseConfig {

    @Value("${firebase.project-id:}")
    private String projectId;

    @Value("${firebase.credentials-path:firebase-service-account.json}")
    private String credentialsPath;

    @Value("${firebase.database-url:}")
    private String databaseUrl;

    @PostConstruct
    public void initialize() {
        if (projectId == null || projectId.isEmpty()) {
            System.out.println("Firebase désactivé - Mode développement avec données mockées");
            return;
        }

        try {
            if (FirebaseApp.getApps().isEmpty()) {
                InputStream serviceAccount = new ClassPathResource(credentialsPath).getInputStream();
                
                FirebaseOptions.Builder optionsBuilder = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .setProjectId(projectId);
                
                // Ajouter l'URL de la base de données si elle est configurée
                if (databaseUrl != null && !databaseUrl.isEmpty()) {
                    optionsBuilder.setDatabaseUrl(databaseUrl);
                }

                FirebaseApp.initializeApp(optionsBuilder.build());
                System.out.println("Firebase initialisé avec succès pour le projet: " + projectId);
            }
        } catch (IOException e) {
            System.err.println("Erreur lors de l'initialisation de Firebase: " + e.getMessage());
            System.out.println("Fonctionnement en mode dégradé avec données mockées");
        }
    }

    @Bean
    public FirebaseAuth firebaseAuth() {
        return FirebaseAuth.getInstance();
    }

    @Bean
    public FirebaseDatabase firebaseDatabase() {
        return FirebaseDatabase.getInstance();
    }
} 