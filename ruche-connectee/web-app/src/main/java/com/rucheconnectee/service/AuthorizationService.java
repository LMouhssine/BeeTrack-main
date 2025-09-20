package com.rucheconnectee.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.TimeoutException;

/**
 * Service pour vérifier les autorisations d'accès aux ressources
 */
@Service
public class AuthorizationService {

    @Autowired
    private FirebaseService firebaseService;

    /**
     * Vérifie si un apiculteur a accès à une ruche
     * @param apiculteurId ID de l'apiculteur
     * @param rucheId ID de la ruche
     * @return true si l'apiculteur a accès, false sinon
     */
    public boolean hasAccessToRuche(String apiculteurId, String rucheId) {
        if (apiculteurId == null || rucheId == null) {
            return false;
        }

        try {
            // Récupérer les données de la ruche depuis Firebase
            Map<String, Object> rucheData = firebaseService.getDocument("RuchesNew", rucheId);
            
            if (rucheData == null) {
                return false;
            }

            // Vérifier si la ruche appartient à l'apiculteur
            String rucheApiculteurId = (String) rucheData.get("idApiculteur");
            return apiculteurId.equals(rucheApiculteurId);

        } catch (InterruptedException | TimeoutException e) {
            // En cas d'erreur, refuser l'accès par sécurité
            return false;
        }
    }

    /**
     * Vérifie si un apiculteur a accès à un rucher
     * @param apiculteurId ID de l'apiculteur
     * @param rucherId ID du rucher
     * @return true si l'apiculteur a accès, false sinon
     */
    public boolean hasAccessToRucher(String apiculteurId, String rucherId) {
        if (apiculteurId == null || rucherId == null) {
            return false;
        }

        try {
            // Récupérer les données du rucher depuis Firebase
            Map<String, Object> rucherData = firebaseService.getDocument("RuchersNew", rucherId);
            
            if (rucherData == null) {
                return false;
            }

            // Vérifier si le rucher appartient à l'apiculteur
            String rucherApiculteurId = (String) rucherData.get("idApiculteur");
            return apiculteurId.equals(rucherApiculteurId);

        } catch (InterruptedException | TimeoutException e) {
            // En cas d'erreur, refuser l'accès par sécurité
            return false;
        }
    }
}
