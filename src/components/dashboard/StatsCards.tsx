import React from 'react';
import { TrendingUp, TrendingDown, Home, Hexagon, AlertTriangle, Wifi } from 'lucide-react';

interface StatCard {
  title: string;
  value: string | number;
  icon: React.ElementType;
  trend?: {
    value: number;
    isPositive: boolean;
    label?: string;
  };
  color: string;
  loading?: boolean;
}

interface StatsCardsProps {
  rucherCount: number;
  rucheCount: number;
  activeAlertsCount: number;
  onlineRuchesCount: number;
  totalRuchesCount: number;
  loading?: boolean;
}

const StatsCards: React.FC<StatsCardsProps> = ({
  rucherCount,
  rucheCount,
  activeAlertsCount,
  onlineRuchesCount,
  totalRuchesCount,
  loading = false
}) => {
  const statsCards: StatCard[] = [
    {
      title: 'Ruchers actifs',
      value: rucherCount,
      icon: Home,
      trend: { value: 12, isPositive: true, label: 'vs mois dernier' },
      color: 'bg-blue-500',
      loading
    },
    {
      title: 'Ruches surveillées',
      value: rucheCount,
      icon: Hexagon,
      trend: { value: 8, isPositive: true, label: 'nouvelles ce mois' },
      color: 'bg-amber-500',
      loading
    },
    {
      title: 'Alertes actives',
      value: activeAlertsCount,
      icon: AlertTriangle,
      trend: { 
        value: activeAlertsCount > 0 ? 15 : 0, 
        isPositive: activeAlertsCount === 0, 
        label: activeAlertsCount > 0 ? 'nécessitent attention' : 'aucune alerte'
      },
      color: activeAlertsCount > 0 ? 'bg-red-500' : 'bg-green-500',
      loading
    },
    {
      title: 'Connectivité',
      value: totalRuchesCount > 0 ? `${onlineRuchesCount}/${totalRuchesCount}` : '0/0',
      icon: Wifi,
      trend: { 
        value: totalRuchesCount > 0 ? Math.round((onlineRuchesCount / totalRuchesCount) * 100) : 0, 
        isPositive: onlineRuchesCount === totalRuchesCount,
        label: 'taux de connexion'
      },
      color: onlineRuchesCount === totalRuchesCount && totalRuchesCount > 0 ? 'bg-green-500' : 'bg-orange-500',
      loading
    }
  ];

  const StatCardSkeleton = () => (
    <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-100 animate-pulse">
      <div className="flex items-center justify-between">
        <div className="flex-1">
          <div className="h-4 bg-gray-200 rounded w-2/3 mb-3"></div>
          <div className="h-8 bg-gray-200 rounded w-1/2 mb-3"></div>
          <div className="h-4 bg-gray-200 rounded w-3/4"></div>
        </div>
        <div className="w-12 h-12 bg-gray-200 rounded-full"></div>
      </div>
    </div>
  );

  if (loading) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {[...Array(4)].map((_, index) => (
          <StatCardSkeleton key={index} />
        ))}
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      {statsCards.map((stat, index) => {
        const Icon = stat.icon;
        return (
          <div 
            key={index} 
            className="bg-white rounded-xl shadow-lg hover-lift transition-all-smooth p-6 border border-gray-100 animate-fade-in group cursor-pointer" 
            style={{ animationDelay: `${index * 0.1}s` }}
            role="button"
            tabIndex={0}
            aria-label={`${stat.title}: ${stat.value}`}
          >
            <div className="flex items-center justify-between">
              <div className="flex-1">
                <p className="text-sm font-medium text-gray-600 mb-2 group-hover:text-gray-700 transition-colors">
                  {stat.title}
                </p>
                <p className="text-3xl font-bold text-gray-900 mb-2 group-hover:text-gray-800 transition-colors">
                  {stat.value}
                </p>
                {stat.trend && (
                  <div className={`flex items-center text-sm ${
                    stat.trend.isPositive ? 'text-green-600' : 'text-red-600'
                  }`}>
                    {stat.trend.isPositive ? (
                      <TrendingUp size={16} className="mr-1 flex-shrink-0" aria-hidden="true" />
                    ) : (
                      <TrendingDown size={16} className="mr-1 flex-shrink-0" aria-hidden="true" />
                    )}
                    <span className="font-medium">{stat.trend.value}%</span>
                    <span className="text-gray-500 ml-1 truncate">{stat.trend.label}</span>
                  </div>
                )}
              </div>
              <div className={`${stat.color} rounded-full p-3 group-hover:scale-110 transition-transform duration-200`}>
                <Icon size={24} className="text-white" aria-hidden="true" />
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
};

export default StatsCards; 