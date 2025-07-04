import React, { useState, useEffect, useMemo, useCallback } from 'react';
import { 
  TrendingUp, 
  TrendingDown, 
  AlertTriangle, 
  CheckCircle, 
  Thermometer, 
  Droplets, 
  Weight,
  Battery,
  Wifi,
  Home,
  Hexagon,
  Activity,
  Calendar,
  Clock,
  BarChart3,
  Settings,
  ChevronDown
} from 'lucide-react';
import { RucheService, RucheAvecRucher } from '../services/rucheService';
import { useAlertesCouvercle } from '../hooks/useAlertesCouvercle';
import { useNotifications } from '../hooks/useNotifications';
import ActivityService from '../services/activityService';
import { RecentActivity } from './dashboard/ActivityFeed';

// Composants modulaires
import StatsCards from './dashboard/StatsCards';
import MobileOptimizedStats from './dashboard/MobileOptimizedStats';
import ActivityFeed from './dashboard/ActivityFeed';
import QuickActions from './dashboard/QuickActions';
import ChartSection from './dashboard/ChartSection';
import { useResponsive } from './dashboard/ResponsiveContainer';
import { LiveRegion, useKeyboardShortcuts } from './dashboard/AccessibleComponents';
import { DashboardSkeleton } from './dashboard/LoadingStates';

interface DashboardProps {
  user: any;
  apiculteur: any;
  onNavigate?: (tab: string) => void;
}

const Dashboard: React.FC<DashboardProps> = ({ user, apiculteur, onNavigate }) => {
  // Hook responsive
  const { isMobile, isTablet } = useResponsive();
  
  // État principal
  const [currentTime, setCurrentTime] = useState(new Date());
  const [loading, setLoading] = useState(true);
  const [ruches, setRuches] = useState<RucheAvecRucher[]>([]);
  const [selectedRucheId, setSelectedRucheId] = useState<string>('');
  const [loadingRuches, setLoadingRuches] = useState(false);
  const [activities, setActivities] = useState<RecentActivity[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  // Hooks pour notifications et alertes
  const { addNotification } = useNotifications();
  const alertes = useAlertesCouvercle({
    apiculteurId: apiculteur?.id || '',
    onNotification: addNotification
  });

  // Service d'activités
  const activityService = useMemo(() => ActivityService.getInstance(), []);

  // Données calculées
  const statsData = useMemo(() => {
    const rucherCount = new Set(ruches.map(r => r.idRucher)).size;
    const rucheCount = ruches.length;
    const onlineRuchesCount = ruches.filter(r => r.enService).length;
    const activeAlertsCount = alertes.alerteActive ? 1 : 0;

    return {
      rucherCount,
      rucheCount,
      activeAlertsCount,
      onlineRuchesCount,
      totalRuchesCount: rucheCount
    };
  }, [ruches, alertes.alerteActive]);

  // Horloge en temps réel avec optimisation (mise à jour chaque minute)
  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 60000); // 60 secondes au lieu d'1 seconde

    // Mise à jour immédiate
    setCurrentTime(new Date());
    
    return () => clearInterval(timer);
  }, []);

  // Chargement initial
  useEffect(() => {
    const loadInitialData = async () => {
      setLoading(true);
      try {
        await Promise.all([
          loadRuches(),
          loadActivities()
        ]);
      } catch (error) {
        console.error('Erreur lors du chargement initial:', error);
        addNotification('Erreur lors du chargement des données', 'error');
      } finally {
        setLoading(false);
      }
    };

    loadInitialData();
  }, []);

  // Écouter les changements d'activités
  useEffect(() => {
    const unsubscribe = activityService.addListener(setActivities);
    return unsubscribe;
  }, [activityService]);

  // Charger les ruches
  const loadRuches = useCallback(async () => {
    try {
      setLoadingRuches(true);
      const ruchesData = await RucheService.obtenirRuchesUtilisateur();
      setRuches(ruchesData);
      
      // Sélectionner automatiquement la première ruche si elle existe
      if (ruchesData.length > 0 && !selectedRucheId) {
        setSelectedRucheId(ruchesData[0].id!);
      }

      // Démarrer la surveillance des alertes pour toutes les ruches
      ruchesData.forEach(ruche => {
        if (ruche.id && ruche.enService) {
          alertes.demarrerSurveillance(ruche.id, ruche.nom);
        }
      });

    } catch (error) {
      console.error('Erreur lors du chargement des ruches:', error);
      addNotification('Erreur lors du chargement des ruches', 'error');
    } finally {
      setLoadingRuches(false);
    }
  }, [selectedRucheId, alertes, addNotification]);

  // Charger les activités
  const loadActivities = useCallback(async () => {
    try {
      // Charger les activités existantes
      const existingActivities = activityService.getActivities();
      setActivities(existingActivities);

      // Générer des activités d'exemple si aucune n'existe
      if (existingActivities.length === 0) {
        activityService.generateSampleActivities();
      }
    } catch (error) {
      console.error('Erreur lors du chargement des activités:', error);
    }
  }, [activityService]);

  // Rafraîchir toutes les données avec debouncing
  const refreshAllData = useCallback(async () => {
    if (refreshing) return; // Éviter les appels multiples
    
    setRefreshing(true);
    try {
      await Promise.all([
        loadRuches(),
        loadActivities()
      ]);
      addNotification('Données actualisées avec succès', 'success');
    } catch (error) {
      console.error('Erreur lors de l\'actualisation:', error);
      addNotification('Erreur lors de l\'actualisation', 'error');
    } finally {
      setRefreshing(false);
    }
  }, [loadRuches, loadActivities, addNotification, refreshing]);

  // Gestionnaires d'événements pour les actions rapides avec memoization
  const quickActionHandlers = useMemo(() => ({
    onAddRuche: () => onNavigate?.('ruches'),
    onAddRucher: () => onNavigate?.('ruchers'),
    onViewAlerts: () => {
      console.log('Affichage des alertes');
    },
    onGenerateReport: () => onNavigate?.('statistiques'),
    onViewStats: () => onNavigate?.('statistiques'),
    onOpenSettings: () => {
      console.log('Ouverture des paramètres');
    },
    onExportData: () => {
      console.log('Export des données');
      addNotification('Export des données en cours...', 'success');
    },
    onScheduleMaintenance: () => {
      console.log('Programmation de maintenance');
      activityService.addActivity({
        type: 'maintenance',
        message: 'Maintenance programmée pour demain matin',
        severity: 'medium'
      });
      addNotification('Maintenance programmée', 'success');
    }
  }), [onNavigate, addNotification, activityService]);

  // Gestionnaire de clic sur une activité
  const handleActivityClick = useCallback((activity: RecentActivity) => {
    activityService.markAsRead(activity.id);
    
    // Navigation basée sur le type d'activité
    if (activity.rucheId && onNavigate) {
      onNavigate('ruches');
    }
  }, [activityService, onNavigate]);

  // Gestionnaire de changement de ruche
  const handleRucheChange = useCallback((rucheId: string) => {
    setSelectedRucheId(rucheId);
  }, []);

  // Raccourcis clavier pour l'accessibilité
  useKeyboardShortcuts({
    'r': () => refreshAllData(), // R pour rafraîchir
    'a': () => onNavigate?.('ruches'), // A pour ajouter une ruche
    'h': () => onNavigate?.('ruchers'), // H pour aller aux ruchers (homes)
    's': () => onNavigate?.('statistiques'), // S pour statistiques
    '?': () => {
      // Afficher l'aide des raccourcis clavier
      console.log('Raccourcis clavier: R=Rafraîchir, A=Ajouter ruche, H=Ruchers, S=Statistiques');
    }
  });

  // Message live pour les lecteurs d'écran
  const [liveMessage, setLiveMessage] = useState('');
  
  useEffect(() => {
    if (refreshing) {
      setLiveMessage('Actualisation des données en cours...');
    } else if (liveMessage.includes('Actualisation')) {
      setLiveMessage('Données actualisées');
      // Effacer le message après 3 secondes
      setTimeout(() => setLiveMessage(''), 3000);
    }
  }, [refreshing]);

  // Affichage du skeleton de chargement amélioré
  if (loading) {
    return <DashboardSkeleton isMobile={isMobile} />;
  }

  return (
    <div className={`p-4 sm:p-6 space-y-4 sm:space-y-6 ${isMobile ? 'pb-20' : ''}`}>
      {/* Région live pour l'accessibilité */}
      <LiveRegion message={liveMessage} priority="polite" />
      
      {/* En-tête du dashboard */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className={`font-bold text-gray-900 ${isMobile ? 'text-2xl' : 'text-3xl'}`}>
            Tableau de bord
          </h1>
          <p className={`mt-1 text-gray-600 ${isMobile ? 'text-sm' : ''}`}>
            Bienvenue, {apiculteur ? `${apiculteur.prenom} ${apiculteur.nom}` : 'Apiculteur'}
          </p>
        </div>
        {!isMobile && (
          <div className="mt-4 sm:mt-0 flex items-center space-x-4">
            {refreshing && (
              <div className="flex items-center space-x-2 text-amber-600">
                <div className="animate-spin w-4 h-4 border-2 border-amber-600 border-t-transparent rounded-full"></div>
                <span className="text-sm font-medium">Actualisation...</span>
              </div>
            )}
            <div className="flex items-center space-x-2 text-gray-500">
              <Clock size={18} />
              <span className="text-sm font-medium">
                {currentTime.toLocaleDateString('fr-FR', { 
                  weekday: 'long', 
                  year: 'numeric', 
                  month: 'long', 
                  day: 'numeric' 
                })}
              </span>
              <span className="text-lg font-mono">
                {currentTime.toLocaleTimeString('fr-FR', { 
                  hour: '2-digit', 
                  minute: '2-digit' 
                })}
              </span>
            </div>
          </div>
        )}
      </div>

      {/* Indicateur de rafraîchissement mobile */}
      {isMobile && refreshing && (
        <div className="flex items-center justify-center space-x-2 text-amber-600 bg-amber-50 p-3 rounded-lg">
          <div className="animate-spin w-4 h-4 border-2 border-amber-600 border-t-transparent rounded-full"></div>
          <span className="text-sm font-medium">Actualisation en cours...</span>
        </div>
      )}

      {/* Cartes de statistiques */}
      {isMobile || isTablet ? (
        <MobileOptimizedStats
          rucherCount={statsData.rucherCount}
          rucheCount={statsData.rucheCount}
          activeAlertsCount={statsData.activeAlertsCount}
          onlineRuchesCount={statsData.onlineRuchesCount}
          totalRuchesCount={statsData.totalRuchesCount}
          loading={loadingRuches}
          onCardClick={(cardType) => {
            switch (cardType) {
              case 'ruchers':
                onNavigate?.('ruchers');
                break;
              case 'ruches':
                onNavigate?.('ruches');
                break;
              case 'alertes':
                quickActionHandlers.onViewAlerts?.();
                break;
              default:
                break;
            }
          }}
        />
      ) : (
        <StatsCards
          rucherCount={statsData.rucherCount}
          rucheCount={statsData.rucheCount}
          activeAlertsCount={statsData.activeAlertsCount}
          onlineRuchesCount={statsData.onlineRuchesCount}
          totalRuchesCount={statsData.totalRuchesCount}
          loading={loadingRuches}
        />
      )}

      {/* Contenu principal */}
      <div className={`grid gap-4 sm:gap-6 ${
        isMobile 
          ? 'grid-cols-1' 
          : isTablet 
            ? 'grid-cols-1' 
            : 'grid-cols-1 lg:grid-cols-3'
      }`}>
        {/* Section des graphiques */}
        <div className={isMobile || isTablet ? 'order-1' : 'lg:col-span-2'}>
          <ChartSection
            ruches={ruches}
            selectedRucheId={selectedRucheId}
            onRucheChange={handleRucheChange}
            loading={loadingRuches}
            onAddRuche={quickActionHandlers.onAddRuche}
            onRefreshData={refreshAllData}
          />
        </div>

        {/* Flux d'activités */}
        <div className={`${isMobile || isTablet ? 'order-2' : ''} flex flex-col`}>
          <ActivityFeed
            activities={activities}
            loading={false}
            onActivityClick={handleActivityClick}
            onRefresh={loadActivities}
            maxItems={isMobile ? 4 : 8}
            showFilters={!isMobile}
          />
        </div>
      </div>

      {/* Actions rapides */}
      <div className={isMobile ? 'order-3' : ''}>
        <QuickActions
          {...quickActionHandlers}
          activeAlertsCount={statsData.activeAlertsCount}
        />
      </div>
    </div>
  );
};

export default Dashboard; 