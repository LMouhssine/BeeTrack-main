import { useState, useEffect, useCallback, useRef } from 'react';
import { AlerteCouvercleService, AlerteCallback } from '../services/alerteCouvercleService';
import { DonneesCapteur } from '../services/rucheService';

interface AlerteActive {
  rucheId: string;
  rucheNom?: string;
  mesure: DonneesCapteur;
}

interface UseAlertesCouvercleProps {
  apiculteurId: string;
  onNotification?: (message: string, type: 'success' | 'error' | 'warning') => void;
}

export interface UseAlertesCouvercleReturn {
  // État des alertes
  alerteActive: AlerteActive | null;
  surveillanceActive: Set<string>;
  
  // Actions
  demarrerSurveillance: (rucheId: string, rucheNom?: string) => void;
  arreterSurveillance: (rucheId: string) => void;
  arreterToutesSurveillances: () => void;
  
  // Gestion des alertes
  ignorerAlerte: (dureeHeures: number) => void;
  ignorerPourSession: () => void;
  fermerAlerte: () => void;
  
  // Statut
  obtenirStatutIgnore: (rucheId: string) => { ignore: boolean; type?: string; finIgnore?: Date };
  reactiverAlertes: (rucheId: string) => void;
}

export const useAlertesCouvercle = ({ 
  apiculteurId, 
  onNotification 
}: UseAlertesCouvercleProps): UseAlertesCouvercleReturn => {
  
  const [alerteActive, setAlerteActive] = useState<AlerteActive | null>(null);
  const [surveillanceActive, setSurveillanceActive] = useState<Set<string>>(new Set());
  
  const alerteServiceRef = useRef(AlerteCouvercleService.getInstance());
  const ruchesNomsRef = useRef<Map<string, string>>(new Map());

  // Callback pour gérer les alertes
  const handleAlerte = useCallback((rucheId: string, mesure: DonneesCapteur) => {
    const rucheNom = ruchesNomsRef.current.get(rucheId);
    
    console.log(`🚨 Alerte couvercle pour ruche ${rucheNom || rucheId}`);
    setAlerteActive({
      rucheId,
      rucheNom,
      mesure
    });
    
    if (onNotification) {
      onNotification(
        `⚠️ Couvercle ouvert détecté sur ${rucheNom || `ruche ${rucheId}`}`,
        'warning'
      );
    }
  }, [onNotification]);

  // Callback pour gérer les erreurs de surveillance
  const handleErreurSurveillance = useCallback((rucheId: string, erreur: Error) => {
    console.error(`❌ Erreur surveillance ruche ${rucheId}:`, erreur);
    
    if (onNotification) {
      onNotification(
        `Erreur de surveillance pour la ruche ${ruchesNomsRef.current.get(rucheId) || rucheId}`,
        'error'
      );
    }
  }, [onNotification]);

  // Démarrer la surveillance d'une ruche
  const demarrerSurveillance = useCallback((rucheId: string, rucheNom?: string) => {
    if (rucheNom) {
      ruchesNomsRef.current.set(rucheId, rucheNom);
    }
    
    const callback: AlerteCallback = {
      onAlerteCouvercle: handleAlerte,
      onErreurSurveillance: handleErreurSurveillance
    };
    
    alerteServiceRef.current.demarrerSurveillance(rucheId, apiculteurId, callback);
    
    setSurveillanceActive(prev => new Set(prev).add(rucheId));
    
    if (onNotification) {
      onNotification(
        `Surveillance démarrée pour ${rucheNom || `ruche ${rucheId}`}`,
        'success'
      );
    }
  }, [apiculteurId, handleAlerte, handleErreurSurveillance, onNotification]);

  // Arrêter la surveillance d'une ruche
  const arreterSurveillance = useCallback((rucheId: string) => {
    alerteServiceRef.current.arreterSurveillance(rucheId);
    
    setSurveillanceActive(prev => {
      const newSet = new Set(prev);
      newSet.delete(rucheId);
      return newSet;
    });
    
    // Fermer l'alerte si elle concerne cette ruche
    if (alerteActive?.rucheId === rucheId) {
      setAlerteActive(null);
    }
    
    const rucheNom = ruchesNomsRef.current.get(rucheId);
    if (onNotification) {
      onNotification(
        `Surveillance arrêtée pour ${rucheNom || `ruche ${rucheId}`}`,
        'success'
      );
    }
  }, [alerteActive, onNotification]);

  // Arrêter toutes les surveillances
  const arreterToutesSurveillances = useCallback(() => {
    alerteServiceRef.current.arreterToutesSurveillances();
    setSurveillanceActive(new Set());
    setAlerteActive(null);
    
    if (onNotification) {
      onNotification('Toutes les surveillances ont été arrêtées', 'success');
    }
  }, [onNotification]);

  // Ignorer temporairement l'alerte
  const ignorerAlerte = useCallback((dureeHeures: number) => {
    if (!alerteActive) return;
    
    alerteServiceRef.current.ignorerAlerte(alerteActive.rucheId, dureeHeures);
    setAlerteActive(null);
    
    const dureeText = dureeHeures === 0.5 ? '30 minutes' : 
                     dureeHeures === 1 ? '1 heure' : 
                     `${dureeHeures} heures`;
    
    if (onNotification) {
      onNotification(
        `Alerte ignorée pour ${dureeText} pour ${alerteActive.rucheNom || `ruche ${alerteActive.rucheId}`}`,
        'success'
      );
    }
  }, [alerteActive, onNotification]);

  // Ignorer pour la session
  const ignorerPourSession = useCallback(() => {
    if (!alerteActive) return;
    
    alerteServiceRef.current.ignorerPourSession(alerteActive.rucheId);
    setAlerteActive(null);
    
    if (onNotification) {
      onNotification(
        `Alerte ignorée pour cette session pour ${alerteActive.rucheNom || `ruche ${alerteActive.rucheId}`}`,
        'success'
      );
    }
  }, [alerteActive, onNotification]);

  // Fermer l'alerte (sans ignorer)
  const fermerAlerte = useCallback(() => {
    setAlerteActive(null);
  }, []);

  // Obtenir le statut d'ignore pour une ruche
  const obtenirStatutIgnore = useCallback((rucheId: string) => {
    return alerteServiceRef.current.obtenirStatutIgnore(rucheId);
  }, []);

  // Réactiver les alertes pour une ruche
  const reactiverAlertes = useCallback((rucheId: string) => {
    alerteServiceRef.current.reactiverAlertes(rucheId);
    
    const rucheNom = ruchesNomsRef.current.get(rucheId);
    if (onNotification) {
      onNotification(
        `Alertes réactivées pour ${rucheNom || `ruche ${rucheId}`}`,
        'success'
      );
    }
  }, [onNotification]);

  // Nettoyage lors du démontage du composant
  useEffect(() => {
    return () => {
      console.log('🧹 Nettoyage des surveillances...');
      alerteServiceRef.current.arreterToutesSurveillances();
    };
  }, []);

  return {
    // État
    alerteActive,
    surveillanceActive,
    
    // Actions
    demarrerSurveillance,
    arreterSurveillance,
    arreterToutesSurveillances,
    
    // Gestion des alertes
    ignorerAlerte,
    ignorerPourSession,
    fermerAlerte,
    
    // Statut
    obtenirStatutIgnore,
    reactiverAlertes
  };
}; 