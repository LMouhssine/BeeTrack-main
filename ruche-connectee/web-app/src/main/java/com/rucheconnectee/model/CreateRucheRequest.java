package com.rucheconnectee.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;

/**
 * DTO pour la création d'une ruche via l'API REST.
 * Compatible avec l'interface mobile Flutter.
 */
public class CreateRucheRequest {
    
    @NotBlank(message = "Le nom de la ruche est requis")
    @JsonProperty("nom")
    private String nom;
    
    @NotBlank(message = "La position est requise")
    @JsonProperty("position")
    private String position;
    
    @NotNull(message = "L'ID du rucher est requis")
    @JsonProperty("idRucher")
    private String idRucher;
    
    @JsonProperty("enService")
    private boolean enService = true;
    
    @JsonProperty("dateInstallation")
    private LocalDateTime dateInstallation;
    
    @JsonProperty("typeRuche")
    private String typeRuche;
    
    @JsonProperty("description")
    private String description;
    
    // Constructeurs
    public CreateRucheRequest() {}
    
    public CreateRucheRequest(String nom, String position, String idRucher, boolean enService) {
        this.nom = nom;
        this.position = position;
        this.idRucher = idRucher;
        this.enService = enService;
        this.dateInstallation = LocalDateTime.now();
    }
    
    // Getters et Setters
    public String getNom() {
        return nom;
    }
    
    public void setNom(String nom) {
        this.nom = nom;
    }
    
    public String getPosition() {
        return position;
    }
    
    public void setPosition(String position) {
        this.position = position;
    }
    
    public String getIdRucher() {
        return idRucher;
    }
    
    public void setIdRucher(String idRucher) {
        this.idRucher = idRucher;
    }
    
    public boolean isEnService() {
        return enService;
    }
    
    public void setEnService(boolean enService) {
        this.enService = enService;
    }
    
    public LocalDateTime getDateInstallation() {
        return dateInstallation;
    }
    
    public void setDateInstallation(LocalDateTime dateInstallation) {
        this.dateInstallation = dateInstallation;
    }
    
    public String getTypeRuche() {
        return typeRuche;
    }
    
    public void setTypeRuche(String typeRuche) {
        this.typeRuche = typeRuche;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    /**
     * Convertit ce DTO en objet Ruche pour la persistance
     */
    public Ruche toRuche(String apiculteurId) {
        Ruche ruche = new Ruche();
        ruche.setNom(this.nom);
        ruche.setRucherId(this.idRucher);
        ruche.setApiculteurId(apiculteurId);
        ruche.setTypeRuche(this.typeRuche);
        ruche.setDescription(this.description);
        ruche.setDateInstallation(this.dateInstallation != null ? this.dateInstallation : LocalDateTime.now());
        ruche.setActif(true);
        ruche.setDerniereMiseAJour(LocalDateTime.now());
        
        return ruche;
    }
} 