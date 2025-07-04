import React, { useState } from 'react';
import { ChevronDown, Activity, Hexagon, TrendingUp, Calendar, RefreshCw } from 'lucide-react';
import MesuresRuche from '../MesuresRuche';
import { RucheAvecRucher } from '../../services/rucheService';

interface ChartSectionProps {
  ruches: RucheAvecRucher[];
  selectedRucheId: string;
  onRucheChange: (rucheId: string) => void;
  loading?: boolean;
  onAddRuche?: () => void;
  onRefreshData?: () => void;
}

type TimeRange = '24h' | '7d' | '30d' | '90d';

interface TimeRangeOption {
  value: TimeRange;
  label: string;
  description: string;
}

const ChartSection: React.FC<ChartSectionProps> = ({
  ruches,
  selectedRucheId,
  onRucheChange,
  loading = false,
  onAddRuche,
  onRefreshData
}) => {
  const [timeRange, setTimeRange] = useState<TimeRange>('7d');
  const [refreshing, setRefreshing] = useState(false);

  const timeRangeOptions: TimeRangeOption[] = [
    { value: '24h', label: '24h', description: 'Dernières 24 heures' },
    { value: '7d', label: '7j', description: '7 derniers jours' },
    { value: '30d', label: '30j', description: '30 derniers jours' },
    { value: '90d', label: '90j', description: '3 derniers mois' }
  ];

  const selectedRuche = ruches.find(r => r.id === selectedRucheId);

  const handleRefresh = async () => {
    if (refreshing || !onRefreshData) return;
    
    setRefreshing(true);
    try {
      await onRefreshData();
    } catch (error) {
      console.error('Erreur lors de l\'actualisation:', error);
    } finally {
      setRefreshing(false);
    }
  };

  const ChartSkeleton = () => (
    <div className="h-64 p-6 animate-pulse">
      <div className="h-4 bg-gray-200 rounded w-1/4 mb-4"></div>
      <div className="h-40 bg-gray-200 rounded"></div>
    </div>
  );

  if (loading) {
    return (
      <div className="lg:col-span-2 bg-white rounded-xl shadow-lg border border-gray-100">
        <div className="p-6 border-b border-gray-100">
          <div className="h-6 bg-gray-200 rounded w-1/3 mb-4 animate-pulse"></div>
          <div className="flex space-x-4">
            <div className="h-8 bg-gray-200 rounded w-32 animate-pulse"></div>
            <div className="h-8 bg-gray-200 rounded w-24 animate-pulse"></div>
          </div>
        </div>
        <ChartSkeleton />
      </div>
    );
  }

  return (
    <div className="lg:col-span-2 bg-white rounded-xl shadow-lg hover-lift border border-gray-100 animate-slide-in-left">
      {/* En-tête avec contrôles */}
      <div className="p-6 border-b border-gray-100">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <h3 className="text-xl font-bold text-gray-900 mb-2">Mesures en temps réel</h3>
            {selectedRuche && (
              <div className="flex items-center space-x-2 text-sm text-gray-600">
                <div className={`w-2 h-2 rounded-full ${selectedRuche.enService ? 'bg-green-500' : 'bg-red-500'}`}></div>
                <span>
                  {selectedRuche.enService ? 'En ligne' : 'Hors ligne'} • 
                  Dernière mise à jour il y a {Math.floor(Math.random() * 30) + 1} min
                </span>
              </div>
            )}
          </div>
          
          <div className="flex items-center space-x-3">
            {/* Bouton d'actualisation */}
            {onRefreshData && (
              <button
                onClick={handleRefresh}
                disabled={refreshing}
                className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors disabled:opacity-50"
                title="Actualiser les données"
                aria-label="Actualiser les données"
              >
                <RefreshCw size={18} className={refreshing ? 'animate-spin' : ''} />
              </button>
            )}

            {/* Sélection de période */}
            <div className="flex bg-gray-100 rounded-lg p-1">
              {timeRangeOptions.map((option) => (
                <button
                  key={option.value}
                  onClick={() => setTimeRange(option.value)}
                  className={`px-3 py-1 text-sm font-medium rounded-md transition-all ${
                    timeRange === option.value
                      ? 'bg-white text-amber-700 shadow-sm'
                      : 'text-gray-500 hover:text-gray-700 hover:bg-gray-50'
                  }`}
                  title={option.description}
                >
                  {option.label}
                </button>
              ))}
            </div>
          </div>
        </div>
        
        {/* Sélecteur de ruche */}
        {ruches.length > 0 && (
          <div className="flex items-center space-x-3 mt-4">
            <label className="text-sm font-medium text-gray-700">Ruche :</label>
            <div className="relative">
              <select
                value={selectedRucheId}
                onChange={(e) => onRucheChange(e.target.value)}
                className="appearance-none bg-white border border-gray-300 rounded-lg px-4 py-2 pr-8 text-sm font-medium text-gray-900 focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent min-w-0"
              >
                {ruches.map((ruche) => (
                  <option key={ruche.id} value={ruche.id}>
                    {ruche.nom} - {ruche.rucherNom || 'Rucher inconnu'}
                  </option>
                ))}
              </select>
              <ChevronDown size={16} className="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-400 pointer-events-none" />
            </div>
            
            {/* Informations sur la ruche sélectionnée */}
            {selectedRuche && (
              <div className="flex items-center space-x-4 text-xs text-gray-500 ml-4">
                <div className="flex items-center space-x-1">
                  <Calendar size={12} />
                  <span>Installée le {new Date(selectedRuche.dateInstallation || Date.now()).toLocaleDateString('fr-FR')}</span>
                </div>
                {selectedRuche.localisation && (
                  <div className="flex items-center space-x-1">
                    <span>📍 {selectedRuche.localisation}</span>
                  </div>
                )}
              </div>
            )}
          </div>
        )}
      </div>
      
      {/* Contenu des graphiques */}
      <div className="relative">
        {ruches.length === 0 ? (
          <div className="h-64 flex items-center justify-center p-6">
            <div className="text-center">
              <Hexagon size={48} className="text-gray-400 mx-auto mb-4" />
              <h4 className="text-lg font-medium text-gray-600 mb-2">Aucune ruche trouvée</h4>
              <p className="text-gray-500 text-sm mb-6">
                Ajoutez des ruches pour commencer à visualiser les mesures de vos capteurs IoT
              </p>
              {onAddRuche && (
                <button 
                  onClick={onAddRuche}
                  className="inline-flex items-center space-x-2 px-4 py-2 bg-amber-600 text-white rounded-lg font-medium hover:bg-amber-700 transition-colors focus-ring-amber"
                >
                  <Hexagon size={18} />
                  <span>Ajouter une ruche</span>
                </button>
              )}
            </div>
          </div>
        ) : selectedRucheId ? (
          <div className="relative">
            {/* Indicateur de chargement des données */}
            {refreshing && (
              <div className="absolute top-4 right-4 z-10">
                <div className="flex items-center space-x-2 bg-white shadow-lg rounded-lg px-3 py-2 text-sm">
                  <div className="animate-spin w-4 h-4 border-2 border-amber-600 border-t-transparent rounded-full"></div>
                  <span className="text-gray-600">Actualisation...</span>
                </div>
              </div>
            )}
            
            <MesuresRuche 
              rucheId={selectedRucheId} 
              rucheNom={selectedRuche?.nom || 'Ruche inconnue'}
              timeRange={timeRange}
            />
          </div>
        ) : (
          <div className="h-64 flex items-center justify-center p-6">
            <div className="text-center">
              <Activity size={48} className="text-amber-400 mx-auto mb-4" />
              <h4 className="text-lg font-medium text-amber-700 mb-2">Sélectionnez une ruche</h4>
              <p className="text-amber-600 text-sm">
                Choisissez une ruche dans la liste pour voir ses mesures détaillées
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ChartSection; 