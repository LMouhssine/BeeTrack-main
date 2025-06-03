import React, { useState, useEffect } from 'react';
import { AlertTriangle, Eye, EyeOff, Clock, Shield, PlayCircle, StopCircle } from 'lucide-react';
import { useAlertesCouvercle } from '../hooks/useAlertesCouvercle';

interface SurveillanceCouvercleProps {
  rucheId: string;
  rucheNom: string;
  apiculteurId: string;
  onNotification?: (message: string, type: 'success' | 'error' | 'warning') => void;
}

const SurveillanceCouvercle: React.FC<SurveillanceCouvercleProps> = ({
  rucheId,
  rucheNom,
  apiculteurId,
  onNotification
}) => {
  const alertes = useAlertesCouvercle({ 
    apiculteurId, 
    onNotification 
  });

  const [enSurveillance, setEnSurveillance] = useState(false);

  useEffect(() => {
    // Vérifier si cette ruche est déjà en surveillance
    setEnSurveillance(alertes.surveillanceActive.has(rucheId));
  }, [alertes.surveillanceActive, rucheId]);

  const demarrerSurveillance = () => {
    alertes.demarrerSurveillance(rucheId, rucheNom);
    setEnSurveillance(true);
  };

  const arreterSurveillance = () => {
    alertes.arreterSurveillance(rucheId);
    setEnSurveillance(false);
  };

  const statutIgnore = alertes.obtenirStatutIgnore(rucheId);

  const formatDateFin = (date: Date) => {
    return new Intl.DateTimeFormat('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    }).format(date);
  };

  return (
    <div className="bg-white rounded-lg shadow-md border border-gray-200 p-6">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-3">
          <div className={`p-2 rounded-full ${enSurveillance ? 'bg-green-100' : 'bg-gray-100'}`}>
            <Eye size={20} className={enSurveillance ? 'text-green-600' : 'text-gray-500'} />
          </div>
          <div>
            <h3 className="text-lg font-semibold text-gray-900">
              Surveillance du Couvercle
            </h3>
            <p className="text-sm text-gray-600">
              Détection automatique d'ouverture non autorisée
            </p>
          </div>
        </div>
        
        <div className={`px-3 py-1 rounded-full text-sm font-medium ${
          enSurveillance 
            ? 'bg-green-100 text-green-800' 
            : 'bg-gray-100 text-gray-600'
        }`}>
          {enSurveillance ? '🟢 Actif' : '⚪ Inactif'}
        </div>
      </div>

      {/* Statut d'ignore */}
      {statutIgnore.ignore && (
        <div className="mb-4 p-4 bg-amber-50 border border-amber-200 rounded-lg">
          <div className="flex items-center space-x-2 mb-2">
            <EyeOff size={16} className="text-amber-600" />
            <span className="font-medium text-amber-800">Alertes temporairement désactivées</span>
          </div>
          <div className="text-sm text-amber-700">
            {statutIgnore.type === 'session' ? (
              <p>🔇 Ignoré pour cette session</p>
            ) : statutIgnore.finIgnore ? (
              <p>
                🕐 Ignoré jusqu'au {formatDateFin(statutIgnore.finIgnore)}
              </p>
            ) : (
              <p>🔇 Alertes désactivées</p>
            )}
          </div>
          <button
            onClick={() => alertes.reactiverAlertes(rucheId)}
            className="mt-2 text-xs bg-amber-600 hover:bg-amber-700 text-white px-3 py-1 rounded-md transition-colors"
          >
            Réactiver maintenant
          </button>
        </div>
      )}

      {/* Description */}
      <div className="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
        <div className="flex items-start space-x-2">
          <AlertTriangle size={16} className="text-blue-600 mt-0.5" />
          <div className="text-sm text-blue-800">
            <p className="font-medium mb-1">Comment ça fonctionne :</p>
            <ul className="space-y-1 text-xs">
              <li>• Vérification automatique toutes les 30 secondes</li>
              <li>• Alerte immédiate si couvercle ouvert détecté</li>
              <li>• Options d'ignore temporaire disponibles</li>
              <li>• Surveillance continue en arrière-plan</li>
            </ul>
          </div>
        </div>
      </div>

      {/* Boutons de contrôle */}
      <div className="space-y-3">
        {!enSurveillance ? (
          <button
            onClick={demarrerSurveillance}
            className="w-full flex items-center justify-center space-x-2 bg-green-600 hover:bg-green-700 text-white font-medium py-3 px-4 rounded-lg transition-colors"
          >
            <PlayCircle size={20} />
            <span>Démarrer la Surveillance</span>
          </button>
        ) : (
          <button
            onClick={arreterSurveillance}
            className="w-full flex items-center justify-center space-x-2 bg-red-600 hover:bg-red-700 text-white font-medium py-3 px-4 rounded-lg transition-colors"
          >
            <StopCircle size={20} />
            <span>Arrêter la Surveillance</span>
          </button>
        )}

        {enSurveillance && (
          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={() => alertes.ignorerAlerte(rucheId, 1)}
              className="flex items-center justify-center space-x-2 bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-3 rounded-md transition-colors text-sm"
            >
              <Clock size={16} />
              <span>Ignorer 1h</span>
            </button>
            <button
              onClick={() => alertes.ignorerPourSession(rucheId)}
              className="flex items-center justify-center space-x-2 bg-purple-600 hover:bg-purple-700 text-white font-medium py-2 px-3 rounded-md transition-colors text-sm"
            >
              <Shield size={16} />
              <span>Session</span>
            </button>
          </div>
        )}
      </div>

      {/* Informations supplémentaires */}
      {enSurveillance && (
        <div className="mt-4 p-3 bg-gray-50 rounded-lg">
          <div className="text-xs text-gray-600 space-y-1">
            <p>📊 <strong>Ruches surveillées :</strong> {alertes.surveillanceActive.size}</p>
            <p>🔄 <strong>Fréquence :</strong> Toutes les 30 secondes</p>
            <p>💾 <strong>Stockage :</strong> Préférences locales du navigateur</p>
          </div>
        </div>
      )}
    </div>
  );
};

export default SurveillanceCouvercle; 