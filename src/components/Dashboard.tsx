import React, { useState, useEffect } from 'react';
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
  Settings
} from 'lucide-react';

interface DashboardProps {
  user: any;
  apiculteur: any;
}

interface StatCard {
  title: string;
  value: string | number;
  icon: React.ElementType;
  trend?: {
    value: number;
    isPositive: boolean;
  };
  color: string;
}

interface RecentActivity {
  id: string;
  type: 'alert' | 'measure' | 'maintenance' | 'info';
  message: string;
  timestamp: Date;
  rucheId?: string;
}

const Dashboard: React.FC<DashboardProps> = ({ user, apiculteur }) => {
  const [currentTime, setCurrentTime] = useState(new Date());
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    // Simuler le chargement des données
    const loadTimer = setTimeout(() => {
      setLoading(false);
    }, 1500);

    return () => {
      clearInterval(timer);
      clearTimeout(loadTimer);
    };
  }, []);

  // Données statistiques mockées (à remplacer par les vraies données)
  const statsCards: StatCard[] = [
    {
      title: 'Ruchers actifs',
      value: 5,
      icon: Home,
      trend: { value: 12, isPositive: true },
      color: 'bg-blue-500'
    },
    {
      title: 'Ruches surveillées',
      value: 23,
      icon: Hexagon,
      trend: { value: 8, isPositive: true },
      color: 'bg-amber-500'
    },
    {
      title: 'Alertes actives',
      value: 2,
      icon: AlertTriangle,
      trend: { value: 15, isPositive: false },
      color: 'bg-red-500'
    },
    {
      title: 'Ruches en ligne',
      value: '21/23',
      icon: Wifi,
      trend: { value: 95, isPositive: true },
      color: 'bg-green-500'
    }
  ];

  const recentActivities: RecentActivity[] = [
    {
      id: '1',
      type: 'alert',
      message: 'Température élevée détectée dans la ruche R-003',
      timestamp: new Date(Date.now() - 1000 * 60 * 15),
      rucheId: 'R-003'
    },
    {
      id: '2',
      type: 'measure',
      message: 'Nouvelle mesure reçue de la ruche R-007',
      timestamp: new Date(Date.now() - 1000 * 60 * 30),
      rucheId: 'R-007'
    },
    {
      id: '3',
      type: 'maintenance',
      message: 'Maintenance programmée pour le rucher Nord',
      timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2),
    },
    {
      id: '4',
      type: 'info',
      message: 'Rapport hebdomadaire généré avec succès',
      timestamp: new Date(Date.now() - 1000 * 60 * 60 * 4),
    }
  ];

  const getActivityIcon = (type: string) => {
    switch (type) {
      case 'alert': return AlertTriangle;
      case 'measure': return Activity;
      case 'maintenance': return CheckCircle;
      case 'info': return Calendar;
      default: return Activity;
    }
  };

  const getActivityColor = (type: string) => {
    switch (type) {
      case 'alert': return 'text-red-500 bg-red-50';
      case 'measure': return 'text-blue-500 bg-blue-50';
      case 'maintenance': return 'text-green-500 bg-green-50';
      case 'info': return 'text-gray-500 bg-gray-50';
      default: return 'text-gray-500 bg-gray-50';
    }
  };

  const formatTimeAgo = (date: Date) => {
    const diffMs = Date.now() - date.getTime();
    const diffMins = Math.floor(diffMs / (1000 * 60));
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
    
    if (diffMins < 60) {
      return `il y a ${diffMins} min`;
    } else if (diffHours < 24) {
      return `il y a ${diffHours}h`;
    } else {
      return date.toLocaleDateString('fr-FR');
    }
  };

  if (loading) {
    return (
      <div className="p-6">
        <div className="animate-pulse">
          {/* Header skeleton */}
          <div className="h-8 bg-gray-200 rounded w-1/3 mb-6"></div>
          
          {/* Stats grid skeleton */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="h-32 bg-gray-200 rounded-xl"></div>
            ))}
          </div>
          
          {/* Content skeleton */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div className="lg:col-span-2 h-96 bg-gray-200 rounded-xl"></div>
            <div className="h-96 bg-gray-200 rounded-xl"></div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* En-tête du dashboard */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">
            Tableau de bord
          </h1>
          <p className="mt-1 text-gray-600">
            Bienvenue, {apiculteur ? `${apiculteur.prenom} ${apiculteur.nom}` : 'Apiculteur'}
          </p>
        </div>
        <div className="mt-4 sm:mt-0 flex items-center space-x-2 text-gray-500">
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

      {/* Cartes de statistiques */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {statsCards.map((stat, index) => {
          const Icon = stat.icon;
          return (
            <div key={index} className="bg-white rounded-xl shadow-lg hover-lift transition-all-smooth p-6 border border-gray-100 animate-fade-in" style={{ animationDelay: `${index * 0.1}s` }}>
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600 mb-2">{stat.title}</p>
                  <p className="text-3xl font-bold text-gray-900">{stat.value}</p>
                  {stat.trend && (
                    <div className={`flex items-center mt-2 text-sm ${
                      stat.trend.isPositive ? 'text-green-600' : 'text-red-600'
                    }`}>
                      {stat.trend.isPositive ? (
                        <TrendingUp size={16} className="mr-1" />
                      ) : (
                        <TrendingDown size={16} className="mr-1" />
                      )}
                      <span className="font-medium">{stat.trend.value}%</span>
                      <span className="text-gray-500 ml-1">vs dernière semaine</span>
                    </div>
                  )}
                </div>
                <div className={`${stat.color} rounded-full p-3`}>
                  <Icon size={24} className="text-white" />
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Contenu principal */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Graphique principal */}
        <div className="lg:col-span-2 bg-white rounded-xl shadow-lg hover-lift p-6 border border-gray-100 animate-slide-in-left">
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-xl font-bold text-gray-900">Aperçu des mesures</h3>
            <div className="flex space-x-2">
              <button className="px-3 py-1 text-sm bg-amber-100 text-amber-700 rounded-lg font-medium">24h</button>
              <button className="px-3 py-1 text-sm text-gray-500 hover:bg-gray-100 rounded-lg">7j</button>
              <button className="px-3 py-1 text-sm text-gray-500 hover:bg-gray-100 rounded-lg">30j</button>
            </div>
          </div>
          
          {/* Placeholder pour graphique */}
          <div className="h-64 bg-gradient-to-br from-amber-50 to-yellow-50 rounded-lg flex items-center justify-center border-2 border-dashed border-amber-200">
            <div className="text-center">
              <Activity size={48} className="text-amber-400 mx-auto mb-4" />
              <p className="text-amber-700 font-medium">Graphique des mesures</p>
              <p className="text-amber-600 text-sm">Températures, humidité, poids...</p>
            </div>
          </div>
          
          {/* Légende */}
          <div className="flex items-center justify-center space-x-6 mt-4">
            <div className="flex items-center">
              <div className="w-3 h-3 bg-red-500 rounded-full mr-2"></div>
              <span className="text-sm text-gray-600">Température</span>
            </div>
            <div className="flex items-center">
              <div className="w-3 h-3 bg-blue-500 rounded-full mr-2"></div>
              <span className="text-sm text-gray-600">Humidité</span>
            </div>
            <div className="flex items-center">
              <div className="w-3 h-3 bg-green-500 rounded-full mr-2"></div>
              <span className="text-sm text-gray-600">Poids</span>
            </div>
          </div>
        </div>

        {/* Activité récente */}
        <div className="bg-white rounded-xl shadow-lg hover-lift p-6 border border-gray-100 animate-slide-in-right">
          <h3 className="text-xl font-bold text-gray-900 mb-6">Activité récente</h3>
          
          <div className="space-y-4">
            {recentActivities.map((activity) => {
              const Icon = getActivityIcon(activity.type);
              const colorClass = getActivityColor(activity.type);
              
              return (
                <div key={activity.id} className="flex items-start space-x-3 p-3 rounded-lg hover:bg-gray-50 transition-colors-smooth">
                  <div className={`p-2 rounded-full ${colorClass}`}>
                    <Icon size={16} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900 leading-relaxed">
                      {activity.message}
                    </p>
                    <div className="flex items-center mt-1 space-x-2">
                      <span className="text-xs text-gray-500">
                        {formatTimeAgo(activity.timestamp)}
                      </span>
                      {activity.rucheId && (
                        <>
                          <span className="text-xs text-gray-300">•</span>
                          <span className="text-xs text-amber-600 font-medium">
                            {activity.rucheId}
                          </span>
                        </>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
          
          <button className="w-full mt-4 py-2 text-sm text-amber-600 hover:text-amber-700 font-medium border border-amber-200 hover:border-amber-300 rounded-lg transition-colors-smooth focus-ring-amber">
            Voir toute l'activité
          </button>
        </div>
      </div>

      {/* Actions rapides */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-gradient-to-br from-amber-500 to-amber-600 rounded-xl shadow-lg hover-lift p-6 text-white animate-scale-in" style={{ animationDelay: '0.1s' }}>
          <div className="flex items-center justify-between">
            <div>
              <h4 className="text-lg font-bold">Ajouter une ruche</h4>
              <p className="text-amber-100 text-sm mt-1">Enregistrer une nouvelle ruche</p>
            </div>
            <Hexagon size={32} className="text-amber-200" />
          </div>
          <button className="w-full mt-4 bg-white bg-opacity-20 hover:bg-opacity-30 text-white font-medium py-2 rounded-lg transition-all-smooth focus-ring-amber">
            Commencer
          </button>
        </div>
        
        <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg hover-lift p-6 text-white animate-scale-in" style={{ animationDelay: '0.2s' }}>
          <div className="flex items-center justify-between">
            <div>
              <h4 className="text-lg font-bold">Rapport mensuel</h4>
              <p className="text-blue-100 text-sm mt-1">Générer un rapport détaillé</p>
            </div>
            <BarChart3 size={32} className="text-blue-200" />
          </div>
          <button className="w-full mt-4 bg-white bg-opacity-20 hover:bg-opacity-30 text-white font-medium py-2 rounded-lg transition-all-smooth focus-ring-amber">
            Générer
          </button>
        </div>
        
        <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-lg hover-lift p-6 text-white animate-scale-in" style={{ animationDelay: '0.3s' }}>
          <div className="flex items-center justify-between">
            <div>
              <h4 className="text-lg font-bold">Configuration</h4>
              <p className="text-green-100 text-sm mt-1">Paramètres et préférences</p>
            </div>
            <Settings size={32} className="text-green-200" />
          </div>
          <button className="w-full mt-4 bg-white bg-opacity-20 hover:bg-opacity-30 text-white font-medium py-2 rounded-lg transition-all-smooth focus-ring-amber">
            Configurer
          </button>
        </div>
      </div>
    </div>
  );
};

export default Dashboard; 