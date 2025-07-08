package com.rucheconnectee.config;

import com.google.firebase.auth.FirebaseAuthException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.util.Map;
import java.util.concurrent.ExecutionException;

/**
 * Gestionnaire global des exceptions pour l'application
 */
@RestControllerAdvice
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    /**
     * Gère les exceptions Firebase Auth
     */
    @ExceptionHandler(FirebaseAuthException.class)
    public ResponseEntity<Map<String, String>> handleFirebaseAuthException(FirebaseAuthException e) {
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("error", "Erreur d'authentification: " + e.getMessage()));
    }

    /**
     * Gère les exceptions d'exécution Firebase
     */
    @ExceptionHandler(ExecutionException.class)
    public ResponseEntity<Map<String, String>> handleExecutionException(ExecutionException e) {
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Erreur d'exécution: " + e.getMessage()));
    }

    /**
     * Gère les exceptions d'interruption
     */
    @ExceptionHandler(InterruptedException.class)
    public ResponseEntity<Map<String, String>> handleInterruptedException(InterruptedException e) {
        Thread.currentThread().interrupt(); // Restaure le flag d'interruption
        return ResponseEntity
                .status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(Map.of("error", "Opération interrompue: " + e.getMessage()));
    }

    /**
     * Gère toutes les autres exceptions non gérées
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleGenericException(Exception e) {
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Une erreur est survenue: " + e.getMessage()));
    }
} 