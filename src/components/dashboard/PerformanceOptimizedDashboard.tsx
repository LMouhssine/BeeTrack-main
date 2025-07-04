import React, { useState, useEffect, useMemo, useCallback, lazy, Suspense } from 'react';
import { Clock } from 'lucide-react';
import { RucheService, RucheAvecRucher } from '../../services/rucheService';
import { useAlertesCouvercle } from '../../hooks/useAlertesCouvercle';
import { useNotifications } from '../../hooks/useNotifications';
import ActivityService from '../../services/activityService';
import { RecentActivity } from './ActivityFeed';

// Lazy imports pour le code splitting
const StatsCards = lazy(() => import('./StatsCards'));
const MobileOptimizedStats = lazy(() => import('./MobileOptimizedStats'));
const ActivityFeed = lazy(() => import('./ActivityFeed'));
const QuickActions = lazy(() => import('./QuickActions'));
const ChartSection = lazy(() => import('./ChartSection'));

import { useResponsive } from './ResponsiveContainer';

interface DashboardProps {
  user: any;
  apiculteur: any;
  onNavigate?: (tab: string) => void;
}

// Composant de fallback pour le chargement
const ComponentSkeleton: React.FC<{ height?: string; className?: string }> = ({ 
  height = 'h-32', 
  className = '' 
}) => (
  <div className={`bg-gray-200 rounded-xl animate-pulse ${height} ${className}`}></div>
);

const PerformanceOptimizedDashboard: React.FC<DashboardProps> = ({ 
  user, 
  apiculteur, 
  onNavigate 
}) => {
  // Hook responsive avec memoization
  const { isMobile, isTablet } = useResponsive();
  
  // État principal
  const [currentTime, setCurrentTime] = useState(new Date());
  const [loading, setLoading] = useState(true);
  const [ruches, setRuches] = useState<RucheAvecRucher[]>([]);
  const [selectedRucheId, setSelectedRucheId] = useState<string>('');
  const [loadingRuches, setLoadingRuches] = useState(false);
  const [activities, setActivities] = useState<RecentActivity[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  // Hooks pour notifications et alertes avec memoization
  const { addNotification } = useNotifications();
  const alertes = useAlertesCouvercle({
    apiculteurId: apiculteur?.id || '',
    onNotification: addNotification
  });

  // Service d'activités avec memoization
  const activityService = useMemo(() => ActivityService.getInstance(), []);

  // Données calculées avec memoization optimisée
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

  // Formatage de l'heure avec memoization
  const formattedTime = useMemo(() => ({
    date: currentTime.toLocaleDateString('fr-FR', { 
      weekday: 'long', 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    }),
    time: currentTime.toLocaleTimeString('fr-FR', { 
      hour: '2-digit', 
      minute: '2-digit' 
    })
  }), [currentTime]);

  // Horloge en temps réel avec optimisation
  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 60000); // Mise à jour chaque minute au lieu de chaque seconde

    return () => clearInterval(timer);
  }, []);

  // Chargement initial optimisé
  useEffect(() => {
    const loadInitialData = async () => {
      setLoading(true);
      try {
        // Chargement en parallèle
        const [ruchesData] = await Promise.all([
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
  }, []); // Dépendances optimisées

  // Écouter les changements d'activités avec cleanup optimisé
  useEffect(() => {
    const unsubscribe = activityService.addListener(setActivities);
    return unsubscribe;
  }, [activityService]);

  // Charger les ruches avec memoization
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

      return ruchesData;
    } catch (error) {
      console.error('Erreur lors du chargement des ruches:', error);
      addNotification('Erreur lors du chargement des ruches', 'error');
      return [];
    } finally {
      setLoadingRuches(false);
    }
  }, [selectedRucheId, alertes, addNotification]);

  // Charger les activités avec memoization
  const loadActivities = useCallback(async () => {
    try {
      const existingActivities = activityService.getActivities();
      setActivities(existingActivities);

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

  // Gestionnaires d'événements avec memoization
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

  // Gestionnaire de clic sur une activité avec memoization
  const handleActivityClick = useCallback((activity: RecentActivity) => {
    activityService.markAsRead(activity.id);
    
    if (activity.rucheId && onNavigate) {
      onNavigate('ruches');
    }
  }, [activityService, onNavigate]);

  // Gestionnaire de changement de ruche avec memoization
  const handleRucheChange = useCallback((rucheId: string) => {
    setSelectedRucheId(rucheId);
  }, []);

  // Gestionnaire de clic sur les cartes de stats avec memoization
  const handleStatsCardClick = useCallback((cardType: string) => {
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
  }, [onNavigate, quickActionHandlers]);

  // Configuration du layout responsive avec memoization
  const layoutConfig = useMemo(() => ({
    containerClass: `p-4 sm:p-6 space-y-4 sm:space-y-6 ${isMobile ? 'pb-20' : ''}`,
    titleClass: `font-bold text-gray-900 ${isMobile ? 'text-2xl' : 'text-3xl'}`,
    subtitleClass: `mt-1 text-gray-600 ${isMobile ? 'text-sm' : ''}`,
    mainGridClass: `grid gap-4 sm:gap-6 ${
      isMobile 
        ? 'grid-cols-1' 
        : isTablet 
          ? 'grid-cols-1' 
          : 'grid-cols-1 lg:grid-cols-3'
    }`,
    chartSectionClass: isMobile || isTablet ? 'order-1' : 'lg:col-span-2',
    activitySectionClass: isMobile || isTablet ? 'order-2' : '',
    actionsSectionClass: isMobile ? 'order-3' : ''
  }), [isMobile, isTablet]);

  // Affichage du skeleton de chargement optimisé
  if (loading) {
    return (
      <div className="p-4 sm:p-6">
        <div className="animate-pulse space-y-6">
          <div className="h-8 bg-gray-200 rounded w-1/3 mb-6"></div>
          <div className={`grid gap-4 ${isMobile ? 'grid-cols-2' : 'grid-cols-4'}`}>
            {[...Array(4)].map((_, i) => (
              <ComponentSkeleton key={i} height="h-24" />
            ))}
          </div>
          <div className={`grid gap-6 ${isMobile ? 'grid-cols-1' : 'grid-cols-3'}`}>
            <ComponentSkeleton className="lg:col-span-2" height="h-96" />
            <ComponentSkeleton height="h-96" />
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className={layoutConfig.containerClass}>
      {/* En-tête du dashboard */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className={layoutConfig.titleClass}>
            Tableau de bord
          </h1>
          <p className={layoutConfig.subtitleClass}>
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
              <span className="text-sm font-medium">{formattedTime.date}</span>
              <span className="text-lg font-mono">{formattedTime.time}</span>
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

      {/* Cartes de statistiques avec lazy loading */}
      <Suspense fallback={<ComponentSkeleton height="h-24" />}>
        {isMobile || isTablet ? (
          <MobileOptimizedStats
            {...statsData}
            loading={loadingRuches}
            onCardClick={handleStatsCardClick}
          />
        ) : (
          <StatsCards
            {...statsData}
            loading={loadingRuches}
          />
        )}
      </Suspense>

      {/* Contenu principal */}
      <div className={layoutConfig.mainGridClass}>
        {/* Section des graphiques */}
        <div className={layoutConfig.chartSectionClass}>
          <Suspense fallback={<ComponentSkeleton height="h-96" />}>
            <ChartSection
              ruches={ruches}
              selectedRucheId={selectedRucheId}
              onRucheChange={handleRucheChange}
              loading={loadingRuches}
              onAddRuche={quickActionHandlers.onAddRuche}
              onRefreshData={refreshAllData}
            />
          </Suspense>
        </div>

        {/* Flux d'activités */}
        <div className={layoutConfig.activitySectionClass}>
          <Suspense fallback={<ComponentSkeleton height="h-96" />}>
            <ActivityFeed
              activities={activities}
              loading={false}
              onActivityClick={handleActivityClick}
              onRefresh={loadActivities}
              maxItems={isMobile ? 5 : 10}
              showFilters={!isMobile}
            />
          </Suspense>
        </div>
      </div>

      {/* Actions rapides */}
      <div className={layoutConfig.actionsSectionClass}>
        <Suspense fallback={<ComponentSkeleton height="h-32" />}>
          <QuickActions
            {...quickActionHandlers}
            activeAlertsCount={statsData.activeAlertsCount}
          />
        </Suspense>
      </div>
    </div>
  );
};

export default PerformanceOptimizedDashboard; 