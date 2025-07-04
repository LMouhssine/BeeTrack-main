import React, { useState, useEffect } from 'react';
import { 
  LineChart, 
  Line, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  Legend, 
  ResponsiveContainer,
  BarChart,
  Bar
} from 'recharts';
import { 
  Thermometer, 
  Droplets, 
  Battery, 
  Signal, 
  AlertTriangle, 
  TrendingUp, 
  Activity,
  RefreshCw,
  Download,
  Eye,
  EyeOff
} from 'lucide-react';
import { RucheService, DonneesCapteur } from '../services/rucheService';
import DiagnosticFirebase from './DiagnosticApi';
import { TestDataService } from '../services/testDataService';

interface MesuresRucheProps {
  rucheId: string;
  rucheNom: string;
}

interface StatistiquesData {
  temperatureMin: number;
  temperatureMax: number;
  temperatureMoyenne: number;
  humiditeMin: number;
  humiditeMax: number;
  humiditeMoyenne: number;
  batterieMin: number;
  batterieMax: number;
  batterieMoyenne: number;
  nombreMesures: number;
}

const MesuresRuche: React.FC<MesuresRucheProps> = ({ rucheId, rucheNom }) => {
  const [mesures, setMesures] = useState<DonneesCapteur[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [stats, setStats] = useState<StatistiquesData | null>(null);
  const [showTemperature, setShowTemperature] = useState(true);
  const [showHumidity, setShowHumidity] = useState(true);
  const [loadingMessage, setLoadingMessage] = useState('Chargement des mesures...');

  useEffect(() => {
    loadMesures();
  }, [rucheId]);

  const loadMesures = async () => {
    try {
      setLoading(true);
      setError('');
      setLoadingMessage('Chargement des mesures...');
      console.log('🔄 Chargement des mesures pour la ruche:', rucheId);
      
      const mesuresData = await RucheService.obtenirMesures7DerniersJoursRobuste(rucheId);
      setMesures(mesuresData);
      console.log('✅ Mesures chargées:', mesuresData.length, 'mesures trouvées');
      
      if (mesuresData.length > 0) {
        calculerStatistiques(mesuresData);
      }
    } catch (error: any) {
      console.error('❌ Erreur lors du chargement des mesures:', error);
      setError(error.message || 'Erreur lors du chargement des mesures');
    } finally {
      setLoading(false);
    }
  };

  // Version sans gestion du loading pour éviter les conflits
  const loadMesuresSansLoading = async () => {
    try {
      setError('');
      console.log('🔄 Rechargement des mesures après création de données...');
      
      const mesuresData = await RucheService.obtenirMesures7DerniersJoursRobuste(rucheId);
      setMesures(mesuresData);
      console.log('✅ Mesures rechargées:', mesuresData.length, 'mesures trouvées');
      
      if (mesuresData.length > 0) {
        calculerStatistiques(mesuresData);
      }
    } catch (error: any) {
      console.error('❌ Erreur lors du rechargement des mesures:', error);
      setError(error.message || 'Erreur lors du chargement des mesures');
    }
  };

  const calculerStatistiques = (mesuresData: DonneesCapteur[]) => {
    const mesuresValides = mesuresData.filter(m => 
      m.temperature !== null && m.temperature !== undefined &&
      m.humidity !== null && m.humidity !== undefined
    );

    if (mesuresValides.length === 0) return;

    const temperatures = mesuresValides.map(m => m.temperature!).filter(t => !isNaN(t));
    const humidites = mesuresValides.map(m => m.humidity!).filter(h => !isNaN(h));
    const batteries = mesuresData.filter(m => m.batterie).map(m => m.batterie!);

    const stats: StatistiquesData = {
      temperatureMin: Math.min(...temperatures),
      temperatureMax: Math.max(...temperatures),
      temperatureMoyenne: temperatures.reduce((a, b) => a + b, 0) / temperatures.length,
      humiditeMin: Math.min(...humidites),
      humiditeMax: Math.max(...humidites),
      humiditeMoyenne: humidites.reduce((a, b) => a + b, 0) / humidites.length,
      batterieMin: batteries.length > 0 ? Math.min(...batteries) : 0,
      batterieMax: batteries.length > 0 ? Math.max(...batteries) : 0,
      batterieMoyenne: batteries.length > 0 ? batteries.reduce((a, b) => a + b, 0) / batteries.length : 0,
      nombreMesures: mesuresData.length,
    };

    setStats(stats);
  };

  const creerDonneesTest = async () => {
    try {
      setLoading(true);
      setError('');
      setLoadingMessage('Création des données de test...');
      console.log('🧪 Début de création des données de test pour la ruche:', rucheId);
      
      try {
        // Essayer d'abord l'endpoint principal avec authentification
        console.log('🔄 Tentative avec l\'endpoint principal...');
        await RucheService.creerDonneesTest(rucheId, 10, 8);
        console.log('✅ Données créées via l\'endpoint principal');
      } catch (error) {
        console.log('⚠️ Échec de l\'endpoint principal, essai de l\'endpoint dev...');
        try {
          // En cas d'échec, essayer l'endpoint de développement
          console.log('🔄 Tentative avec l\'endpoint de développement...');
          await RucheService.creerDonneesTestDev(rucheId, 10, 8);
          console.log('✅ Données créées via l\'endpoint de développement');
        } catch (devError) {
          console.log('⚠️ Échec de l\'endpoint dev, création directe dans Firestore...');
          // En dernier recours, créer directement dans Firestore
          console.log('🔄 Tentative avec Firestore direct...');
          await TestDataService.creerDonneesTestFirestore(rucheId, 10, 8);
          console.log('✅ Données créées directement dans Firestore');
        }
      }
      
      setLoadingMessage('Rechargement des mesures...');
      // Recharger les données après création (sans conflit de loading)
      await loadMesuresSansLoading();
      console.log('✅ Processus de création de données terminé avec succès');
    } catch (error: any) {
      console.error('❌ Échec de création des données de test:', error);
      setError(error.message || 'Erreur lors de la création des données de test');
    } finally {
      setLoading(false);
    }
  };

  const creerDonneesTestFirestore = async () => {
    try {
      setLoading(true);
      setError('');
      setLoadingMessage('Création des données via Firestore...');
      console.log('🔥 Début de création des données via Firestore pour la ruche:', rucheId);
      
      await TestDataService.creerDonneesTestFirestore(rucheId, 10, 8);
      console.log('✅ Données créées directement dans Firestore');
      
      setLoadingMessage('Rechargement des mesures...');
      // Recharger les données après création (sans conflit de loading)
      await loadMesuresSansLoading();
      console.log('✅ Processus de création Firestore terminé avec succès');
    } catch (error: any) {
      console.error('❌ Échec de création des données de test Firestore:', error);
      setError(error.message || 'Erreur lors de la création des données de test Firestore');
    } finally {
      setLoading(false);
    }
  };

  const chargerDepuisFirestore = async () => {
    try {
      setLoading(true);
      setError('');
      setLoadingMessage('Chargement depuis Firestore...');
      console.log('🔥 Chargement direct depuis Firestore pour la ruche:', rucheId);
      
      const mesuresData = await RucheService.obtenirMesures7DerniersJoursFirestore(rucheId);
      setMesures(mesuresData);
      console.log('✅ Mesures chargées depuis Firestore:', mesuresData.length, 'mesures trouvées');
      
      if (mesuresData.length > 0) {
        calculerStatistiques(mesuresData);
      }
    } catch (error: any) {
      console.error('❌ Erreur lors du chargement depuis Firestore:', error);
      setError(error.message || 'Erreur lors du chargement depuis Firestore');
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (timestamp: Date) => {
    return new Intl.DateTimeFormat('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    }).format(timestamp);
  };

  const formatDateComplete = (timestamp: Date) => {
    return new Intl.DateTimeFormat('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    }).format(timestamp);
  };

  const formatNumber = (value: number, decimales: number = 1) => {
    return value.toFixed(decimales);
  };

  // Préparer les données pour les graphiques
  const dataForChart = mesures.map(mesure => ({
    timestamp: formatDate(mesure.timestamp),
    timestampComplete: formatDateComplete(mesure.timestamp),
    temperature: mesure.temperature,
    humidity: mesure.humidity,
    batterie: mesure.batterie,
    signalQualite: mesure.signalQualite,
    couvercleOuvert: mesure.couvercleOuvert ? 1 : 0,
  }));

  if (loading) {
    return (
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-amber-600 mx-auto mb-4"></div>
          <p className="text-gray-600">{loadingMessage}</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-6">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="text-center py-12">
            <AlertTriangle className="w-12 h-12 text-red-500 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-red-900 mb-2">Erreur</h3>
            <p className="text-red-700 mb-4">{error}</p>
            <div className="space-x-4">
              <button
                onClick={loadMesures}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                <RefreshCw size={16} className="inline mr-2" />
                Réessayer
              </button>
              <button
                onClick={chargerDepuisFirestore}
                className="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors"
              >
                🔥 Charger depuis Firestore
              </button>
              <button
                onClick={creerDonneesTest}
                className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
              >
                🧪 Créer des données de test
              </button>
              <button
                onClick={creerDonneesTestFirestore}
                className="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
              >
                🔥 Créer via Firestore
              </button>
            </div>
          </div>
        </div>
        
        {/* Diagnostic API en cas d'erreur */}
        <DiagnosticFirebase />
      </div>
    );
  }

  if (mesures.length === 0) {
    return (
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="text-center py-12">
          <Activity className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Aucune mesure</h3>
          <p className="text-gray-600 mb-4">Aucune mesure trouvée pour les 7 derniers jours.</p>
          <button
            onClick={chargerDepuisFirestore}
            className="px-4 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors"
          >
            🔥 Charger depuis Firestore
          </button>
          <button
            onClick={creerDonneesTest}
            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
          >
            🧪 Créer des données de test
          </button>
          <button
            onClick={creerDonneesTestFirestore}
            className="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
          >
            🔥 Créer via Firestore
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-8 p-6">
      {/* En-tête */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Mesures - {rucheNom}</h2>
          <p className="text-gray-600">Données des 7 derniers jours</p>
        </div>
        <div className="flex items-center space-x-3">
          <button
            onClick={loadMesures}
            disabled={loading}
            className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:bg-gray-400"
          >
            <RefreshCw size={16} className={loading ? 'animate-spin' : ''} />
            <span>Actualiser</span>
          </button>
        </div>
      </div>

      {/* Statistiques */}
      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
            <div className="flex items-center space-x-4">
              <Thermometer className="w-10 h-10 text-blue-600" />
              <div>
                <p className="text-sm text-blue-600 font-medium mb-1">Température</p>
                <p className="text-2xl font-bold text-blue-900 mb-1">{formatNumber(stats.temperatureMoyenne)}°C</p>
                <p className="text-xs text-blue-700">
                  Min: {formatNumber(stats.temperatureMin)}°C | Max: {formatNumber(stats.temperatureMax)}°C
                </p>
              </div>
            </div>
          </div>

          <div className="bg-green-50 border border-green-200 rounded-lg p-6">
            <div className="flex items-center space-x-4">
              <Droplets className="w-10 h-10 text-green-600" />
              <div>
                <p className="text-sm text-green-600 font-medium mb-1">Humidité</p>
                <p className="text-2xl font-bold text-green-900 mb-1">{formatNumber(stats.humiditeMoyenne)}%</p>
                <p className="text-xs text-green-700">
                  Min: {formatNumber(stats.humiditeMin)}% | Max: {formatNumber(stats.humiditeMax)}%
                </p>
              </div>
            </div>
          </div>

          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6">
            <div className="flex items-center space-x-4">
              <Battery className="w-10 h-10 text-yellow-600" />
              <div>
                <p className="text-sm text-yellow-600 font-medium mb-1">Batterie</p>
                <p className="text-2xl font-bold text-yellow-900 mb-1">{formatNumber(stats.batterieMoyenne, 0)}%</p>
                <p className="text-xs text-yellow-700">
                  Min: {formatNumber(stats.batterieMin, 0)}% | Max: {formatNumber(stats.batterieMax, 0)}%
                </p>
              </div>
            </div>
          </div>

          <div className="bg-purple-50 border border-purple-200 rounded-lg p-6">
            <div className="flex items-center space-x-4">
              <TrendingUp className="w-10 h-10 text-purple-600" />
              <div>
                <p className="text-sm text-purple-600 font-medium mb-1">Mesures</p>
                <p className="text-2xl font-bold text-purple-900 mb-1">{stats.nombreMesures}</p>
                <p className="text-xs text-purple-700">Derniers 7 jours</p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Contrôles d'affichage */}
      <div className="bg-gray-50 border border-gray-200 rounded-lg p-6 mb-8">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Contrôles d'affichage</h3>
        <div className="flex flex-wrap gap-3">
          <button
            onClick={() => setShowTemperature(!showTemperature)}
            className={`flex items-center space-x-2 px-4 py-2 rounded-lg transition-colors ${
              showTemperature 
                ? 'bg-blue-600 text-white shadow-md' 
                : 'bg-white border border-gray-300 text-gray-700 hover:bg-gray-50'
            }`}
          >
            {showTemperature ? <Eye size={16} /> : <EyeOff size={16} />}
            <span>Température</span>
          </button>
          <button
            onClick={() => setShowHumidity(!showHumidity)}
            className={`flex items-center space-x-2 px-4 py-2 rounded-lg transition-colors ${
              showHumidity 
                ? 'bg-green-600 text-white shadow-md' 
                : 'bg-white border border-gray-300 text-gray-700 hover:bg-gray-50'
            }`}
          >
            {showHumidity ? <Eye size={16} /> : <EyeOff size={16} />}
            <span>Humidité</span>
          </button>
        </div>
      </div>

      {/* Graphique principal */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-8 mb-8">
        <h3 className="text-xl font-medium text-gray-900 mb-6">Évolution Température et Humidité</h3>
        <div className="h-96">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={dataForChart}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis 
                dataKey="timestamp" 
                tick={{ fontSize: 12 }}
                angle={-45}
                textAnchor="end"
                height={80}
              />
              <YAxis yAxisId="temp" orientation="left" domain={['dataMin - 5', 'dataMax + 5']} />
              <YAxis yAxisId="humidity" orientation="right" domain={[0, 100]} />
              <Tooltip 
                labelFormatter={(label, payload) => {
                  if (payload && payload[0]) {
                    return payload[0].payload.timestampComplete;
                  }
                  return label;
                }}
                formatter={(value: any, name: string) => {
                  if (name === 'temperature') return [`${value?.toFixed(1)}°C`, 'Température'];
                  if (name === 'humidity') return [`${value?.toFixed(1)}%`, 'Humidité'];
                  return [value, name];
                }}
              />
              <Legend />
              {showTemperature && (
                <Line 
                  yAxisId="temp"
                  type="monotone" 
                  dataKey="temperature" 
                  stroke="#3B82F6" 
                  strokeWidth={2}
                  dot={{ fill: '#3B82F6', strokeWidth: 2, r: 3 }}
                  name="Température (°C)"
                />
              )}
              {showHumidity && (
                <Line 
                  yAxisId="humidity"
                  type="monotone" 
                  dataKey="humidity" 
                  stroke="#10B981" 
                  strokeWidth={2}
                  dot={{ fill: '#10B981', strokeWidth: 2, r: 3 }}
                  name="Humidité (%)"
                />
              )}
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Graphique batterie */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-8 mb-8">
        <h3 className="text-xl font-medium text-gray-900 mb-6">Niveau de Batterie</h3>
        <div className="h-80">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={dataForChart}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis 
                dataKey="timestamp" 
                tick={{ fontSize: 12 }}
                angle={-45}
                textAnchor="end"
                height={80}
              />
              <YAxis domain={[0, 100]} />
              <Tooltip 
                labelFormatter={(label, payload) => {
                  if (payload && payload[0]) {
                    return payload[0].payload.timestampComplete;
                  }
                  return label;
                }}
                formatter={(value: any) => [`${value}%`, 'Batterie']}
              />
              <Bar 
                dataKey="batterie" 
                fill="#F59E0B" 
                name="Batterie (%)"
                radius={[4, 4, 0, 0]}
              />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Tableau des dernières mesures */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
        <h3 className="text-xl font-medium text-gray-900 mb-6">Dernières Mesures</h3>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date/Heure
                </th>
                <th className="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Température
                </th>
                <th className="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Humidité
                </th>
                <th className="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Batterie
                </th>
                <th className="px-6 py-4 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Couvercle
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {mesures.slice(0, 10).map((mesure, index) => (
                <tr key={mesure.id || index} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {formatDateComplete(mesure.timestamp)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {mesure.temperature ? `${formatNumber(mesure.temperature)}°C` : '-'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {mesure.humidity ? `${formatNumber(mesure.humidity)}%` : '-'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <div className="flex items-center space-x-2">
                      <Battery size={16} className={`${
                        !mesure.batterie ? 'text-gray-400' :
                        mesure.batterie > 50 ? 'text-green-600' : 
                        mesure.batterie > 20 ? 'text-yellow-600' : 'text-red-600'
                      }`} />
                      <span>{mesure.batterie ? `${mesure.batterie}%` : '-'}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <span className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-medium ${
                      mesure.couvercleOuvert 
                        ? 'bg-red-100 text-red-800' 
                        : 'bg-green-100 text-green-800'
                    }`}>
                      {mesure.couvercleOuvert ? 'Ouvert' : 'Fermé'}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default MesuresRuche; 