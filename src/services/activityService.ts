import { RecentActivity } from '../components/dashboard/ActivityFeed';
import { RucheService, RucheAvecRucher } from './rucheService';
import { DonneesCapteursService } from './donneesCapteursService';

export class ActivityService {
  private static instance: ActivityService;
  private activities: RecentActivity[] = [];
  private listeners: ((activities: RecentActivity[]) => void)[] = [];

  private constructor() {}

  static getInstance(): ActivityService {
    if (!ActivityService.instance) {
      ActivityService.instance = new ActivityService();
    }
    return ActivityService.instance;
  }

  // Ajouter un listener pour les changements d'activités
  addListener(callback: (activities: RecentActivity[]) => void): () => void {
    this.listeners.push(callback);
    return () => {
      this.listeners = this.listeners.filter(listener => listener !== callback);
    };
  }

  // Notifier tous les listeners
  private notifyListeners(): void {
    this.listeners.forEach(listener => listener([...this.activities]));
  }

  // Ajouter une nouvelle activité
  addActivity(activity: Omit<RecentActivity, 'id' | 'timestamp'>): void {
    const newActivity: RecentActivity = {
      ...activity,
      id: `activity_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      timestamp: new Date(),
      read: false
    };

    this.activities.unshift(newActivity);
    
    // Garder seulement les 100 dernières activités
    if (this.activities.length > 100) {
      this.activities = this.activities.slice(0, 100);
    }

    this.notifyListeners();
  }

  // Marquer une activité comme lue
  markAsRead(activityId: string): void {
    const activity = this.activities.find(a => a.id === activityId);
    if (activity) {
      activity.read = true;
      this.notifyListeners();
    }
  }

  // Marquer toutes les activités comme lues
  markAllAsRead(): void {
    this.activities.forEach(activity => {
      activity.read = true;
    });
    this.notifyListeners();
  }

  // Obtenir toutes les activités
  getActivities(): RecentActivity[] {
    return [...this.activities];
  }

  // Obtenir les activités non lues
  getUnreadActivities(): RecentActivity[] {
    return this.activities.filter(activity => !activity.read);
  }

  // Obtenir le nombre d'activités non lues
  getUnreadCount(): number {
    return this.getUnreadActivities().length;
  }

  // Générer des activités basées sur les données réelles du système
  async generateActivitiesFromSystemData(): Promise<void> {
    try {
      // Récupérer les ruches pour générer des activités
      const ruches = await RucheService.obtenirRuchesUtilisateur();
      
      // Générer des activités pour les nouvelles mesures
      for (const ruche of ruches) {
        if (ruche.id) {
          await this.generateMeasureActivities(ruche);
        }
      }

      // Générer des activités pour les connexions/déconnexions
      this.generateConnectionActivities(ruches);

      // Générer des activités système
      this.generateSystemActivities();

    } catch (error) {
      console.error('Erreur lors de la génération des activités:', error);
      this.addActivity({
        type: 'system',
        message: 'Erreur lors du chargement des activités récentes',
        severity: 'high'
      });
    }
  }

  // Générer des activités pour les mesures
  private async generateMeasureActivities(ruche: RucheAvecRucher): Promise<void> {
    try {
      if (!ruche.id) return;

      // Récupérer les dernières mesures
      const mesures = await DonneesCapteursService.obtenirDernieresMesures(ruche.id, 5);
      
      for (const mesure of mesures) {
        // Vérifier si c'est une mesure récente (moins de 2 heures)
        const measureTime = new Date(mesure.horodatage || Date.now());
        const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000);
        
        if (measureTime > twoHoursAgo) {
          // Générer des alertes si les valeurs sont anormales
          this.checkForAlerts(ruche, mesure);
          
          // Ajouter une activité de mesure normale
          this.addActivity({
            type: 'measure',
            message: `Nouvelles données reçues de ${ruche.nom}`,
            rucheId: ruche.id,
            rucherName: ruche.rucherNom,
            severity: 'low'
          });
        }
      }
    } catch (error) {
      console.error(`Erreur lors de la génération des activités de mesure pour ${ruche.nom}:`, error);
    }
  }

  // Vérifier et générer des alertes basées sur les mesures
  private checkForAlerts(ruche: RucheAvecRucher, mesure: any): void {
    const alerts: { condition: boolean; message: string; severity: 'medium' | 'high' | 'critical' }[] = [
      {
        condition: mesure.temperature && (mesure.temperature > 40 || mesure.temperature < 10),
        message: `Température anormale (${mesure.temperature}°C) détectée dans ${ruche.nom}`,
        severity: mesure.temperature > 45 || mesure.temperature < 5 ? 'critical' : 'high'
      },
      {
        condition: mesure.humidite && (mesure.humidite > 80 || mesure.humidite < 30),
        message: `Humidité anormale (${mesure.humidite}%) détectée dans ${ruche.nom}`,
        severity: 'medium'
      },
      {
        condition: mesure.poids && mesure.poids < 10,
        message: `Poids faible (${mesure.poids}kg) détecté dans ${ruche.nom} - Risque d'essaimage`,
        severity: 'high'
      },
      {
        condition: mesure.activiteEntrees !== undefined && mesure.activiteEntrees < 5,
        message: `Activité faible détectée dans ${ruche.nom} - Vérification recommandée`,
        severity: 'medium'
      }
    ];

    alerts.forEach(alert => {
      if (alert.condition) {
        this.addActivity({
          type: 'alert',
          message: alert.message,
          rucheId: ruche.id,
          rucherName: ruche.rucherNom,
          severity: alert.severity
        });
      }
    });
  }

  // Générer des activités de connexion
  private generateConnectionActivities(ruches: RucheAvecRucher[]): void {
    ruches.forEach(ruche => {
      // Simuler des événements de connexion basés sur l'état de service
      if (!ruche.enService) {
        this.addActivity({
          type: 'connection',
          message: `${ruche.nom} est hors ligne - Vérification de la connectivité nécessaire`,
          rucheId: ruche.id,
          rucherName: ruche.rucherNom,
          severity: 'medium'
        });
      }
    });
  }

  // Générer des activités système
  private generateSystemActivities(): void {
    const now = new Date();
    const lastBackup = new Date(now.getTime() - 24 * 60 * 60 * 1000); // 24h ago
    
    // Vérifier si une sauvegarde est nécessaire
    if (now.getTime() - lastBackup.getTime() > 7 * 24 * 60 * 60 * 1000) { // 7 jours
      this.addActivity({
        type: 'system',
        message: 'Sauvegarde hebdomadaire recommandée - Exportez vos données',
        severity: 'low'
      });
    }

    // Activité de maintenance programmée
    const dayOfWeek = now.getDay();
    const hour = now.getHours();
    
    if (dayOfWeek === 1 && hour === 8) { // Lundi 8h
      this.addActivity({
        type: 'maintenance',
        message: 'Maintenance hebdomadaire programmée - Vérification des capteurs recommandée',
        severity: 'low'
      });
    }
  }

  // Simuler des activités pour les tests
  generateSampleActivities(): void {
    const sampleActivities = [
      {
        type: 'alert' as const,
        message: 'Température élevée détectée dans la ruche Abeille-01',
        rucheId: 'ruche-001',
        rucherName: 'Rucher Principal',
        severity: 'high' as const
      },
      {
        type: 'measure' as const,
        message: 'Nouvelle mesure reçue de la ruche Abeille-02',
        rucheId: 'ruche-002',
        rucherName: 'Rucher Nord',
        severity: 'low' as const
      },
      {
        type: 'maintenance' as const,
        message: 'Maintenance programmée pour le rucher Principal',
        rucherName: 'Rucher Principal',
        severity: 'medium' as const
      },
      {
        type: 'info' as const,
        message: 'Rapport mensuel généré avec succès',
        severity: 'low' as const
      }
    ];

    sampleActivities.forEach((activity, index) => {
      setTimeout(() => {
        this.addActivity(activity);
      }, index * 500);
    });
  }

  // Nettoyer les anciennes activités
  cleanOldActivities(maxAge: number = 30): void {
    const cutoff = new Date(Date.now() - maxAge * 24 * 60 * 60 * 1000);
    this.activities = this.activities.filter(activity => activity.timestamp > cutoff);
    this.notifyListeners();
  }
}

export default ActivityService; 