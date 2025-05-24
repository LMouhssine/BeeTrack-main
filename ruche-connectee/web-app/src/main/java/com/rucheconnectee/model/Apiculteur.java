package com.rucheconnectee.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

/**
 * Modèle représentant un apiculteur dans le système.
 * Correspond à la collection 'apiculteurs' dans Firebase.
 */
public class Apiculteur {
    
    private String id;
    
    @JsonProperty("email")
    private String email;
    
    @JsonProperty("nom")
    private String nom;
    
    @JsonProperty("prenom")
    private String prenom;
    
    @JsonProperty("identifiant")
    private String identifiant;
    
    @JsonProperty("role")
    private String role = "apiculteur";
    
    @JsonProperty("createdAt")
    private LocalDateTime createdAt;
    
    @JsonProperty("telephone")
    private String telephone;
    
    @JsonProperty("adresse")
    private String adresse;
    
    @JsonProperty("ville")
    private String ville;
    
    @JsonProperty("codePostal")
    private String codePostal;
    
    @JsonProperty("actif")
    private boolean actif = true;

    // Constructors
    public Apiculteur() {}

    public Apiculteur(String id, String email, String nom, String prenom, String identifiant, 
                      String role, LocalDateTime createdAt, String telephone, String adresse, 
                      String ville, String codePostal, boolean actif) {
        this.id = id;
        this.email = email;
        this.nom = nom;
        this.prenom = prenom;
        this.identifiant = identifiant;
        this.role = role;
        this.createdAt = createdAt;
        this.telephone = telephone;
        this.adresse = adresse;
        this.ville = ville;
        this.codePostal = codePostal;
        this.actif = actif;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getPrenom() {
        return prenom;
    }

    public void setPrenom(String prenom) {
        this.prenom = prenom;
    }

    public String getIdentifiant() {
        return identifiant;
    }

    public void setIdentifiant(String identifiant) {
        this.identifiant = identifiant;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getTelephone() {
        return telephone;
    }

    public void setTelephone(String telephone) {
        this.telephone = telephone;
    }

    public String getAdresse() {
        return adresse;
    }

    public void setAdresse(String adresse) {
        this.adresse = adresse;
    }

    public String getVille() {
        return ville;
    }

    public void setVille(String ville) {
        this.ville = ville;
    }

    public String getCodePostal() {
        return codePostal;
    }

    public void setCodePostal(String codePostal) {
        this.codePostal = codePostal;
    }

    public boolean isActif() {
        return actif;
    }

    public void setActif(boolean actif) {
        this.actif = actif;
    }
} 