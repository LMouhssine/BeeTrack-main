import React, { useState } from 'react';
import { AlertTriangle, Play, Square, TestTube } from 'lucide-react';
import { useAlertesCouvercle } from '../hooks/useAlertesCouvercle';
import { useNotifications } from '../hooks/useNotifications';
import AlerteCouvercleModal from './AlerteCouvercleModal';
import NotificationToast from './NotificationToast';
import { DonneesCapteur } from '../services/rucheService';

const TestAlerteCouvercle: React.FC = () => {
  const { notifications, addNotification, removeNotification } = useNotifications();
  const alertes = useAlertesCouvercle({
    apiculteurId: 'test-user',
    onNotification: addNotification
  });

  const [testRucheId] = useState('test-ruche-001');
  const [simulerCouvercleOuvert, setSimulerCouvercleOuvert] = useState(false);

  // Simuler une mesure avec couvercle ouvert
  const simulerAlerte = () => {
    const mesureTest: DonneesCapteur = {
      id: 'test-mesure-' + Date.now(),
      rucheId: testRucheId,
      timestamp: new Date(),
      temperature: 25.5,
      humidity: 65.2,
      couvercleOuvert: true,
      batterie: 85,
      signalQualite: 92
    };

    // Déclencher manuellement l'alerte
    if (alertes.alerteActive === null) {
      // Simuler l'alerte en appelant directement le callback
      const callback = (alertes as any).handleAlerte;
      if (callback) {
        callback(testRucheId, mesureTest);
      }
    }
  };

  const demarrerTest = () => {
    alertes.demarrerSurveillance(testRucheId, 'Ruche de Test');
    setSimulerCouvercleOuvert(true);
  };

  const arreterTest = () => {
    alertes.arreterSurveillance(testRucheId);
    setSimulerCouvercleOuvert(false);
  };

  const statutIgnore = alertes.obtenirStatutIgnore(testRucheId);

  return (
    <div className="max-w-4xl mx-auto p-6 space-y-6">
      <div className="bg-white rounded-lg shadow-md border border-gray-200 p-6">
        <div className="flex items-center space-x-3 mb-6">
          <div className="p-2 rounded-full bg-blue-100">
            <TestTube size={24} className="text-blue-600" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Test Alerte Couvercle</h1>
            <p className="text-gray-600">Démonstration du système d'alerte en temps réel</p>
          </div>
        </div>

        {/* État actuel */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <div className="bg-gray-50 rounded-lg p-4">
            <h3 className="font-medium text-gray-900 mb-2">Surveillance</h3>
            <div className={`flex items-center space-x-2 ${
              alertes.surveillanceActive.has(testRucheId) ? 'text-green-600' : 'text-gray-500'
            }`}>
              <div className={`w-2 h-2 rounded-full ${
                alertes.surveillanceActive.has(testRucheId) ? 'bg-green-500' : 'bg-gray-400'
              }`}></div>
              <span className="text-sm font-medium">
                {alertes.surveillanceActive.has(testRucheId) ? 'Active' : 'Inactive'}
              </span>
            </div>
          </div>

          <div className="bg-gray-50 rounded-lg p-4">
            <h3 className="font-medium text-gray-900 mb-2">Alerte Active</h3>
            <div className={`flex items-center space-x-2 ${
              alertes.alerteActive ? 'text-red-600' : 'text-gray-500'
            }`}>
              <div className={`w-2 h-2 rounded-full ${
                alertes.alerteActive ? 'bg-red-500' : 'bg-gray-400'
              }`}></div>
              <span className="text-sm font-medium">
                {alertes.alerteActive ? 'Oui' : 'Non'}
              </span>
            </div>
          </div>

          <div className="bg-gray-50 rounded-lg p-4">
            <h3 className="font-medium text-gray-900 mb-2">Statut Ignore</h3>
            <div className={`flex items-center space-x-2 ${
              statutIgnore.ignore ? 'text-amber-600' : 'text-gray-500'
            }`}>
              <div className={`w-2 h-2 rounded-full ${
                statutIgnore.ignore ? 'bg-amber-500' : 'bg-gray-400'
              }`}></div>
              <span className="text-sm font-medium">
                {statutIgnore.ignore ? `Ignoré (${statutIgnore.type})` : 'Normal'}
              </span>
            </div>
          </div>
        </div>

        {/* Contrôles */}
        <div className="space-y-4">
          <h3 className="text-lg font-semibold text-gray-900">Contrôles de Test</h3>
          
          <div className="flex flex-wrap gap-3">
            {!alertes.surveillanceActive.has(testRucheId) ? (
              <button
                onClick={demarrerTest}
                className="flex items-center space-x-2 bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg transition-colors"
              >
                <Play size={16} />
                <span>Démarrer Surveillance Test</span>
              </button>
            ) : (
              <button
                onClick={arreterTest}
                className="flex items-center space-x-2 bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg transition-colors"
              >
                <Square size={16} />
                <span>Arrêter Surveillance</span>
              </button>
            )}

            <button
              onClick={simulerAlerte}
              disabled={!alertes.surveillanceActive.has(testRucheId) || alertes.alerteActive !== null}
              className="flex items-center space-x-2 bg-orange-600 hover:bg-orange-700 disabled:bg-gray-400 text-white px-4 py-2 rounded-lg transition-colors"
            >
              <AlertTriangle size={16} />
              <span>Simuler Alerte</span>
            </button>

            {statutIgnore.ignore && (
              <button
                onClick={() => alertes.reactiverAlertes(testRucheId)}
                className="flex items-center space-x-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors"
              >
                <span>Réactiver Alertes</span>
              </button>
            )}
          </div>
        </div>

        {/* Instructions */}
        <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <h4 className="font-medium text-blue-900 mb-2">Instructions de Test</h4>
          <ol className="text-sm text-blue-800 space-y-1">
            <li>1. Cliquez sur "Démarrer Surveillance Test" pour activer la surveillance</li>
            <li>2. Cliquez sur "Simuler Alerte" pour déclencher une alerte de couvercle ouvert</li>
            <li>3. Testez les options d'ignore dans la modal d'alerte</li>
            <li>4. Observez les notifications toast qui apparaissent</li>
            <li>5. Utilisez "Réactiver Alertes" si vous avez ignoré les alertes</li>
          </ol>
        </div>

        {/* Informations de debug */}
        <div className="mt-6 p-4 bg-gray-50 rounded-lg">
          <h4 className="font-medium text-gray-900 mb-2">Informations de Debug</h4>
          <div className="text-sm text-gray-600 space-y-1">
            <p><strong>Ruches surveillées:</strong> {alertes.surveillanceActive.size}</p>
            <p><strong>Notifications actives:</strong> {notifications.length}</p>
            <p><strong>Alerte active:</strong> {alertes.alerteActive ? 'Oui' : 'Non'}</p>
            {statutIgnore.ignore && (
              <p><strong>Fin ignore:</strong> {statutIgnore.finIgnore?.toLocaleString() || 'Session'}</p>
            )}
          </div>
        </div>
      </div>

      {/* Modal d'alerte */}
      {alertes.alerteActive && (
        <AlerteCouvercleModal
          isOpen={true}
          rucheId={alertes.alerteActive.rucheId}
          rucheNom={alertes.alerteActive.rucheNom}
          mesure={alertes.alerteActive.mesure}
          onIgnorerTemporairement={alertes.ignorerAlerte}
          onIgnorerSession={alertes.ignorerPourSession}
          onFermer={alertes.fermerAlerte}
        />
      )}

      {/* Notifications */}
      {notifications.map(notification => (
        <NotificationToast
          key={notification.id}
          message={notification.message}
          type={notification.type}
          onClose={() => removeNotification(notification.id)}
          duration={notification.duration}
        />
      ))}
    </div>
  );
};

export default TestAlerteCouvercle; 