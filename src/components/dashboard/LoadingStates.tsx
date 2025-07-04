import React from 'react';
import { Activity, Home, Hexagon, AlertTriangle, Clock } from 'lucide-react';

// Skeleton amélioré avec animations plus fluides
export const SkeletonCard: React.FC<{ 
  className?: string; 
  showIcon?: boolean;
  lines?: number;
}> = ({ 
  className = '', 
  showIcon = true,
  lines = 3 
}) => (
  <div className={`bg-white rounded-xl shadow-lg p-6 border border-gray-100 animate-pulse ${className}`}>
    <div className="flex items-center justify-between">
      <div className="flex-1 space-y-3">
        {[...Array(lines)].map((_, i) => (
          <div 
            key={i}
            className={`h-3 bg-gray-200 rounded ${
              i === 0 ? 'w-2/3' : 
              i === 1 ? 'w-1/2' : 
              'w-3/4'
            }`}
            style={{ animationDelay: `${i * 0.1}s` }}
          />
        ))}
      </div>
      {showIcon && (
        <div className="w-12 h-12 bg-gray-200 rounded-full flex-shrink-0"></div>
      )}
    </div>
  </div>
);

// Skeleton pour les graphiques
export const ChartSkeleton: React.FC<{ className?: string }> = ({ className = '' }) => (
  <div className={`bg-white rounded-xl shadow-lg border border-gray-100 ${className}`}>
    <div className="p-6 border-b border-gray-100 animate-pulse">
      <div className="flex justify-between items-center mb-4">
        <div className="h-6 bg-gray-200 rounded w-1/3"></div>
        <div className="flex space-x-2">
          <div className="h-8 bg-gray-200 rounded w-12"></div>
          <div className="h-8 bg-gray-200 rounded w-12"></div>
          <div className="h-8 bg-gray-200 rounded w-12"></div>
        </div>
      </div>
      <div className="h-4 bg-gray-200 rounded w-1/2"></div>
    </div>
    <div className="p-6 animate-pulse">
      <div className="h-64 bg-gray-200 rounded relative overflow-hidden">
        {/* Animation de vague */}
        <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white to-transparent opacity-30 animate-shimmer"></div>
      </div>
    </div>
  </div>
);

// Skeleton pour les activités
export const ActivitySkeleton: React.FC<{ count?: number }> = ({ count = 5 }) => (
  <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-100">
    <div className="animate-pulse">
      <div className="h-6 bg-gray-200 rounded w-1/3 mb-6"></div>
      <div className="space-y-4">
        {[...Array(count)].map((_, i) => (
          <div key={i} className="flex items-start space-x-3">
            <div className="w-8 h-8 bg-gray-200 rounded-full flex-shrink-0"></div>
            <div className="flex-1 space-y-2">
              <div className="h-4 bg-gray-200 rounded w-3/4"></div>
              <div className="h-3 bg-gray-200 rounded w-1/2"></div>
            </div>
          </div>
        ))}
      </div>
    </div>
  </div>
);

// Skeleton pour les actions rapides
export const QuickActionsSkeleton: React.FC<{ className?: string }> = ({ className = '' }) => (
  <div className={`space-y-6 ${className}`}>
    <div className="h-6 bg-gray-200 rounded w-1/4 animate-pulse"></div>
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {[...Array(6)].map((_, i) => (
        <div 
          key={i} 
          className="h-24 bg-gray-200 rounded-xl animate-pulse"
          style={{ animationDelay: `${i * 0.1}s` }}
        ></div>
      ))}
    </div>
  </div>
);

// Composant de chargement avec indicateur de progression
export const LoadingSpinner: React.FC<{
  size?: 'sm' | 'md' | 'lg';
  color?: string;
  message?: string;
  showProgress?: boolean;
  progress?: number;
}> = ({ 
  size = 'md', 
  color = 'border-amber-600',
  message,
  showProgress = false,
  progress = 0
}) => {
  const sizeClasses = {
    sm: 'w-4 h-4',
    md: 'w-8 h-8',
    lg: 'w-12 h-12'
  };

  return (
    <div className="flex flex-col items-center justify-center space-y-4">
      <div className="relative">
        <div className={`${sizeClasses[size]} border-2 border-gray-200 border-t-transparent rounded-full animate-spin ${color}`}></div>
        {showProgress && (
          <div className="absolute inset-0 flex items-center justify-center">
            <span className="text-xs font-medium text-gray-600">{Math.round(progress)}%</span>
          </div>
        )}
      </div>
      {message && (
        <p className="text-sm text-gray-600 text-center max-w-xs">{message}</p>
      )}
      {showProgress && (
        <div className="w-32 bg-gray-200 rounded-full h-2 overflow-hidden">
          <div 
            className="bg-amber-600 h-2 rounded-full transition-all duration-300 ease-out"
            style={{ width: `${Math.min(100, Math.max(0, progress))}%` }}
          ></div>
        </div>
      )}
    </div>
  );
};

// Composant d'état vide amélioré
export const EmptyState: React.FC<{
  icon?: React.ElementType;
  title: string;
  description?: string;
  action?: {
    label: string;
    onClick: () => void;
  };
  className?: string;
}> = ({ 
  icon: Icon = Activity, 
  title, 
  description, 
  action,
  className = ''
}) => (
  <div className={`text-center p-8 ${className}`}>
    <div className="mx-auto w-24 h-24 rounded-full bg-gray-100 flex items-center justify-center mb-6">
      <Icon size={32} className="text-gray-400" />
    </div>
    <h3 className="text-lg font-medium text-gray-900 mb-2">{title}</h3>
    {description && (
      <p className="text-gray-500 text-sm mb-6 max-w-sm mx-auto">{description}</p>
    )}
    {action && (
      <button
        onClick={action.onClick}
        className="inline-flex items-center px-4 py-2 bg-amber-600 text-white rounded-lg font-medium hover:bg-amber-700 transition-colors focus:outline-none focus:ring-2 focus:ring-amber-500 focus:ring-offset-2"
      >
        {action.label}
      </button>
    )}
  </div>
);

// Composant d'erreur amélioré
export const ErrorState: React.FC<{
  title?: string;
  message: string;
  onRetry?: () => void;
  className?: string;
}> = ({ 
  title = 'Une erreur est survenue',
  message, 
  onRetry,
  className = ''
}) => (
  <div className={`text-center p-8 ${className}`}>
    <div className="mx-auto w-24 h-24 rounded-full bg-red-100 flex items-center justify-center mb-6">
      <AlertTriangle size={32} className="text-red-500" />
    </div>
    <h3 className="text-lg font-medium text-gray-900 mb-2">{title}</h3>
    <p className="text-gray-500 text-sm mb-6 max-w-sm mx-auto">{message}</p>
    {onRetry && (
      <button
        onClick={onRetry}
        className="inline-flex items-center px-4 py-2 bg-red-600 text-white rounded-lg font-medium hover:bg-red-700 transition-colors focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2"
      >
        Réessayer
      </button>
    )}
  </div>
);

// Skeleton dashboard complet
export const DashboardSkeleton: React.FC<{ isMobile?: boolean }> = ({ isMobile = false }) => (
  <div className="p-4 sm:p-6 space-y-6">
    <div className="animate-pulse">
      {/* En-tête */}
      <div className="flex justify-between items-center mb-6">
        <div className="space-y-2">
          <div className="h-8 bg-gray-200 rounded w-48"></div>
          <div className="h-4 bg-gray-200 rounded w-32"></div>
        </div>
        {!isMobile && (
          <div className="flex items-center space-x-4">
            <div className="h-4 bg-gray-200 rounded w-32"></div>
            <div className="h-4 bg-gray-200 rounded w-16"></div>
          </div>
        )}
      </div>

      {/* Stats cards */}
      <div className={`grid gap-4 mb-6 ${isMobile ? 'grid-cols-2' : 'grid-cols-4'}`}>
        {[...Array(4)].map((_, i) => (
          <SkeletonCard key={i} />
        ))}
      </div>

      {/* Contenu principal */}
      <div className={`grid gap-6 ${isMobile ? 'grid-cols-1' : 'lg:grid-cols-3'}`}>
        <ChartSkeleton className={isMobile ? '' : 'lg:col-span-2'} />
        <ActivitySkeleton />
      </div>

      {/* Actions rapides */}
      <QuickActionsSkeleton />
    </div>
  </div>
);

export default {
  SkeletonCard,
  ChartSkeleton,
  ActivitySkeleton,
  QuickActionsSkeleton,
  LoadingSpinner,
  EmptyState,
  ErrorState,
  DashboardSkeleton
}; 