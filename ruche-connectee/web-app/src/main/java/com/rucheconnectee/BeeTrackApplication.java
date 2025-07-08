package com.rucheconnectee;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;

/**
 * Application BeeTrack avec services Firebase réels
 */
@SpringBootApplication(exclude = {
    SecurityAutoConfiguration.class,
    org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration.class,
    org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration.class
})
public class BeeTrackApplication {

    public static void main(String[] args) {
        System.out.println("🚀 Démarrage de BeeTrack Application...");
        SpringApplication.run(BeeTrackApplication.class, args);
        System.out.println("✅ BeeTrack Application démarrée avec succès !");
        System.out.println("🔥 Connexion Firebase activée - Données réelles !");
        System.out.println("📱 Dashboard: http://localhost:8080/dashboard");
        System.out.println("🐝 Ruches: http://localhost:8080/ruches");
        System.out.println("📍 Ruchers: http://localhost:8080/ruchers");
        System.out.println("📊 Stats: http://localhost:8080/statistiques");
        System.out.println("📚 API: http://localhost:8080/swagger-ui.html");
    }
} 