import React, { useState } from 'react';
import { DonneesCapteursService, DonneesCapteur } from '../services/donneesCapteursService';

interface TestDerniereMesureProps {
  rucheId?: string;
  apiculteurId?: string;
}

const TestDerniereMesure: React.FC<TestDerniereMesureProps> = ({ 
  rucheId: initialRucheId = '', 
  apiculteurId: initialApiculteurId = 'test-user' 
}) => {
  const [rucheId, setRucheId] = useState(initialRucheId);
  const [apiculteurId, setApiculteurId] = useState(initialApiculteurId);
  const [derniereMesure, setDerniereMesure] = useState<DonneesCapteur | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string>('');
  const [connectivite, setConnectivite] = useState<boolean | null>(null);

  const testerConnectivite = async () => {
    try {
      setLoading(true);
      const isConnected = await DonneesCapteursService.testConnectivite();
      setConnectivite(isConnected);
      setError(isConnected ? '' : 'Firebase non accessible');
    } catch (err: any) {
      setError(`Erreur de connectivité: ${err.message}`);
      setConnectivite(false);
    } finally {
      setLoading(false);
    }
  };

  const recupererDerniereMesure = async () => {
    if (!rucheId.trim()) {
      setError('Veuillez saisir un ID de ruche');
      return;
    }

    try {
      setLoading(true);
      setError('');
      
      const mesure = await DonneesCapteursService.getDerniereMesure(rucheId);
      setDerniereMesure(mesure);
      
      if (!mesure) {
        setError('Aucune mesure trouvée pour cette ruche');
      }
    } catch (err: any) {
      setError(err.message);
      setDerniereMesure(null);
    } finally {
      setLoading(false);
    }
  };

  const obtenirMesures7Jours = async () => {
    if (!rucheId.trim()) {
      setError('Veuillez saisir un ID de ruche');
      return;
    }

    try {
      setLoading(true);
      setError('');
      
      const mesures = await DonneesCapteursService.getMesures7DerniersJours(rucheId);
      
      if (mesures.length > 0) {
        setDerniereMesure(mesures[mesures.length - 1]); // Afficher la dernière mesure
        setError(`✅ ${mesures.length} mesures trouvées sur 7 jours`);
      } else {
        setError('Aucune mesure trouvée sur les 7 derniers jours');
        setDerniereMesure(null);
      }
    } catch (err: any) {
      setError(err.message);
      setDerniereMesure(null);
    } finally {
      setLoading(false);
    }
  };

  const creerDonneesTest = async () => {
    if (!rucheId.trim()) {
      setError('Veuillez saisir un ID de ruche');
      return;
    }

    try {
      setLoading(true);
      setError('');
      
      const nombreMesures = await DonneesCapteursService.creerDonneesTest(rucheId, 7, 8);
      setError(`✅ ${nombreMesures} mesures créées avec succès`);
    } catch (err: any) {
      setError(`Erreur lors de la création: ${err.message}`);
    } finally {
      setLoading(false);
    }
  };

  const formatTimestamp = (date: Date) => {
    return date.toLocaleString('fr-FR', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });
  };

  return (
    <div className="max-w-4xl mx-auto p-6 bg-white rounded-lg shadow-lg">
      <h2 className="text-2xl font-bold mb-6 text-gray-800">
        🧪 Test Firebase - Données Capteurs
      </h2>

      {/* Configuration */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            ID de la ruche
          </label>
          <input
            type="text"
            value={rucheId}
            onChange={(e) => setRucheId(e.target.value)}
            placeholder="Saisir l'ID de la ruche"
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            ID de l'apiculteur
          </label>
          <input
            type="text"
            value={apiculteurId}
            onChange={(e) => setApiculteurId(e.target.value)}
            placeholder="ID de l'apiculteur"
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
      </div>

      {/* Boutons d'action */}
      <div className="flex flex-wrap gap-3 mb-6">
        <button
          onClick={testerConnectivite}
          disabled={loading}
          className="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 disabled:opacity-50"
        >
          {loading ? '⏳' : '🔗'} Test Connectivité Firebase
        </button>
        
        <button
          onClick={recupererDerniereMesure}
          disabled={loading || !rucheId.trim()}
          className="px-4 py-2 bg-green-500 text-white rounded-md hover:bg-green-600 disabled:opacity-50"
        >
          {loading ? '⏳' : '📊'} Dernière Mesure
        </button>
        
        <button
          onClick={obtenirMesures7Jours}
          disabled={loading || !rucheId.trim()}
          className="px-4 py-2 bg-orange-500 text-white rounded-md hover:bg-orange-600 disabled:opacity-50"
        >
          {loading ? '⏳' : '📈'} Mesures 7 Jours
        </button>
        
        <button
          onClick={creerDonneesTest}
          disabled={loading || !rucheId.trim()}
          className="px-4 py-2 bg-purple-500 text-white rounded-md hover:bg-purple-600 disabled:opacity-50"
        >
          {loading ? '⏳' : '🎲'} Créer Données Test
        </button>
      </div>

      {/* Statut de connectivité */}
      {connectivite !== null && (
        <div className={`p-3 rounded-md mb-4 ${
          connectivite ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
        }`}>
          {connectivite ? '✅ Firebase accessible' : '❌ Firebase non accessible'}
        </div>
      )}

      {/* Erreurs */}
      {error && (
        <div className={`p-3 rounded-md mb-4 ${
          error.startsWith('✅') ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
        }`}>
          {error}
        </div>
      )}

      {/* Résultats */}
      {derniereMesure && (
        <div className="bg-gray-50 p-4 rounded-md">
          <h3 className="text-lg font-semibold mb-3 text-gray-800">
            📊 Dernière Mesure
          </h3>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div className="bg-white p-3 rounded border">
              <div className="text-sm text-gray-600">ID</div>
              <div className="font-mono text-sm">{derniereMesure.id}</div>
            </div>
            
            <div className="bg-white p-3 rounded border">
              <div className="text-sm text-gray-600">Ruche ID</div>
              <div className="font-mono text-sm">{derniereMesure.rucheId}</div>
            </div>
            
            <div className="bg-white p-3 rounded border">
              <div className="text-sm text-gray-600">Timestamp</div>
              <div className="text-sm">{formatTimestamp(derniereMesure.timestamp)}</div>
            </div>
            
            <div className="bg-white p-3 rounded border">
              <div className="text-sm text-gray-600">Température</div>
              <div className="text-lg font-semibold text-red-600">
                {derniereMesure.temperature?.toFixed(1)}°C
              </div>
            </div>
            
            <div className="bg-white p-3 rounded border">
              <div className="text-sm text-gray-600">Humidité</div>
              <div className="text-lg font-semibold text-blue-600">
                {derniereMesure.humidity?.toFixed(1)}%
              </div>
            </div>
            
            <div className="bg-white p-3 rounded border">
              <div className="text-sm text-gray-600">Batterie</div>
              <div className="text-lg font-semibold text-green-600">
                {derniereMesure.batterie}%
              </div>
            </div>
            
            <div className="bg-white p-3 rounded border">
              <div className="text-sm text-gray-600">Couvercle</div>
              <div className={`text-lg font-semibold ${
                derniereMesure.couvercleOuvert ? 'text-orange-600' : 'text-green-600'
              }`}>
                {derniereMesure.couvercleOuvert ? '🔓 Ouvert' : '🔒 Fermé'}
              </div>
            </div>
            
            <div className="bg-white p-3 rounded border">
              <div className="text-sm text-gray-600">Signal</div>
              <div className="text-lg font-semibold text-purple-600">
                {derniereMesure.signalQualite}%
              </div>
            </div>
            
            {derniereMesure.erreur && (
              <div className="bg-white p-3 rounded border">
                <div className="text-sm text-gray-600">Erreur</div>
                <div className="text-sm text-red-600">{derniereMesure.erreur}</div>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Instructions */}
      <div className="mt-6 p-4 bg-blue-50 rounded-md">
        <h4 className="font-semibold text-blue-800 mb-2">📋 Instructions</h4>
        <ol className="text-sm text-blue-700 space-y-1">
          <li>1. Testez d'abord la connectivité avec l'API Spring Boot</li>
          <li>2. Saisissez un ID de ruche (ou créez des données de test)</li>
          <li>3. Utilisez "Dernière Mesure (Auth)" pour l'endpoint sécurisé</li>
          <li>4. Utilisez "Test Sans Auth" pour l'endpoint de développement</li>
        </ol>
      </div>
    </div>
  );
};

export default TestDerniereMesure; 