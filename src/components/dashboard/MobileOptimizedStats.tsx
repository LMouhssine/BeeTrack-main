import React from 'react';
import { TrendingUp, TrendingDown, Home, Hexagon, AlertTriangle, Wifi } from 'lucide-react';
import { useResponsive } from './ResponsiveContainer';

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

interface MobileOptimizedStatsProps {
  rucherCount: number;
  rucheCount: number;
  activeAlertsCount: number;
  onlineRuchesCount: number;
  totalRuchesCount: number;
  loading?: boolean;
  onCardClick?: (cardType: string) => void;
}

const MobileOptimizedStats: React.FC<MobileOptimizedStatsProps> = ({
  rucherCount,
  rucheCount,
  activeAlertsCount,
  onlineRuchesCount,
  totalRuchesCount,
  loading = false,
  onCardClick
}) => {
  const { isMobile, isTablet } = useResponsive();

  const statsCards: StatCard[] = [
    {
      title: 'Ruchers',
      value: rucherCount,
      icon: Home,
      trend: { value: 12, isPositive: true, label: 'vs mois dernier' },
      color: 'bg-blue-500',
      loading
    },
    {
      title: 'Ruches',
      value: rucheCount,
      icon: Hexagon,
      trend: { value: 8, isPositive: true, label: 'nouvelles' },
      color: 'bg-amber-500',
      loading
    },
    {
      title: 'Alertes',
      value: activeAlertsCount,
      icon: AlertTriangle,
      trend: { 
        value: activeAlertsCount > 0 ? 15 : 0, 
        isPositive: activeAlertsCount === 0, 
        label: activeAlertsCount > 0 ? 'actives' : 'aucune'
      },
      color: activeAlertsCount > 0 ? 'bg-red-500' : 'bg-green-500',
      loading
    },
    {
      title: 'En ligne',
      value: totalRuchesCount > 0 ? `${onlineRuchesCount}/${totalRuchesCount}` : '0/0',
      icon: Wifi,
      trend: { 
        value: totalRuchesCount > 0 ? Math.round((onlineRuchesCount / totalRuchesCount) * 100) : 0, 
        isPositive: onlineRuchesCount === totalRuchesCount,
        label: 'connectées'
      },
      color: onlineRuchesCount === totalRuchesCount && totalRuchesCount > 0 ? 'bg-green-500' : 'bg-orange-500',
      loading
    }
  ];

  const StatCardMobileSkeleton = () => (
    <div className="bg-white rounded-lg shadow-md p-4 animate-pulse">
      <div className="flex items-center justify-between">
        <div className="flex-1">
          <div className="h-3 bg-gray-200 rounded w-2/3 mb-2"></div>
          <div className="h-6 bg-gray-200 rounded w-1/2 mb-2"></div>
          <div className="h-3 bg-gray-200 rounded w-3/4"></div>
        </div>
        <div className="w-10 h-10 bg-gray-200 rounded-full"></div>
      </div>
    </div>
  );

  if (loading) {
    return (
      <div className={`grid gap-4 ${
        isMobile ? 'grid-cols-2' : isTablet ? 'grid-cols-2' : 'grid-cols-4'
      }`}>
        {[...Array(4)].map((_, index) => (
          <StatCardMobileSkeleton key={index} />
        ))}
      </div>
    );
  }

  return (
    <div className={`grid gap-4 ${
      isMobile ? 'grid-cols-2' : isTablet ? 'grid-cols-2' : 'grid-cols-4'
    }`}>
      {statsCards.map((stat, index) => {
        const Icon = stat.icon;
        const cardType = stat.title.toLowerCase();
        
        return (
          <button 
            key={index} 
            className={`bg-white rounded-lg shadow-md hover:shadow-lg transition-all duration-200 p-4 border border-gray-100 animate-fade-in group text-left ${
              onCardClick ? 'cursor-pointer hover:scale-105 focus:outline-none focus:ring-2 focus:ring-amber-500' : ''
            }`}
            style={{ animationDelay: `${index * 0.1}s` }}
            onClick={() => onCardClick?.(cardType)}
            disabled={!onCardClick}
            aria-label={`${stat.title}: ${stat.value}`}
          >
            <div className="flex items-center justify-between">
              <div className="flex-1 min-w-0">
                <p className={`text-xs font-medium text-gray-600 mb-1 truncate ${
                  isMobile ? 'text-xs' : 'text-sm'
                }`}>
                  {stat.title}
                </p>
                <p className={`font-bold text-gray-900 mb-1 ${
                  isMobile ? 'text-xl' : 'text-2xl'
                }`}>
                  {stat.value}
                </p>
                {stat.trend && (
                  <div className={`flex items-center text-xs ${
                    stat.trend.isPositive ? 'text-green-600' : 'text-red-600'
                  }`}>
                    {stat.trend.isPositive ? (
                      <TrendingUp size={12} className="mr-1 flex-shrink-0" aria-hidden="true" />
                    ) : (
                      <TrendingDown size={12} className="mr-1 flex-shrink-0" aria-hidden="true" />
                    )}
                    {!isMobile && (
                      <>
                        <span className="font-medium">{stat.trend.value}%</span>
                        <span className="text-gray-500 ml-1 truncate">{stat.trend.label}</span>
                      </>
                    )}
                  </div>
                )}
              </div>
              <div className={`${stat.color} rounded-full p-2 group-hover:scale-110 transition-transform duration-200 flex-shrink-0`}>
                <Icon size={isMobile ? 16 : 20} className="text-white" aria-hidden="true" />
              </div>
            </div>
          </button>
        );
      })}
    </div>
  );
};

export default MobileOptimizedStats; 