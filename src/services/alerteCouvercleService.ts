import { DonneesCapteursService, DonneesCapteur } from './donneesCapteursService';

// Interface pour les règles d'ignore d'alerte
interface AlerteIgnoreRule {
  rucheId: string;
  timestamp: number;
  dureeMs: number;
  type: 'session' | 'temporaire';
}

// Interface pour le callback d'alerte
export interface AlerteCallback {
  onAlerteCouvercle: (rucheId: string, mesure: DonneesCapteur) => void;
  onErreurSurveillance?: (rucheId: string, erreur: Error) => void;
}

export class AlerteCouvercleService {
  private static instance: AlerteCouvercleService;
  private surveillanceIntervals: Map<string, NodeJS.Timeout> = new Map();
  private alerteCallbacks: Map<string, AlerteCallback> = new Map();
  private readonly STORAGE_KEY = 'beetrackAlertesIgnore';
  private readonly INTERVAL_MS = 30000; // 30 secondes
  
  private constructor() {}

  public static getInstance(): AlerteCouvercleService {
    if (!AlerteCouvercleService.instance) {
      AlerteCouvercleService.instance = new AlerteCouvercleService();
    }
    return AlerteCouvercleService.instance;
  }

  /**
   * Démarre la surveillance d'une ruche
   */
  public demarrerSurveillance(
    rucheId: string, 
    callback: AlerteCallback
  ): void {
    console.log(`🚨 Démarrage surveillance ruche ${rucheId}`);
    
    // Arrêter la surveillance existante si elle existe
    this.arreterSurveillance(rucheId);
    
    // Enregistrer le callback
    this.alerteCallbacks.set(rucheId, callback);
    
    // Fonction de surveillance
    const surveiller = async () => {
      try {
        console.log(`🔍 Vérification ruche ${rucheId}`);
        
        const mesure = await DonneesCapteursService.getDerniereMesure(rucheId);
        
        if (mesure && mesure.couvercleOuvert === true) {
          console.log(`⚠️ Couvercle ouvert détecté pour ruche ${rucheId}`);
          
          // Vérifier si l'alerte doit être ignorée
          if (!this.doitIgnorerAlerte(rucheId)) {
            callback.onAlerteCouvercle(rucheId, mesure);
          } else {
            console.log(`🔇 Alerte ignorée pour ruche ${rucheId}`);
          }
        }
        
      } catch (error) {
        console.error(`❌ Erreur surveillance ruche ${rucheId}:`, error);
        if (callback.onErreurSurveillance) {
          callback.onErreurSurveillance(rucheId, error as Error);
        }
      }
    };
    
    // Première vérification immédiate
    surveiller();
    
    // Programmer les vérifications périodiques
    const interval = setInterval(surveiller, this.INTERVAL_MS);
    this.surveillanceIntervals.set(rucheId, interval);
  }

  /**
   * Arrête la surveillance d'une ruche
   */
  public arreterSurveillance(rucheId: string): void {
    const interval = this.surveillanceIntervals.get(rucheId);
    if (interval) {
      clearInterval(interval);
      this.surveillanceIntervals.delete(rucheId);
      this.alerteCallbacks.delete(rucheId);
      console.log(`🛑 Surveillance arrêtée pour ruche ${rucheId}`);
    }
  }

  /**
   * Arrête toutes les surveillances
   */
  public arreterToutesSurveillances(): void {
    this.surveillanceIntervals.forEach((interval, rucheId) => {
      clearInterval(interval);
      console.log(`🛑 Surveillance arrêtée pour ruche ${rucheId}`);
    });
    this.surveillanceIntervals.clear();
    this.alerteCallbacks.clear();
  }

  /**
   * Ignore temporairement l'alerte pour une ruche
   */
  public ignorerAlerte(rucheId: string, dureeHeures: number = 1): void {
    const rule: AlerteIgnoreRule = {
      rucheId,
      timestamp: Date.now(),
      dureeMs: dureeHeures * 60 * 60 * 1000, // Convertir heures en millisecondes
      type: 'temporaire'
    };
    
    this.sauvegarderRegleIgnore(rule);
    console.log(`🔇 Alerte ignorée pour ${dureeHeures}h pour ruche ${rucheId}`);
  }

  /**
   * Ignore l'alerte pour la session courante
   */
  public ignorerPourSession(rucheId: string): void {
    const rule: AlerteIgnoreRule = {
      rucheId,
      timestamp: Date.now(),
      dureeMs: 0, // Pas de limite de temps pour session
      type: 'session'
    };
    
    this.sauvegarderRegleIgnore(rule);
    console.log(`🔇 Alerte ignorée pour la session pour ruche ${rucheId}`);
  }

  /**
   * Vérifie si une alerte doit être ignorée
   */
  private doitIgnorerAlerte(rucheId: string): boolean {
    const rules = this.obtenirReglesIgnore();
    const maintenant = Date.now();
    
    for (const rule of rules) {
      if (rule.rucheId === rucheId) {
        if (rule.type === 'session') {
          return true; // Ignorer pour toute la session
        }
        
        if (rule.type === 'temporaire') {
          const finIgnore = rule.timestamp + rule.dureeMs;
          if (maintenant < finIgnore) {
            return true; // Encore dans la période d'ignore
          }
        }
      }
    }
    
    // Nettoyer les règles expirées
    this.nettoyerReglesExpirees();
    return false;
  }

  /**
   * Sauvegarde une règle d'ignore dans le localStorage
   */
  private sauvegarderRegleIgnore(rule: AlerteIgnoreRule): void {
    const rules = this.obtenirReglesIgnore();
    
    // Supprimer les anciennes règles pour cette ruche
    const rulesFiltrees = rules.filter(r => r.rucheId !== rule.rucheId);
    rulesFiltrees.push(rule);
    
    try {
      localStorage.setItem(this.STORAGE_KEY, JSON.stringify(rulesFiltrees));
    } catch (error) {
      console.error('Erreur sauvegarde règle ignore:', error);
    }
  }

  /**
   * Récupère les règles d'ignore depuis le localStorage
   */
  private obtenirReglesIgnore(): AlerteIgnoreRule[] {
    try {
      const stored = localStorage.getItem(this.STORAGE_KEY);
      return stored ? JSON.parse(stored) : [];
    } catch (error) {
      console.error('Erreur lecture règles ignore:', error);
      return [];
    }
  }

  /**
   * Nettoie les règles expirées
   */
  private nettoyerReglesExpirees(): void {
    const rules = this.obtenirReglesIgnore();
    const maintenant = Date.now();
    
    const rulesValides = rules.filter(rule => {
      if (rule.type === 'session') return true; // Les règles de session ne expirent pas
      if (rule.type === 'temporaire') {
        return maintenant < (rule.timestamp + rule.dureeMs);
      }
      return false;
    });
    
    if (rulesValides.length !== rules.length) {
      try {
        localStorage.setItem(this.STORAGE_KEY, JSON.stringify(rulesValides));
      } catch (error) {
        console.error('Erreur nettoyage règles:', error);
      }
    }
  }

  /**
   * Réactive les alertes pour une ruche
   */
  public reactiverAlertes(rucheId: string): void {
    const rules = this.obtenirReglesIgnore();
    const rulesFiltrees = rules.filter(r => r.rucheId !== rucheId);
    
    try {
      localStorage.setItem(this.STORAGE_KEY, JSON.stringify(rulesFiltrees));
      console.log(`🔊 Alertes réactivées pour ruche ${rucheId}`);
    } catch (error) {
      console.error('Erreur réactivation alertes:', error);
    }
  }

  /**
   * Obtient le statut d'ignore pour une ruche
   */
  public obtenirStatutIgnore(rucheId: string): { ignore: boolean; type?: string; finIgnore?: Date } {
    const rules = this.obtenirReglesIgnore();
    const maintenant = Date.now();
    
    for (const rule of rules) {
      if (rule.rucheId === rucheId) {
        if (rule.type === 'session') {
          return { ignore: true, type: 'session' };
        }
        
        if (rule.type === 'temporaire') {
          const finIgnore = rule.timestamp + rule.dureeMs;
          if (maintenant < finIgnore) {
            return { 
              ignore: true, 
              type: 'temporaire', 
              finIgnore: new Date(finIgnore) 
            };
          }
        }
      }
    }
    
    return { ignore: false };
  }
} 