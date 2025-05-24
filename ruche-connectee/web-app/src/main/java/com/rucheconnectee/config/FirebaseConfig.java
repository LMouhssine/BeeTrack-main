package com.rucheconnectee.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.FirestoreOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.io.InputStream;

/**
 * Configuration Firebase pour l'authentification et Firestore.
 * Initialise la connexion avec Firebase en utilisant les credentials de service.
 */
@Configuration
public class FirebaseConfig {

    @Value("${firebase.project-id}")
    private String projectId;

    @Value("${firebase.credentials-path:firebase-service-account.json}")
    private String credentialsPath;

    @PostConstruct
    public void initialize() {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                InputStream serviceAccount = new ClassPathResource(credentialsPath).getInputStream();
                
                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .setProjectId(projectId)
                        .build();

                FirebaseApp.initializeApp(options);
            }
        } catch (IOException e) {
            throw new RuntimeException("Erreur lors de l'initialisation de Firebase", e);
        }
    }

    @Bean
    public FirebaseAuth firebaseAuth() {
        return FirebaseAuth.getInstance();
    }

    @Bean
    public Firestore firestore() {
        try {
            InputStream serviceAccount = new ClassPathResource(credentialsPath).getInputStream();
            GoogleCredentials credentials = GoogleCredentials.fromStream(serviceAccount);
            
            FirestoreOptions firestoreOptions = FirestoreOptions.newBuilder()
                    .setCredentials(credentials)
                    .setProjectId(projectId)
                    .build();
                    
            return firestoreOptions.getService();
        } catch (IOException e) {
            throw new RuntimeException("Erreur lors de l'initialisation de Firestore", e);
        }
    }
} 