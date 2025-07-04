import React, { useState, useEffect } from 'react';
import { 
  ArrowLeft, 
  Home, 
  MapPin, 
  Calendar, 
  Activity, 
  CheckCircle, 
  AlertTriangle, 
  Edit3, 
  Trash2,
  User,
  Clock,
  Thermometer,
  Droplets,
  Battery,
  BookOpen,
  BarChart3,
  Signal,
  RefreshCw,
  Eye
} from 'lucide-react';
import { RucheService, Ruche, DonneesCapteur } from '../services/rucheService';
import MesuresRuche from './MesuresRuche';
import SurveillanceCouvercle from './SurveillanceCouvercle';

interface RucheDetailsProps {
  rucheId: string;
  onBack: () => void;
  onEdit?: (ruche: Ruche) => void;
  onDelete?: (rucheId: string) => void;
}

const RucheDetails: React.FC<RucheDetailsProps> = ({ rucheId, onBack, onEdit, onDelete }) => {
  const [ruche, setRuche] = useState<Ruche | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [activeTab, setActiveTab] = useState<'details' | 'mesures' | 'surveillance'>('details');
  const [derniereMesure, setDerniereMesure] = useState<DonneesCapteur | null>(null);
  const [loadingCapteurs, setLoadingCapteurs] = useState(false);

  useEffect(() => {
    loadRucheDetails();
  }, [rucheId]);

  const loadRucheDetails = async () => {
    try {
      setLoading(true);
      setError('');
      
      const rucheData = await RucheService.obtenirRucheParId(rucheId);
      if (rucheData) {
        setRuche(rucheData);
        // Charger aussi les données de capteurs
        await loadDerniereMesure();
      } else {
        setError('Ruche non trouvée');
      }
    } catch (error: any) {
      console.error('Erreur lors du chargement des détails:', error);
      setError('Erreur lors du chargement des détails: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  const loadDerniereMesure = async () => {
    try {
      setLoadingCapteurs(true);
      console.log('🔍 Chargement de la dernière mesure pour la ruche:', rucheId);
      
      // Récupérer les mesures des 7 derniers jours et prendre la plus récente
              const mesures = await RucheService.obtenirMesures7DerniersJours(rucheId);
      
      if (mesures.length > 0) {
        // Trier par timestamp décroissant et prendre la plus récente
        const mesuresTriees = mesures.sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime());
        setDerniereMesure(mesuresTriees[0]);
        console.log('✅ Dernière mesure chargée:', mesuresTriees[0]);
      } else {
        setDerniereMesure(null);
        console.log('⚠️ Aucune mesure trouvée');
      }
    } catch (error: any) {
      console.error('❌ Erreur lors du chargement des capteurs:', error);
      setDerniereMesure(null);
    } finally {
      setLoadingCapteurs(false);
    }
  };

  const formatDate = (date: Date | string) => {
    const d = typeof date === 'string' ? new Date(date) : date;
    return new Intl.DateTimeFormat('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    }).format(d);
  };

  const formatDateOnly = (date: Date | string) => {
    const d = typeof date === 'string' ? new Date(date) : date;
    return new Intl.DateTimeFormat('fr-FR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    }).format(d);
  };

  const handleDelete = async () => {
    if (!ruche) return;
    
    const confirmDelete = window.confirm(
      `Êtes-vous sûr de vouloir supprimer la ruche "${ruche.nom}" ?\n\nCette action est irréversible.`
    );
    
    if (confirmDelete && onDelete) {
      onDelete(ruche.id!);
    }
  };

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="flex items-center space-x-4">
          <button
            onClick={onBack}
            className="flex items-center space-x-2 text-amber-600 hover:text-amber-700"
          >
            <ArrowLeft size={20} />
            <span>Retour</span>
          </button>
        </div>
        
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-amber-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Chargement des détails...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-6">
        <div className="flex items-center space-x-4">
          <button
            onClick={onBack}
            className="flex items-center space-x-2 text-amber-600 hover:text-amber-700"
          >
            <ArrowLeft size={20} />
            <span>Retour</span>
          </button>
        </div>
        
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
          <AlertTriangle className="w-12 h-12 text-red-500 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-red-900 mb-2">Erreur</h3>
          <p className="text-red-700">{error}</p>
          <button
            onClick={loadRucheDetails}
            className="mt-4 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
          >
            Réessayer
          </button>
        </div>
      </div>
    );
  }

  if (!ruche) {
    return (
      <div className="space-y-6">
        <div className="flex items-center space-x-4">
          <button
            onClick={onBack}
            className="flex items-center space-x-2 text-amber-600 hover:text-amber-700"
          >
            <ArrowLeft size={20} />
            <span>Retour</span>
          </button>
        </div>
        
        <div className="text-center py-12">
          <Home className="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Ruche non trouvée</h3>
          <p className="text-gray-600">Cette ruche n'existe pas ou vous n'avez pas l'autorisation de la voir.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* En-tête avec navigation */}
      <div className="flex items-center justify-between">
        <button
          onClick={onBack}
          className="flex items-center space-x-2 text-amber-600 hover:text-amber-700 transition-colors"
        >
          <ArrowLeft size={20} />
          <span>Retour à la liste</span>
        </button>
        
        <div className="flex items-center space-x-2">
          {onEdit && (
            <button
              onClick={() => onEdit(ruche)}
              className="flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              <Edit3 size={16} />
              <span>Modifier</span>
            </button>
          )}
          {onDelete && (
            <button
              onClick={handleDelete}
              className="flex items-center space-x-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >
              <Trash2 size={16} />
              <span>Supprimer</span>
            </button>
          )}
        </div>
      </div>

      {/* En-tête de la ruche */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="flex items-center space-x-4">
          <div className={`p-3 rounded-lg ${ruche.enService ? 'bg-green-100' : 'bg-yellow-100'}`}>
            <Home className={`w-8 h-8 ${ruche.enService ? 'text-green-600' : 'text-yellow-600'}`} />
          </div>
          <div className="flex-1">
            <h1 className="text-2xl font-bold text-gray-900">{ruche.nom}</h1>
            <div className="flex items-center space-x-4 mt-2">
              <div className="flex items-center space-x-2">
                {ruche.enService ? (
                  <>
                    <CheckCircle className="w-5 h-5 text-green-500" />
                    <span className="text-green-700 font-medium">En service</span>
                  </>
                ) : (
                  <>
                    <AlertTriangle className="w-5 h-5 text-yellow-500" />
                    <span className="text-yellow-700 font-medium">Hors service</span>
                  </>
                )}
              </div>
              <div className="flex items-center space-x-2 text-gray-600">
                <MapPin className="w-4 h-4" />
                <span>Position: {ruche.position}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Onglets */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        <div className="border-b border-gray-200">
          <nav className="flex space-x-8 px-6">
            <button
              onClick={() => setActiveTab('details')}
              className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                activeTab === 'details'
                  ? 'border-amber-500 text-amber-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <div className="flex items-center space-x-2">
                <Home size={16} />
                <span>Détails</span>
              </div>
            </button>
            <button
              onClick={() => setActiveTab('mesures')}
              className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                activeTab === 'mesures'
                  ? 'border-amber-500 text-amber-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <div className="flex items-center space-x-2">
                <BarChart3 size={16} />
                <span>Mesures</span>
              </div>
            </button>
            <button
              onClick={() => setActiveTab('surveillance')}
              className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors ${
                activeTab === 'surveillance'
                  ? 'border-amber-500 text-amber-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <div className="flex items-center space-x-2">
                <Eye size={16} />
                <span>Surveillance</span>
              </div>
            </button>
          </nav>
        </div>

        {/* Contenu des onglets */}
        <div className="p-6">
          {activeTab === 'details' && (
            <div className="space-y-6">
              {/* Informations principales */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {/* Dates importantes */}
                <div className="space-y-4">
                  <h3 className="text-lg font-semibold text-gray-900 flex items-center">
                    <Calendar className="w-5 h-5 mr-2 text-amber-600" />
                    Dates importantes
                  </h3>
                  <div className="space-y-3">
                    <div>
                      <p className="text-sm font-medium text-gray-700">Date d'installation</p>
                      <p className="text-gray-900">{formatDateOnly(ruche.dateInstallation)}</p>
                    </div>
                    {ruche.dateCreation && (
                      <div>
                        <p className="text-sm font-medium text-gray-700">Date de création</p>
                        <p className="text-gray-600">{formatDate(ruche.dateCreation)}</p>
                      </div>
                    )}
                    {ruche.dateMiseAJour && (
                      <div>
                        <p className="text-sm font-medium text-gray-700">Dernière modification</p>
                        <p className="text-gray-600">{formatDate(ruche.dateMiseAJour)}</p>
                      </div>
                    )}
                  </div>
                </div>

                {/* Informations techniques */}
                <div className="space-y-4">
                  <h3 className="text-lg font-semibold text-gray-900 flex items-center">
                    <Activity className="w-5 h-5 mr-2 text-amber-600" />
                    Informations techniques
                  </h3>
                  <div className="space-y-3">
                    <div>
                      <p className="text-sm font-medium text-gray-700">Identifiant</p>
                      <p className="text-gray-900 font-mono text-sm">{ruche.id}</p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-700">Rucher</p>
                      <p className="text-gray-900">{ruche.idRucher}</p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-700">Propriétaire</p>
                      <p className="text-gray-900 font-mono text-sm">{ruche.idApiculteur}</p>
                    </div>
                    {ruche.typeRuche && (
                      <div>
                        <p className="text-sm font-medium text-gray-700">Type de ruche</p>
                        <p className="text-gray-900">{ruche.typeRuche}</p>
                      </div>
                    )}
                    {ruche.nombreCadres && (
                      <div>
                        <p className="text-sm font-medium text-gray-700">Nombre de cadres</p>
                        <p className="text-gray-900">{ruche.nombreCadres}</p>
                      </div>
                    )}
                  </div>
                </div>

                {/* Données capteurs */}
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <h3 className="text-lg font-semibold text-gray-900 flex items-center">
                      <Activity className="w-5 h-5 mr-2 text-amber-600" />
                      Capteurs
                    </h3>
                    <button
                      onClick={loadDerniereMesure}
                      disabled={loadingCapteurs}
                      className="flex items-center space-x-1 px-3 py-1 text-sm bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors disabled:opacity-50"
                    >
                      <RefreshCw size={14} className={loadingCapteurs ? 'animate-spin' : ''} />
                      <span>Actualiser</span>
                    </button>
                  </div>
                  
                  {loadingCapteurs ? (
                    <div className="text-center py-8">
                      <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-amber-600 mx-auto mb-2"></div>
                      <p className="text-sm text-gray-500">Chargement des capteurs...</p>
                    </div>
                  ) : derniereMesure ? (
                    <div className="space-y-4">
                      <div className="text-xs text-gray-500 mb-3">
                        Dernière mesure: {new Intl.DateTimeFormat('fr-FR', {
                          day: '2-digit',
                          month: '2-digit',
                          hour: '2-digit',
                          minute: '2-digit'
                        }).format(derniereMesure.timestamp)}
                      </div>
                      
                      <div className="grid grid-cols-2 gap-4">
                        {/* Température */}
                        {derniereMesure.temperature !== null && derniereMesure.temperature !== undefined && (
                          <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
                            <div className="flex items-center space-x-2 mb-1">
                              <Thermometer className="w-4 h-4 text-blue-600" />
                              <p className="text-sm font-medium text-blue-700">Température</p>
                            </div>
                            <p className="text-lg font-bold text-blue-900">
                              {derniereMesure.temperature.toFixed(1)}°C
                            </p>
                          </div>
                        )}

                        {/* Humidité */}
                        {derniereMesure.humidity !== null && derniereMesure.humidity !== undefined && (
                          <div className="bg-green-50 border border-green-200 rounded-lg p-3">
                            <div className="flex items-center space-x-2 mb-1">
                              <Droplets className="w-4 h-4 text-green-600" />
                              <p className="text-sm font-medium text-green-700">Humidité</p>
                            </div>
                            <p className="text-lg font-bold text-green-900">
                              {derniereMesure.humidity.toFixed(0)}%
                            </p>
                          </div>
                        )}

                        {/* Batterie */}
                        {derniereMesure.batterie !== null && derniereMesure.batterie !== undefined && (
                          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-3">
                            <div className="flex items-center space-x-2 mb-1">
                              <Battery className={`w-4 h-4 ${
                                derniereMesure.batterie > 50 ? 'text-green-600' : 
                                derniereMesure.batterie > 20 ? 'text-yellow-600' : 'text-red-600'
                              }`} />
                              <p className="text-sm font-medium text-yellow-700">Batterie</p>
                            </div>
                            <p className={`text-lg font-bold ${
                              derniereMesure.batterie > 50 ? 'text-green-900' : 
                              derniereMesure.batterie > 20 ? 'text-yellow-900' : 'text-red-900'
                            }`}>
                              {derniereMesure.batterie}%
                            </p>
                          </div>
                        )}

                        {/* Signal */}
                        {derniereMesure.signalQualite !== null && derniereMesure.signalQualite !== undefined && (
                          <div className="bg-purple-50 border border-purple-200 rounded-lg p-3">
                            <div className="flex items-center space-x-2 mb-1">
                              <Signal className="w-4 h-4 text-purple-600" />
                              <p className="text-sm font-medium text-purple-700">Signal</p>
                            </div>
                            <p className="text-lg font-bold text-purple-900">
                              {derniereMesure.signalQualite}%
                            </p>
                          </div>
                        )}
                      </div>

                      {/* État du couvercle */}
                      {derniereMesure.couvercleOuvert !== null && derniereMesure.couvercleOuvert !== undefined && (
                        <div className="mt-4">
                          <div className={`flex items-center space-x-2 px-3 py-2 rounded-lg ${
                            derniereMesure.couvercleOuvert 
                              ? 'bg-red-50 border border-red-200' 
                              : 'bg-green-50 border border-green-200'
                          }`}>
                            <Activity className={`w-4 h-4 ${
                              derniereMesure.couvercleOuvert ? 'text-red-600' : 'text-green-600'
                            }`} />
                            <div>
                              <p className="text-sm font-medium text-gray-700">État du couvercle</p>
                              <p className={`text-sm font-bold ${
                                derniereMesure.couvercleOuvert ? 'text-red-700' : 'text-green-700'
                              }`}>
                                {derniereMesure.couvercleOuvert ? 'Ouvert' : 'Fermé'}
                              </p>
                            </div>
                          </div>
                        </div>
                      )}
                    </div>
                  ) : (
                    <div className="text-center py-8 text-gray-500">
                      <Activity className="w-8 h-8 mx-auto mb-2 text-gray-400" />
                      <p className="text-sm">Aucune donnée de capteur disponible</p>
                      <p className="text-xs text-gray-400 mt-1">
                        Créez des données de test dans l'onglet "Mesures"
                      </p>
                    </div>
                  )}
                </div>
              </div>

              {/* Notes (si disponibles) */}
              {ruche.notes && (
                <div className="mt-8 pt-6 border-t border-gray-200">
                  <h3 className="text-lg font-semibold text-gray-900 flex items-center mb-4">
                    <BookOpen className="w-5 h-5 mr-2 text-amber-600" />
                    Notes
                  </h3>
                  <div className="bg-gray-50 rounded-lg p-4">
                    <p className="text-gray-900 whitespace-pre-wrap">{ruche.notes}</p>
                  </div>
                </div>
              )}
            </div>
          )}

          {activeTab === 'mesures' && (
            <div className="-m-6">
              <MesuresRuche rucheId={ruche.id!} rucheNom={ruche.nom} />
            </div>
          )}

          {activeTab === 'surveillance' && (
            <div className="-m-6">
              <SurveillanceCouvercle 
                rucheId={ruche.id!} 
                rucheNom={ruche.nom}
                apiculteurId={ruche.idApiculteur}
              />
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default RucheDetails; 