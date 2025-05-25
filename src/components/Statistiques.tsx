import React from 'react';
import { BarChart3, TrendingUp } from 'lucide-react';

const Statistiques: React.FC = () => {
  return (
    <div className="text-center py-16 bg-white rounded-lg shadow-sm border border-gray-200">
      <TrendingUp className="mx-auto text-amber-500 mb-4" size={64} />
      <h3 className="text-xl font-semibold text-gray-900 mb-2">
        Tableau de Bord
      </h3>
      <p className="text-gray-600 mb-4 max-w-md mx-auto">
        Les statistiques et graphiques de vos ruches seront bientôt disponibles. 
        Vous pourrez suivre la production, la santé des colonies et bien plus.
      </p>
      <div className="flex items-center justify-center space-x-2 text-amber-600">
        <BarChart3 size={20} />
        <span className="font-medium">Graphiques en développement</span>
      </div>
    </div>
  );
};

export default Statistiques; 