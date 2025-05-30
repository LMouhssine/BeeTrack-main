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
  BookOpen
} from 'lucide-react';
import { RucheService, Ruche } from '../services/rucheService';

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

      {/* Carte principale */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
        {/* En-tête de la ruche */}
        <div className="p-6 border-b border-gray-200">
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

        {/* Informations principales */}
        <div className="p-6">
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

            {/* Données capteurs (si disponibles) */}
            <div className="space-y-4">
              <h3 className="text-lg font-semibold text-gray-900 flex items-center">
                <Activity className="w-5 h-5 mr-2 text-amber-600" />
                Capteurs
              </h3>
              {(ruche as any).temperature || (ruche as any).humidite || (ruche as any).niveauBatterie ? (
                <div className="space-y-3">
                  {(ruche as any).temperature && (
                    <div className="flex items-center space-x-3">
                      <Thermometer className="w-4 h-4 text-red-500" />
                      <div>
                        <p className="text-sm font-medium text-gray-700">Température</p>
                        <p className="text-gray-900">{(ruche as any).temperature.toFixed(1)}°C</p>
                      </div>
                    </div>
                  )}
                  {(ruche as any).humidite && (
                    <div className="flex items-center space-x-3">
                      <Droplets className="w-4 h-4 text-blue-500" />
                      <div>
                        <p className="text-sm font-medium text-gray-700">Humidité</p>
                        <p className="text-gray-900">{(ruche as any).humidite.toFixed(0)}%</p>
                      </div>
                    </div>
                  )}
                  {(ruche as any).niveauBatterie && (
                    <div className="flex items-center space-x-3">
                      <Battery className="w-4 h-4 text-green-500" />
                      <div>
                        <p className="text-sm font-medium text-gray-700">Niveau batterie</p>
                        <p className="text-gray-900">{(ruche as any).niveauBatterie}%</p>
                      </div>
                    </div>
                  )}
                </div>
              ) : (
                <div className="text-center py-8 text-gray-500">
                  <Activity className="w-8 h-8 mx-auto mb-2 text-gray-400" />
                  <p className="text-sm">Aucune donnée de capteur disponible</p>
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
      </div>

      {/* Actions supplémentaires */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Actions disponibles</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button className="flex items-center justify-center space-x-2 p-4 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
            <Activity size={20} className="text-amber-600" />
            <span>Voir l'historique</span>
          </button>
          <button className="flex items-center justify-center space-x-2 p-4 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
            <Thermometer size={20} className="text-blue-600" />
            <span>Données capteurs</span>
          </button>
          <button className="flex items-center justify-center space-x-2 p-4 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors">
            <BookOpen size={20} className="text-green-600" />
            <span>Ajouter une note</span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default RucheDetails; 