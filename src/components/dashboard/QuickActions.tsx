import React, { useState } from 'react';
import { 
  Hexagon, 
  BarChart3, 
  Settings, 
  Plus, 
  Bell,
  Download,
  Upload,
  Calendar,
  AlertTriangle,
  Activity,
  MapPin
} from 'lucide-react';

interface QuickAction {
  id: string;
  title: string;
  description: string;
  icon: React.ElementType;
  color: string;
  action: () => void;
  disabled?: boolean;
  badge?: string | number;
}

interface QuickActionsProps {
  onAddRuche?: () => void;
  onGenerateReport?: () => void;
  onOpenSettings?: () => void;
  onAddRucher?: () => void;
  onViewAlerts?: () => void;
  onExportData?: () => void;
  onImportData?: () => void;
  onScheduleMaintenance?: () => void;
  onViewStats?: () => void;
  activeAlertsCount?: number;
  className?: string;
}

const QuickActions: React.FC<QuickActionsProps> = ({
  onAddRuche,
  onGenerateReport,
  onOpenSettings,
  onAddRucher,
  onViewAlerts,
  onExportData,
  onImportData,
  onScheduleMaintenance,
  onViewStats,
  activeAlertsCount = 0,
  className = ""
}) => {
  const [loadingAction, setLoadingAction] = useState<string | null>(null);

  const handleActionClick = async (actionId: string, action: () => void) => {
    if (loadingAction) return;
    
    setLoadingAction(actionId);
    try {
      await action();
    } catch (error) {
      console.error('Erreur lors de l\'exécution de l\'action:', error);
    } finally {
      setLoadingAction(null);
    }
  };

  const quickActions: QuickAction[] = [
    {
      id: 'add-ruche',
      title: 'Ajouter une ruche',
      description: 'Enregistrer une nouvelle ruche',
      icon: Hexagon,
      color: 'from-amber-500 to-amber-600',
      action: onAddRuche || (() => {}),
      disabled: !onAddRuche
    },
    {
      id: 'add-rucher',
      title: 'Nouveau rucher',
      description: 'Créer un nouveau rucher',
      icon: MapPin,
      color: 'from-green-500 to-green-600',
      action: onAddRucher || (() => {}),
      disabled: !onAddRucher
    },
    {
      id: 'view-alerts',
      title: 'Alertes actives',
      description: 'Consulter les alertes en cours',
      icon: AlertTriangle,
      color: activeAlertsCount > 0 ? 'from-red-500 to-red-600' : 'from-gray-400 to-gray-500',
      action: onViewAlerts || (() => {}),
      disabled: !onViewAlerts,
      badge: activeAlertsCount > 0 ? activeAlertsCount : undefined
    },
    {
      id: 'generate-report',
      title: 'Rapport mensuel',
      description: 'Générer un rapport détaillé',
      icon: BarChart3,
      color: 'from-blue-500 to-blue-600',
      action: onGenerateReport || (() => {}),
      disabled: !onGenerateReport
    },
    {
      id: 'view-stats',
      title: 'Statistiques',
      description: 'Voir les analyses détaillées',
      icon: Activity,
      color: 'from-purple-500 to-purple-600',
      action: onViewStats || (() => {}),
      disabled: !onViewStats
    },
    {
      id: 'schedule-maintenance',
      title: 'Maintenance',
      description: 'Programmer une maintenance',
      icon: Calendar,
      color: 'from-indigo-500 to-indigo-600',
      action: onScheduleMaintenance || (() => {}),
      disabled: !onScheduleMaintenance
    },
    {
      id: 'export-data',
      title: 'Exporter données',
      description: 'Sauvegarder vos données',
      icon: Download,
      color: 'from-teal-500 to-teal-600',
      action: onExportData || (() => {}),
      disabled: !onExportData
    },
    {
      id: 'import-data',
      title: 'Importer données',
      description: 'Charger des données',
      icon: Upload,
      color: 'from-cyan-500 to-cyan-600',
      action: onImportData || (() => {}),
      disabled: !onImportData
    },
    {
      id: 'settings',
      title: 'Configuration',
      description: 'Paramètres et préférences',
      icon: Settings,
      color: 'from-gray-500 to-gray-600',
      action: onOpenSettings || (() => {}),
      disabled: !onOpenSettings
    }
  ];

  // Montrer seulement les 6 actions les plus importantes par défaut
  const priorityActions = quickActions.slice(0, 6);

  return (
    <div className={`space-y-6 ${className}`}>
      <div className="flex items-center justify-between">
        <h3 className="text-xl font-bold text-gray-900">Actions rapides</h3>
        <button className="text-sm text-amber-600 hover:text-amber-700 font-medium">
          Personnaliser
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {priorityActions.map((action, index) => {
          const Icon = action.icon;
          const isLoading = loadingAction === action.id;
          
          return (
            <button
              key={action.id}
              onClick={() => handleActionClick(action.id, action.action)}
              disabled={action.disabled || isLoading}
              className={`relative bg-gradient-to-br ${action.color} rounded-xl shadow-lg hover-lift p-6 text-white transition-all-smooth animate-scale-in group disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100 focus-ring-amber`}
              style={{ animationDelay: `${index * 0.1}s` }}
              aria-label={`${action.title}: ${action.description}`}
            >
              {/* Badge pour les notifications */}
              {action.badge && (
                <span className="absolute -top-2 -right-2 bg-red-500 text-white text-xs font-bold rounded-full w-6 h-6 flex items-center justify-center animate-pulse">
                  {action.badge}
                </span>
              )}

              <div className="flex items-center justify-between">
                <div className="text-left">
                  <h4 className="text-lg font-bold mb-1 group-hover:scale-105 transition-transform">
                    {action.title}
                  </h4>
                  <p className="text-white text-opacity-90 text-sm">
                    {action.description}
                  </p>
                </div>
                <div className="ml-4">
                  {isLoading ? (
                    <div className="animate-spin">
                      <div className="w-8 h-8 border-2 border-white border-t-transparent rounded-full"></div>
                    </div>
                  ) : (
                    <Icon 
                      size={32} 
                      className="text-white text-opacity-80 group-hover:text-opacity-100 group-hover:scale-110 transition-all duration-200" 
                      aria-hidden="true"
                    />
                  )}
                </div>
              </div>

              {/* Indicateur d'état pour certaines actions */}
              {action.id === 'view-alerts' && activeAlertsCount > 0 && (
                <div className="absolute bottom-2 right-2">
                  <div className="w-3 h-3 bg-red-400 rounded-full animate-pulse"></div>
                </div>
              )}
            </button>
          );
        })}
      </div>

      {/* Bouton pour voir toutes les actions */}
      {quickActions.length > priorityActions.length && (
        <div className="text-center">
          <button className="px-6 py-2 text-amber-600 hover:text-amber-700 font-medium border border-amber-200 hover:border-amber-300 rounded-lg transition-colors-smooth focus-ring-amber">
            Voir toutes les actions ({quickActions.length - priorityActions.length} de plus)
          </button>
        </div>
      )}
    </div>
  );
};

export default QuickActions; 