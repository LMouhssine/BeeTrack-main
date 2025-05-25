import React from 'react';
import { Box, Wrench } from 'lucide-react';

const RuchesList: React.FC = () => {
  return (
    <div className="text-center py-16 bg-white rounded-lg shadow-sm border border-gray-200">
      <Wrench className="mx-auto text-amber-500 mb-4" size={64} />
      <h3 className="text-xl font-semibold text-gray-900 mb-2">
        Gestion des Ruches
      </h3>
      <p className="text-gray-600 mb-4 max-w-md mx-auto">
        Cette fonctionnalité est en cours de développement. 
        Vous pourrez bientôt gérer vos ruches individuelles depuis cette interface.
      </p>
      <div className="flex items-center justify-center space-x-2 text-amber-600">
        <Box size={20} />
        <span className="font-medium">Bientôt disponible</span>
      </div>
    </div>
  );
};

export default RuchesList; 