import React, { useState } from 'react';
import { AlertTriangle, X, Clock, EyeOff } from 'lucide-react';
import { DonneesCapteur } from '../services/rucheService';

interface AlerteCouvercleModalProps {
  isOpen: boolean;
  rucheId: string;
  rucheNom?: string;
  mesure: DonneesCapteur;
  onIgnorerTemporairement: (dureeHeures: number) => void;
  onIgnorerSession: () => void;
  onFermer: () => void;
}

const AlerteCouvercleModal: React.FC<AlerteCouvercleModalProps> = ({
  isOpen,
  rucheId,
  rucheNom,
  mesure,
  onIgnorerTemporairement,
  onIgnorerSession,
  onFermer
}) => {
  const [dureeSelectionnee, setDureeSelectionnee] = useState<number>(1);

  if (!isOpen) return null;

  const formatDate = (date: Date) => {
    return new Intl.DateTimeFormat('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    }).format(date);
  };

  const dureeOptions = [
    { value: 0.5, label: '30 minutes' },
    { value: 1, label: '1 heure' },
    { value: 2, label: '2 heures' },
    { value: 4, label: '4 heures' },
    { value: 8, label: '8 heures' },
    { value: 24, label: '24 heures' }
  ];

  return (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-md w-full animate-in fade-in-0 zoom-in-95 duration-200">
        {/* Header d'alerte */}
        <div className="bg-gradient-to-r from-red-500 to-orange-500 text-white p-6 rounded-t-xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="bg-white/20 p-2 rounded-full">
                <AlertTriangle size={24} className="animate-pulse" />
              </div>
              <div>
                <h2 className="text-xl font-bold">⚠️ Alerte Ruche</h2>
                <p className="text-red-100 text-sm">Couvercle ouvert détecté</p>
              </div>
            </div>
          </div>
        </div>

        {/* Contenu */}
        <div className="p-6">
          {/* Informations de la ruche */}
          <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
            <div className="flex items-center space-x-2 mb-2">
              <div className="w-3 h-3 bg-red-500 rounded-full animate-pulse"></div>
              <span className="font-semibold text-red-800">
                {rucheNom || `Ruche ${rucheId}`}
              </span>
            </div>
            <p className="text-red-700 font-medium mb-1">
              🚨 Le couvercle de la ruche est actuellement ouvert !
            </p>
            <p className="text-red-600 text-sm">
              Dernière mesure : {formatDate(mesure.timestamp)}
            </p>
          </div>

          {/* Informations additionnelles */}
          {(mesure.temperature || mesure.humidity || mesure.batterie) && (
            <div className="bg-gray-50 rounded-lg p-4 mb-6">
              <h3 className="font-medium text-gray-800 mb-2">Autres mesures :</h3>
              <div className="grid grid-cols-2 gap-2 text-sm">
                {mesure.temperature && (
                  <div className="flex justify-between">
                    <span className="text-gray-600">Température :</span>
                    <span className="font-medium">{mesure.temperature.toFixed(1)}°C</span>
                  </div>
                )}
                {mesure.humidity && (
                  <div className="flex justify-between">
                    <span className="text-gray-600">Humidité :</span>
                    <span className="font-medium">{mesure.humidity.toFixed(1)}%</span>
                  </div>
                )}
                {mesure.batterie && (
                  <div className="flex justify-between">
                    <span className="text-gray-600">Batterie :</span>
                    <span className="font-medium">{mesure.batterie}%</span>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Message d'action */}
          <div className="bg-amber-50 border border-amber-200 rounded-lg p-4 mb-6">
            <p className="text-amber-800 text-sm">
              💡 <strong>Action recommandée :</strong> Vérifiez immédiatement l'état de votre ruche. 
              Un couvercle ouvert peut exposer la colonie aux intempéries et aux prédateurs.
            </p>
          </div>

          {/* Options d'ignore */}
          <div className="space-y-4">
            <h3 className="font-medium text-gray-800 border-b pb-2">
              Options de gestion de l'alerte :
            </h3>

            {/* Ignorer temporairement */}
            <div className="border border-gray-200 rounded-lg p-4">
              <div className="flex items-center space-x-2 mb-3">
                <Clock size={18} className="text-blue-500" />
                <span className="font-medium text-gray-800">Ignorer temporairement</span>
              </div>
              
              <div className="space-y-3">
                <select
                  value={dureeSelectionnee}
                  onChange={(e) => setDureeSelectionnee(Number(e.target.value))}
                  className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  {dureeOptions.map(option => (
                    <option key={option.value} value={option.value}>
                      {option.label}
                    </option>
                  ))}
                </select>
                
                <button
                  onClick={() => onIgnorerTemporairement(dureeSelectionnee)}
                  className="w-full flex items-center justify-center space-x-2 bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-md transition duration-200"
                >
                  <Clock size={16} />
                  <span>Ignorer pour {dureeOptions.find(o => o.value === dureeSelectionnee)?.label}</span>
                </button>
              </div>
            </div>

            {/* Ignorer pour la session */}
            <div className="border border-gray-200 rounded-lg p-4">
              <div className="flex items-center space-x-2 mb-3">
                <EyeOff size={18} className="text-purple-500" />
                <span className="font-medium text-gray-800">Ignorer pour cette session</span>
              </div>
              <p className="text-gray-600 text-sm mb-3">
                L'alerte sera ignorée jusqu'à ce que vous fermiez l'application.
              </p>
              <button
                onClick={onIgnorerSession}
                className="w-full flex items-center justify-center space-x-2 bg-purple-600 hover:bg-purple-700 text-white font-medium py-2 px-4 rounded-md transition duration-200"
              >
                <EyeOff size={16} />
                <span>Ignorer pour cette session</span>
              </button>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="bg-gray-50 px-6 py-4 rounded-b-xl">
          <button
            onClick={onFermer}
            className="w-full flex items-center justify-center space-x-2 bg-gray-600 hover:bg-gray-700 text-white font-medium py-2 px-4 rounded-md transition duration-200"
          >
            <X size={16} />
            <span>Fermer (continuer à surveiller)</span>
          </button>
          <p className="text-center text-xs text-gray-500 mt-2">
            En fermant cette alerte, la surveillance continue en arrière-plan
          </p>
        </div>
      </div>
    </div>
  );
};

export default AlerteCouvercleModal; 