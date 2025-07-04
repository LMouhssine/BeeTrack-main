import React, { useState, useMemo } from 'react';
import { 
  AlertTriangle, 
  Activity, 
  CheckCircle, 
  Calendar, 
  Clock,
  Filter,
  RefreshCw,
  Eye,
  ChevronRight
} from 'lucide-react';

export interface RecentActivity {
  id: string;
  type: 'alert' | 'measure' | 'maintenance' | 'info' | 'connection' | 'system';
  message: string;
  timestamp: Date;
  rucheId?: string;
  rucherName?: string;
  severity?: 'low' | 'medium' | 'high' | 'critical';
  read?: boolean;
}

interface ActivityFeedProps {
  activities: RecentActivity[];
  loading?: boolean;
  onActivityClick?: (activity: RecentActivity) => void;
  onRefresh?: () => void;
  maxItems?: number;
  showFilters?: boolean;
}

const ActivityFeed: React.FC<ActivityFeedProps> = ({
  activities = [],
  loading = false,
  onActivityClick,
  onRefresh,
  maxItems = 10,
  showFilters = true
}) => {
  const [filter, setFilter] = useState<string>('all');
  const [showUnreadOnly, setShowUnreadOnly] = useState(false);

  const filteredActivities = useMemo(() => {
    let filtered = activities;

    if (filter !== 'all') {
      filtered = filtered.filter(activity => activity.type === filter);
    }

    if (showUnreadOnly) {
      filtered = filtered.filter(activity => !activity.read);
    }

    return filtered
      .sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime())
      .slice(0, maxItems);
  }, [activities, filter, showUnreadOnly, maxItems]);

  const getActivityIcon = (type: string) => {
    switch (type) {
      case 'alert': return AlertTriangle;
      case 'measure': return Activity;
      case 'maintenance': return CheckCircle;
      case 'info': return Calendar;
      case 'connection': return Activity;
      case 'system': return CheckCircle;
      default: return Activity;
    }
  };

  const getActivityColor = (type: string, severity?: string) => {
    if (type === 'alert') {
      switch (severity) {
        case 'critical': return 'text-red-600 bg-red-100 border-red-200';
        case 'high': return 'text-red-500 bg-red-50 border-red-100';
        case 'medium': return 'text-orange-500 bg-orange-50 border-orange-100';
        case 'low': return 'text-yellow-500 bg-yellow-50 border-yellow-100';
        default: return 'text-red-500 bg-red-50 border-red-100';
      }
    }

    switch (type) {
      case 'measure': return 'text-blue-500 bg-blue-50 border-blue-100';
      case 'maintenance': return 'text-green-500 bg-green-50 border-green-100';
      case 'connection': return 'text-purple-500 bg-purple-50 border-purple-100';
      case 'system': return 'text-gray-500 bg-gray-50 border-gray-100';
      case 'info': return 'text-gray-500 bg-gray-50 border-gray-100';
      default: return 'text-gray-500 bg-gray-50 border-gray-100';
    }
  };

  const formatTimeAgo = (date: Date) => {
    const diffMs = Date.now() - date.getTime();
    const diffMins = Math.floor(diffMs / (1000 * 60));
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
    
    if (diffMins < 1) {
      return 'À l\'instant';
    } else if (diffMins < 60) {
      return `il y a ${diffMins} min`;
    } else if (diffHours < 24) {
      return `il y a ${diffHours}h`;
    } else if (diffDays < 7) {
      return `il y a ${diffDays}j`;
    } else {
      return date.toLocaleDateString('fr-FR', { 
        day: 'numeric', 
        month: 'short' 
      });
    }
  };

  const getTypeLabel = (type: string) => {
    switch (type) {
      case 'alert': return 'Alertes';
      case 'measure': return 'Mesures';
      case 'maintenance': return 'Maintenance';
      case 'connection': return 'Connexions';
      case 'system': return 'Système';
      case 'info': return 'Informations';
      default: return 'Tout';
    }
  };

  const ActivitySkeleton = () => (
    <div className="flex items-start space-x-3 p-3 rounded-lg animate-pulse">
      <div className="w-8 h-8 bg-gray-200 rounded-full flex-shrink-0"></div>
      <div className="flex-1 min-w-0 space-y-2">
        <div className="h-4 bg-gray-200 rounded w-3/4"></div>
        <div className="h-3 bg-gray-200 rounded w-1/2"></div>
      </div>
    </div>
  );

  if (loading) {
    return (
      <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-100">
        <div className="flex items-center justify-between mb-6">
          <div className="h-6 bg-gray-200 rounded w-1/3 animate-pulse"></div>
          <div className="w-8 h-8 bg-gray-200 rounded animate-pulse"></div>
        </div>
        <div className="space-y-4">
          {[...Array(5)].map((_, index) => (
            <ActivitySkeleton key={index} />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-100 animate-slide-in-right">
      {/* En-tête avec filtres */}
      <div className="flex flex-col space-y-4 mb-6">
        <div className="flex items-center justify-between">
          <h3 className="text-xl font-bold text-gray-900">Activité récente</h3>
          <div className="flex items-center space-x-2">
            {onRefresh && (
              <button
                onClick={onRefresh}
                className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
                title="Actualiser"
                aria-label="Actualiser les activités"
              >
                <RefreshCw size={18} />
              </button>
            )}
          </div>
        </div>

        {showFilters && (
          <div className="flex flex-wrap items-center gap-2">
            <div className="flex items-center space-x-2">
              <Filter size={16} className="text-gray-400" />
              <select
                value={filter}
                onChange={(e) => setFilter(e.target.value)}
                className="text-sm border border-gray-200 rounded-lg px-3 py-1 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
              >
                <option value="all">Tout</option>
                <option value="alert">Alertes</option>
                <option value="measure">Mesures</option>
                <option value="maintenance">Maintenance</option>
                <option value="connection">Connexions</option>
                <option value="info">Informations</option>
              </select>
            </div>
            
            <label className="flex items-center space-x-1 text-sm">
              <input
                type="checkbox"
                checked={showUnreadOnly}
                onChange={(e) => setShowUnreadOnly(e.target.checked)}
                className="rounded border-gray-300 text-amber-600 focus:ring-amber-500"
              />
              <span className="text-gray-600">Non lues uniquement</span>
            </label>
          </div>
        )}
      </div>

      {/* Liste des activités */}
      <div className="space-y-2 max-h-96 overflow-y-auto">
        {filteredActivities.length === 0 ? (
          <div className="text-center py-8">
            <Activity size={48} className="text-gray-300 mx-auto mb-4" />
            <p className="text-gray-500 font-medium">Aucune activité</p>
            <p className="text-gray-400 text-sm">
              {filter !== 'all' 
                ? `Aucune activité de type "${getTypeLabel(filter)}" trouvée`
                : 'Les activités récentes apparaîtront ici'
              }
            </p>
          </div>
        ) : (
          filteredActivities.map((activity) => {
            const Icon = getActivityIcon(activity.type);
            const colorClass = getActivityColor(activity.type, activity.severity);
            
            return (
              <div 
                key={activity.id} 
                className={`flex items-start space-x-3 p-3 rounded-lg transition-all duration-200 ${
                  activity.read ? 'hover:bg-gray-50' : 'bg-blue-50 hover:bg-blue-100 border-l-4 border-l-blue-400'
                } ${onActivityClick ? 'cursor-pointer' : ''}`}
                onClick={() => onActivityClick?.(activity)}
                role={onActivityClick ? 'button' : undefined}
                tabIndex={onActivityClick ? 0 : undefined}
                aria-label={`Activité: ${activity.message}`}
              >
                <div className={`p-2 rounded-full border ${colorClass} flex-shrink-0`}>
                  <Icon size={16} />
                </div>
                <div className="flex-1 min-w-0">
                  <p className={`text-sm leading-relaxed ${activity.read ? 'text-gray-900' : 'text-gray-900 font-medium'}`}>
                    {activity.message}
                  </p>
                  <div className="flex items-center mt-1 space-x-2 text-xs">
                    <Clock size={12} className="text-gray-400" />
                    <span className="text-gray-500">
                      {formatTimeAgo(activity.timestamp)}
                    </span>
                    {activity.rucheId && (
                      <>
                        <span className="text-gray-300">•</span>
                        <span className="text-amber-600 font-medium">
                          {activity.rucheId}
                        </span>
                      </>
                    )}
                    {activity.rucherName && (
                      <>
                        <span className="text-gray-300">•</span>
                        <span className="text-blue-600 font-medium">
                          {activity.rucherName}
                        </span>
                      </>
                    )}
                    {!activity.read && (
                      <>
                        <span className="text-gray-300">•</span>
                        <span className="text-blue-600 text-xs font-medium">
                          Nouveau
                        </span>
                      </>
                    )}
                  </div>
                </div>
                {onActivityClick && (
                  <ChevronRight size={16} className="text-gray-400 flex-shrink-0 mt-1" />
                )}
              </div>
            );
          })
        )}
      </div>
      
      {/* Bouton voir plus */}
      {activities.length > maxItems && (
        <button className="w-full mt-4 py-2 text-sm text-amber-600 hover:text-amber-700 font-medium border border-amber-200 hover:border-amber-300 rounded-lg transition-colors-smooth focus-ring-amber">
          Voir toute l'activité ({activities.length - filteredActivities.length} de plus)
        </button>
      )}
    </div>
  );
};

export default ActivityFeed; 