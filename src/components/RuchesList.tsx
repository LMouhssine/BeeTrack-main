import React, { useState, useEffect } from 'react';
import { 
  Box, 
  Plus, 
  MapPin, 
  Calendar, 
  Search, 
  Filter, 
  Trash2, 
  Edit3, 
  CheckCircle, 
  AlertTriangle, 
  Home,
  User,
  Clock,
  Activity
} from 'lucide-react';
import { RucheService, RucheAvecRucher } from '../services/rucheService';
import AjouterRucheModal from './AjouterRucheModal';

const RuchesList: React.FC = () => {
  const [ruches, setRuches] = useState<RucheAvecRucher[]>([]);
  const [filteredRuches, setFilteredRuches] = useState<RucheAvecRucher[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState<'all' | 'enService' | 'horsService'>('all');
  const [showAddModal, setShowAddModal] = useState(false);
  const [error, setError] = useState('');

  // Statistiques
  const stats = {
    total: ruches.length,
    enService: ruches.filter(r => r.enService).length,
    horsService: ruches.filter(r => !r.enService).length,
    ruchers: new Set(ruches.map(r => r.idRucher)).size
  };

  useEffect(() => {
    loadRuches();
  }, []);

  useEffect(() => {
    // Filtrer les ruches selon les critères
    let filtered = ruches;

    // Filtre par recherche
    if (searchTerm) {
      filtered = filtered.filter(ruche =>
        ruche.nom.toLowerCase().includes(searchTerm.toLowerCase()) ||
        ruche.position.toLowerCase().includes(searchTerm.toLowerCase()) ||
        ruche.rucherNom?.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    // Filtre par statut
    if (filterStatus !== 'all') {
      filtered = filtered.filter(ruche =>
        filterStatus === 'enService' ? ruche.enService : !ruche.enService
      );
    }

    setFilteredRuches(filtered);
  }, [ruches, searchTerm, filterStatus]);

  const loadRuches = async () => {
    try {
      setLoading(true);
      setError('');
      
      const ruchesData = await RucheService.obtenirRuchesUtilisateur();
      setRuches(ruchesData);
      console.log('🐝 Ruches chargées:', ruchesData.length);
      
    } catch (error: any) {
      console.error('Erreur lors du chargement des ruches:', error);
      setError('Impossible de charger les ruches: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteRuche = async (id: string, nom: string) => {
    if (!window.confirm(`Êtes-vous sûr de vouloir supprimer la ruche "${nom}" ?`)) {
      return;
    }

    try {
      await RucheService.supprimerRuche(id);
      console.log('🐝 Ruche supprimée:', id);
      await loadRuches(); // Recharger la liste
    } catch (error: any) {
      console.error('Erreur lors de la suppression:', error);
      alert('Erreur lors de la suppression: ' + error.message);
    }
  };

  const formatDate = (dateString: string) => {
    return new Intl.DateTimeFormat('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    }).format(new Date(dateString));
  };

  if (loading) {
    return (
      <div className="text-center py-12">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-amber-600 mx-auto mb-4"></div>
        <p className="text-gray-600">Chargement des ruches...</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* En-tête avec statistiques */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="text-2xl font-bold text-gray-900 flex items-center">
              <Box className="mr-3 text-amber-600" />
              Mes Ruches
            </h2>
            <p className="text-gray-600 mt-1">Gérez vos ruches et suivez leur état</p>
          </div>
          <button
            onClick={() => setShowAddModal(true)}
            className="flex items-center space-x-2 bg-amber-600 hover:bg-amber-700 text-white px-4 py-2 rounded-lg transition-colors"
          >
            <Plus size={20} />
            <span>Ajouter une ruche</span>
          </button>
        </div>

        {/* Statistiques */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div className="bg-blue-50 p-4 rounded-lg border border-blue-200">
            <div className="flex items-center">
              <Home className="w-8 h-8 text-blue-600 mr-3" />
              <div>
                <p className="text-sm font-medium text-blue-600">Total</p>
                <p className="text-2xl font-bold text-blue-900">{stats.total}</p>
              </div>
            </div>
          </div>

          <div className="bg-green-50 p-4 rounded-lg border border-green-200">
            <div className="flex items-center">
              <CheckCircle className="w-8 h-8 text-green-600 mr-3" />
              <div>
                <p className="text-sm font-medium text-green-600">En service</p>
                <p className="text-2xl font-bold text-green-900">{stats.enService}</p>
              </div>
            </div>
          </div>

          <div className="bg-yellow-50 p-4 rounded-lg border border-yellow-200">
            <div className="flex items-center">
              <AlertTriangle className="w-8 h-8 text-yellow-600 mr-3" />
              <div>
                <p className="text-sm font-medium text-yellow-600">Hors service</p>
                <p className="text-2xl font-bold text-yellow-900">{stats.horsService}</p>
              </div>
            </div>
          </div>

          <div className="bg-purple-50 p-4 rounded-lg border border-purple-200">
            <div className="flex items-center">
              <MapPin className="w-8 h-8 text-purple-600 mr-3" />
              <div>
                <p className="text-sm font-medium text-purple-600">Ruchers</p>
                <p className="text-2xl font-bold text-purple-900">{stats.ruchers}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Filtres et recherche */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
        <div className="flex flex-col md:flex-row gap-4">
          {/* Recherche */}
          <div className="flex-1">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
              <input
                type="text"
                placeholder="Rechercher par nom, position ou rucher..."
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
          </div>

          {/* Filtre par statut */}
          <div className="flex items-center space-x-2">
            <Filter size={20} className="text-gray-400" />
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value as typeof filterStatus)}
              className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
            >
              <option value="all">Toutes les ruches</option>
              <option value="enService">En service</option>
              <option value="horsService">Hors service</option>
            </select>
          </div>
        </div>
      </div>

      {/* Messages d'erreur */}
      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4 flex items-center space-x-2">
          <AlertTriangle className="w-5 h-5 text-red-500 flex-shrink-0" />
          <div className="flex-1">
            <span className="text-sm text-red-700">{error}</span>
          </div>
          <button
            onClick={loadRuches}
            className="text-sm text-red-600 hover:text-red-800 font-medium"
          >
            Réessayer
          </button>
        </div>
      )}

      {/* Liste des ruches */}
      {filteredRuches.length === 0 ? (
        <div className="text-center py-12 bg-white rounded-lg shadow-sm border border-gray-200">
          {searchTerm || filterStatus !== 'all' ? (
            <div>
              <Search className="mx-auto text-gray-400 mb-4" size={48} />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Aucune ruche trouvée</h3>
              <p className="text-gray-600 mb-4">Essayez de modifier vos critères de recherche</p>
              <button
                onClick={() => {
                  setSearchTerm('');
                  setFilterStatus('all');
                }}
                className="text-amber-600 hover:text-amber-700 font-medium"
              >
                Réinitialiser les filtres
              </button>
            </div>
          ) : (
            <div>
              <Home className="mx-auto text-amber-500 mb-4" size={64} />
              <h3 className="text-xl font-semibold text-gray-900 mb-2">
                Aucune ruche créée
              </h3>
              <p className="text-gray-600 mb-6 max-w-md mx-auto">
                Commencez par ajouter votre première ruche pour commencer à gérer votre exploitation apicole.
              </p>
              <button
                onClick={() => setShowAddModal(true)}
                className="inline-flex items-center space-x-2 bg-amber-600 hover:bg-amber-700 text-white px-6 py-3 rounded-lg transition-colors"
              >
                <Plus size={20} />
                <span>Ajouter ma première ruche</span>
              </button>
            </div>
          )}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredRuches.map((ruche) => (
            <div key={ruche.id} className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden hover:shadow-md transition-shadow">
              {/* En-tête de la carte */}
              <div className="p-4 border-b border-gray-200">
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-3">
                    <div className={`p-2 rounded-lg ${ruche.enService ? 'bg-green-100' : 'bg-yellow-100'}`}>
                      <Home className={`w-6 h-6 ${ruche.enService ? 'text-green-600' : 'text-yellow-600'}`} />
                    </div>
                    <div>
                      <h3 className="font-semibold text-gray-900">{ruche.nom}</h3>
                      <p className="text-sm text-gray-500">Position: {ruche.position}</p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-1">
                    <button
                      onClick={() => console.log('Éditer ruche:', ruche.id)}
                      className="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                      title="Modifier"
                    >
                      <Edit3 size={16} />
                    </button>
                    <button
                      onClick={() => handleDeleteRuche(ruche.id, ruche.nom)}
                      className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                      title="Supprimer"
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                </div>
              </div>

              {/* Contenu de la carte */}
              <div className="p-4 space-y-3">
                {/* Statut */}
                <div className="flex items-center space-x-2">
                  {ruche.enService ? (
                    <>
                      <CheckCircle className="w-4 h-4 text-green-500" />
                      <span className="text-sm font-medium text-green-700">En service</span>
                    </>
                  ) : (
                    <>
                      <AlertTriangle className="w-4 h-4 text-yellow-500" />
                      <span className="text-sm font-medium text-yellow-700">Hors service</span>
                    </>
                  )}
                </div>

                {/* Rucher */}
                <div className="flex items-center space-x-2 text-gray-600">
                  <MapPin className="w-4 h-4" />
                  <div>
                    <p className="text-sm font-medium">{ruche.rucherNom || 'Rucher inconnu'}</p>
                    {ruche.rucherAdresse && (
                      <p className="text-xs text-gray-500">{ruche.rucherAdresse}</p>
                    )}
                  </div>
                </div>

                {/* Date d'installation */}
                <div className="flex items-center space-x-2 text-gray-600">
                  <Calendar className="w-4 h-4" />
                  <div>
                    <p className="text-sm">Installée le {formatDate(ruche.dateInstallation)}</p>
                    {ruche.dateCreation && (
                      <p className="text-xs text-gray-500">
                        Créée le {formatDate(ruche.dateCreation)}
                      </p>
                    )}
                  </div>
                </div>

                {/* Type de ruche si disponible */}
                {ruche.typeRuche && (
                  <div className="flex items-center space-x-2 text-gray-600">
                    <Home className="w-4 h-4" />
                    <p className="text-sm">Type: {ruche.typeRuche}</p>
                  </div>
                )}

                {/* Données capteurs si disponibles */}
                {(ruche.temperature || ruche.humidite || ruche.niveauBatterie) && (
                  <div className="mt-3 pt-3 border-t border-gray-200">
                    <div className="grid grid-cols-3 gap-2 text-xs">
                      {ruche.temperature && (
                        <div className="text-center">
                          <p className="text-gray-500">Temp.</p>
                          <p className="font-medium">{ruche.temperature.toFixed(1)}°C</p>
                        </div>
                      )}
                      {ruche.humidite && (
                        <div className="text-center">
                          <p className="text-gray-500">Hum.</p>
                          <p className="font-medium">{ruche.humidite.toFixed(0)}%</p>
                        </div>
                      )}
                      {ruche.niveauBatterie && (
                        <div className="text-center">
                          <p className="text-gray-500">Batt.</p>
                          <p className="font-medium">{ruche.niveauBatterie}%</p>
                        </div>
                      )}
                    </div>
                  </div>
                )}
              </div>

              {/* Actions */}
              <div className="px-4 py-3 bg-gray-50 border-t border-gray-200">
                <button className="w-full text-sm text-amber-600 hover:text-amber-700 font-medium flex items-center justify-center space-x-1">
                  <Activity size={16} />
                  <span>Voir les détails</span>
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal d'ajout */}
      <AjouterRucheModal
        isOpen={showAddModal}
        onClose={() => setShowAddModal(false)}
        onRucheAdded={loadRuches}
      />
    </div>
  );
};

export default RuchesList; 