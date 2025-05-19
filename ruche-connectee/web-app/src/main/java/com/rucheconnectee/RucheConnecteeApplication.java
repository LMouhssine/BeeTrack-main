package com.rucheconnectee;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Point d'entrée principal de l'application Spring Boot pour le système de ruches connectées.
 * Cette classe initialise l'application Spring Boot et active les fonctionnalités de planification.
 */
@SpringBootApplication
@EnableScheduling
public class RucheConnecteeApplication {

    public static void main(String[] args) {
        SpringApplication.run(RucheConnecteeApplication.class, args);
    }
}