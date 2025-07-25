package com.rucheconnectee.service;

import com.rucheconnectee.model.Apiculteur;
import com.rucheconnectee.model.Ruche;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Service de notification pour les alertes de couvercle ouvert
 */
@Service
@ConditionalOnProperty(name = "firebase.project-id")
public class NotificationService {

    @Autowired
    private JavaMailSender mailSender;

    @Autowired
    private ApiculteurService apiculteurService;

    @Autowired
    private RucheService rucheService;

    // Cache des inhibitions temporaires par ruche
    private final Map<String, InhibitionInfo> inhibitions = new ConcurrentHashMap<>();

    /**
     * Envoie une notification email pour un couvercle ouvert
     */
    public void envoyerAlerteCouvercleOuvert(String rucheId, Map<String, Object> mesure) {
        try {
            // Vérifier si l'alerte est inhibée
            if (estAlerteInhibee(rucheId)) {
                System.out.println("🔇 Alerte inhibée pour la ruche: " + rucheId);
                return;
            }

            // Récupérer les informations de la ruche
            Ruche ruche = rucheService.getRucheById(rucheId);
            if (ruche == null) {
                System.err.println("❌ Ruche non trouvée: " + rucheId);
                return;
            }

            // Récupérer les informations de l'apiculteur
            Apiculteur apiculteur = apiculteurService.getApiculteurById(ruche.getApiculteurId());
            if (apiculteur == null) {
                System.err.println("❌ Apiculteur non trouvé pour la ruche: " + rucheId);
                return;
            }

            // Préparer le message
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(apiculteur.getEmail());
            message.setSubject("🚨 ALERTE - Couvercle ouvert détecté");
            message.setText(creerMessageAlerte(ruche, apiculteur, mesure));

            // Envoyer l'email
            mailSender.send(message);
            System.out.println("✅ Email d'alerte envoyé à: " + apiculteur.getEmail());

        } catch (Exception e) {
            System.err.println("❌ Erreur lors de l'envoi de l'email d'alerte: " + e.getMessage());
        }
    }

    /**
     * Crée le contenu du message d'alerte
     */
    private String creerMessageAlerte(Ruche ruche, Apiculteur apiculteur, Map<String, Object> mesure) {
        StringBuilder message = new StringBuilder();
        
        message.append("Bonjour ").append(apiculteur.getPrenom()).append(",\n\n");
        message.append("🚨 Une alerte a été déclenchée pour votre ruche.\n\n");
        
        message.append("📋 Détails de l'alerte:\n");
        message.append("• Ruche: ").append(ruche.getNom()).append("\n");
        message.append("• Type: Couvercle ouvert\n");
        message.append("• Heure: ").append(formatTimestamp((String) mesure.get("timestamp"))).append("\n");
        
        if (mesure.get("temperature") != null) {
            message.append("• Température: ").append(mesure.get("temperature")).append("°C\n");
        }
        if (mesure.get("humidite") != null) {
            message.append("• Humidité: ").append(mesure.get("humidite")).append("%\n");
        }
        
        message.append("\n🔧 Actions recommandées:\n");
        message.append("1. Vérifier l'état de la ruche\n");
        message.append("2. S'assurer qu'aucune intervention n'est en cours\n");
        message.append("3. Contacter l'équipe si nécessaire\n");
        
        message.append("\n📱 Vous pouvez également consulter l'application mobile pour plus de détails.\n\n");
        message.append("Cordialement,\n");
        message.append("L'équipe BeeTrack");
        
        return message.toString();
    }

    /**
     * Active une inhibition temporaire pour une ruche
     */
    public void activerInhibition(String rucheId, int dureeHeures) {
        LocalDateTime finInhibition = LocalDateTime.now().plusHours(dureeHeures);
        inhibitions.put(rucheId, new InhibitionInfo(finInhibition, dureeHeures));
        
        System.out.println("🔇 Inhibition activée pour la ruche " + rucheId + 
                          " jusqu'à " + finInhibition.format(DateTimeFormatter.ofPattern("HH:mm")));
    }

    /**
     * Désactive l'inhibition pour une ruche
     */
    public void desactiverInhibition(String rucheId) {
        inhibitions.remove(rucheId);
        System.out.println("🔔 Inhibition désactivée pour la ruche: " + rucheId);
    }

    /**
     * Vérifie si une alerte est inhibée pour une ruche
     */
    public boolean estAlerteInhibee(String rucheId) {
        InhibitionInfo inhibition = inhibitions.get(rucheId);
        if (inhibition == null) {
            return false;
        }

        // Vérifier si l'inhibition a expiré
        if (LocalDateTime.now().isAfter(inhibition.finInhibition)) {
            inhibitions.remove(rucheId);
            return false;
        }

        return true;
    }

    /**
     * Obtient le statut d'inhibition pour une ruche
     */
    public Map<String, Object> obtenirStatutInhibition(String rucheId) {
        InhibitionInfo inhibition = inhibitions.get(rucheId);
        
        if (inhibition == null) {
            return Map.of("inhibee", false);
        }

        // Vérifier si l'inhibition a expiré
        if (LocalDateTime.now().isAfter(inhibition.finInhibition)) {
            inhibitions.remove(rucheId);
            return Map.of("inhibee", false);
        }

        return Map.of(
            "inhibee", true,
            "finInhibition", inhibition.finInhibition,
            "dureeHeures", inhibition.dureeHeures,
            "tempsRestant", java.time.Duration.between(LocalDateTime.now(), inhibition.finInhibition).toHours()
        );
    }

    /**
     * Nettoie les inhibitions expirées
     */
    public void nettoyerInhibitionsExpirees() {
        LocalDateTime maintenant = LocalDateTime.now();
        inhibitions.entrySet().removeIf(entry -> 
            maintenant.isAfter(entry.getValue().finInhibition)
        );
    }

    /**
     * Obtient toutes les inhibitions actives
     */
    public Map<String, InhibitionInfo> obtenirInhibitionsActives() {
        nettoyerInhibitionsExpirees();
        return new ConcurrentHashMap<>(inhibitions);
    }

    /**
     * Formate un timestamp pour l'affichage
     */
    private String formatTimestamp(String timestamp) {
        try {
            LocalDateTime dateTime = LocalDateTime.parse(timestamp.substring(0, 19));
            return dateTime.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
        } catch (Exception e) {
            return timestamp;
        }
    }

    /**
     * Classe pour stocker les informations d'inhibition
     */
    public static class InhibitionInfo {
        public final LocalDateTime finInhibition;
        public final int dureeHeures;

        public InhibitionInfo(LocalDateTime finInhibition, int dureeHeures) {
            this.finInhibition = finInhibition;
            this.dureeHeures = dureeHeures;
        }
    }
} 