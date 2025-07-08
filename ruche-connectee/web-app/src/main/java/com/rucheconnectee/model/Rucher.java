package com.rucheconnectee.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;

/**
 * Modèle représentant un rucher (emplacement regroupant plusieurs ruches).
 * Correspond à la collection 'ruchers' dans Firebase.
 */
public class Rucher {
    
    private String id;
    
    @JsonProperty("nom")
    private String nom;
    
    @JsonProperty("apiculteur_id")
    private String apiculteurId;
    
    @JsonProperty("description")
    private String description;
    
    @JsonProperty("adresse")
    private String adresse;
    
    @JsonProperty("ville")
    private String ville;
    
    @JsonProperty("code_postal")
    private String codePostal;
    
    @JsonProperty("position_lat")
    private Double positionLat;
    
    @JsonProperty("position_lng")
    private Double positionLng;
    
    @JsonProperty("date_creation")
    private LocalDateTime dateCreation;
    
    @JsonProperty("nombre_ruches")
    private Integer nombreRuches = 0;
    
    @JsonProperty("actif")
    private boolean actif = true;
    
    @JsonProperty("notes")
    private String notes;

    @JsonProperty("coordonnees")
    private String coordonnees;

    // Constructors
    public Rucher() {}

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getApiculteurId() {
        return apiculteurId;
    }

    public void setApiculteurId(String apiculteurId) {
        this.apiculteurId = apiculteurId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
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

    public Double getPositionLat() {
        return positionLat;
    }

    public void setPositionLat(Double positionLat) {
        this.positionLat = positionLat;
    }

    public Double getPositionLng() {
        return positionLng;
    }

    public void setPositionLng(Double positionLng) {
        this.positionLng = positionLng;
    }

    public LocalDateTime getDateCreation() {
        return dateCreation;
    }

    public void setDateCreation(LocalDateTime dateCreation) {
        this.dateCreation = dateCreation;
    }

    public Integer getNombreRuches() {
        return nombreRuches;
    }

    public void setNombreRuches(Integer nombreRuches) {
        this.nombreRuches = nombreRuches;
    }

    public boolean isActif() {
        return actif;
    }

    public void setActif(boolean actif) {
        this.actif = actif;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getCoordonnees() {
        return coordonnees;
    }

    public void setCoordonnees(String coordonnees) {
        this.coordonnees = coordonnees;
    }
} 