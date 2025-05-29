import React, { useState, useEffect } from 'react';
import { X, MapPin, Calendar, Home, AlertTriangle, CheckCircle, Loader } from 'lucide-react';
import { RucheService } from '../services/rucheService';
import { RucherService, Rucher } from '../services/rucherService';

interface AjouterRucheModalProps {
  isOpen: boolean;
  onClose: () => void;
  onRucheAdded: () => void;
  rucherPreselectionne?: string;
}

const AjouterRucheModal: React.FC<AjouterRucheModalProps> = ({
  isOpen,
  onClose,
  onRucheAdded,
  rucherPreselectionne
}) => {
  const [formData, setFormData] = useState({
    nom: '',
    position: '',
    idRucher: rucherPreselectionne || '',
    enService: true,
    dateInstallation: new Date().toISOString().split('T')[0], // Format YYYY-MM-DD
    typeRuche: '',
    description: ''
  });

  const [ruchers, setRuchers] = useState<Rucher[]>([]);
  const [loading, setLoading] = useState(false);
  const [ruchersLoading, setRuchersLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  // Charger les ruchers au montage du composant
  useEffect(() => {
    if (isOpen) {
      loadRuchers();
      // Réinitialiser le formulaire
      setFormData({
        nom: '',
        position: '',
        idRucher: rucherPreselectionne || '',
        enService: true,
        dateInstallation: new Date().toISOString().split('T')[0],
        typeRuche: '',
        description: ''
      });
      setError('');
      setSuccess('');
    }
  }, [isOpen, rucherPreselectionne]);

  const loadRuchers = async () => {
    setRuchersLoading(true);
    try {
      const ruchersData = await RucherService.obtenirRuchersUtilisateurConnecte();
      setRuchers(ruchersData);
    } catch (error: any) {
      console.error('Erreur lors du chargement des ruchers:', error);
      setError('Impossible de charger les ruchers: ' + error.message);
    } finally {
      setRuchersLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess('');

    // Validation côté client
    if (!formData.nom.trim()) {
      setError('Le nom de la ruche est requis');
      setLoading(false);
      return;
    }

    if (!formData.position.trim()) {
      setError('La position est requise');
      setLoading(false);
      return;
    }

    if (!formData.idRucher) {
      setError('Veuillez sélectionner un rucher');
      setLoading(false);
      return;
    }

    try {
      // Créer la requête pour RucheService
      const rucheData = {
        nom: formData.nom.trim(),
        position: formData.position.trim(),
        idRucher: formData.idRucher,
        enService: formData.enService,
        dateInstallation: new Date(formData.dateInstallation)
      };

      const nouvelleRucheId = await RucheService.ajouterRuche(rucheData);
      console.log('🐝 Ruche créée avec succès, ID:', nouvelleRucheId);

      setSuccess(`Ruche "${formData.nom}" créée avec succès !`);
      
      // Attendre un peu pour que l'utilisateur voie le message
      setTimeout(() => {
        onRucheAdded();
        onClose();
      }, 1500);

    } catch (error: any) {
      console.error('Erreur lors de l\'ajout de la ruche:', error);
      setError(error.message || 'Erreur lors de l\'ajout de la ruche');
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value, type } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? (e.target as HTMLInputElement).checked : value
    }));
  };

  const selectedRucher = ruchers.find(r => r.id === formData.idRucher);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex items-center justify-center min-h-screen px-4 pt-4 pb-20 text-center sm:block sm:p-0">
        {/* Overlay */}
        <div className="fixed inset-0 transition-opacity bg-gray-500 bg-opacity-75" onClick={onClose}></div>

        {/* Modal */}
        <div className="inline-block w-full max-w-2xl p-6 my-8 overflow-hidden text-left align-middle transition-all transform bg-white shadow-xl rounded-lg">
          {/* Header */}
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center space-x-3">
              <div className="p-2 bg-amber-100 rounded-lg">
                <Home className="w-6 h-6 text-amber-600" />
              </div>
              <div>
                <h3 className="text-lg font-semibold text-gray-900">Ajouter une ruche</h3>
                <p className="text-sm text-gray-500">Créer une nouvelle ruche dans votre rucher</p>
              </div>
            </div>
            <button
              onClick={onClose}
              className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          {/* Messages */}
          {error && (
            <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg flex items-center space-x-2">
              <AlertTriangle className="w-5 h-5 text-red-500 flex-shrink-0" />
              <span className="text-sm text-red-700">{error}</span>
            </div>
          )}

          {success && (
            <div className="mb-4 p-3 bg-green-50 border border-green-200 rounded-lg flex items-center space-x-2">
              <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0" />
              <span className="text-sm text-green-700">{success}</span>
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Sélection du rucher */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Rucher de destination *
              </label>
              {ruchersLoading ? (
                <div className="flex items-center space-x-2 p-3 border border-gray-300 rounded-lg">
                  <Loader className="w-4 h-4 animate-spin text-gray-400" />
                  <span className="text-sm text-gray-500">Chargement des ruchers...</span>
                </div>
              ) : (
                <>
                  <select
                    name="idRucher"
                    value={formData.idRucher}
                    onChange={handleInputChange}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                    required
                  >
                    <option value="">Choisir un rucher...</option>
                    {ruchers.map(rucher => (
                      <option key={rucher.id} value={rucher.id}>
                        {rucher.nom}
                      </option>
                    ))}
                  </select>
                  
                  {selectedRucher && (
                    <div className="mt-2 p-3 bg-green-50 border border-green-200 rounded-lg">
                      <div className="flex items-center space-x-2 mb-1">
                        <CheckCircle className="w-4 h-4 text-green-500" />
                        <span className="text-sm font-medium text-green-700">Rucher sélectionné</span>
                      </div>
                      <p className="text-sm font-semibold text-gray-900">{selectedRucher.nom}</p>
                      {selectedRucher.adresse && (
                        <p className="text-xs text-gray-600">{selectedRucher.adresse}</p>
                      )}
                    </div>
                  )}
                </>
              )}
            </div>

            {/* Informations de la ruche */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Nom de la ruche *
                </label>
                <input
                  type="text"
                  name="nom"
                  value={formData.nom}
                  onChange={handleInputChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                  placeholder="Ex: Ruche A1, Ruche du Printemps..."
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Position dans le rucher *
                </label>
                <input
                  type="text"
                  name="position"
                  value={formData.position}
                  onChange={handleInputChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                  placeholder="Ex: A1, B2, Rangée 1-Position 3..."
                  required
                />
              </div>
            </div>

            {/* Informations complémentaires */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Type de ruche
                </label>
                <select
                  name="typeRuche"
                  value={formData.typeRuche}
                  onChange={handleInputChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                >
                  <option value="">Sélectionner un type...</option>
                  <option value="Dadant">Dadant</option>
                  <option value="Langstroth">Langstroth</option>
                  <option value="Warré">Warré</option>
                  <option value="Voirnot">Voirnot</option>
                  <option value="Autre">Autre</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  <Calendar className="inline w-4 h-4 mr-1" />
                  Date d'installation
                </label>
                <input
                  type="date"
                  name="dateInstallation"
                  value={formData.dateInstallation}
                  onChange={handleInputChange}
                  max={new Date().toISOString().split('T')[0]}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                />
              </div>
            </div>

            {/* Description */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Description (optionnelle)
              </label>
              <textarea
                name="description"
                value={formData.description}
                onChange={handleInputChange}
                rows={3}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-amber-500 focus:border-transparent"
                placeholder="Informations complémentaires sur la ruche..."
              />
            </div>

            {/* Configuration */}
            <div className="space-y-4">
              <h4 className="text-sm font-medium text-gray-900">Configuration</h4>
              
              {/* Statut en service */}
              <div className="flex items-center justify-between p-3 border border-gray-200 rounded-lg">
                <div className="flex items-center space-x-3">
                  <div className={`p-2 rounded-lg ${formData.enService ? 'bg-green-100' : 'bg-yellow-100'}`}>
                    <CheckCircle className={`w-5 h-5 ${formData.enService ? 'text-green-600' : 'text-yellow-600'}`} />
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-900">Ruche en service</p>
                    <p className="text-xs text-gray-500">
                      {formData.enService ? 'La ruche est opérationnelle' : 'La ruche est hors service'}
                    </p>
                  </div>
                </div>
                <label className="relative inline-flex items-center cursor-pointer">
                  <input
                    type="checkbox"
                    name="enService"
                    checked={formData.enService}
                    onChange={handleInputChange}
                    className="sr-only peer"
                  />
                  <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-amber-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-amber-600"></div>
                </label>
              </div>
            </div>

            {/* Boutons d'action */}
            <div className="flex items-center justify-end space-x-3 pt-4 border-t border-gray-200">
              <button
                type="button"
                onClick={onClose}
                disabled={loading}
                className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-amber-500 disabled:opacity-50"
              >
                Annuler
              </button>
              <button
                type="submit"
                disabled={loading || ruchersLoading}
                className="px-6 py-2 text-sm font-medium text-white bg-amber-600 rounded-lg hover:bg-amber-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-amber-500 disabled:opacity-50 flex items-center space-x-2"
              >
                {loading ? (
                  <>
                    <Loader className="w-4 h-4 animate-spin" />
                    <span>Création...</span>
                  </>
                ) : (
                  <>
                    <Home className="w-4 h-4" />
                    <span>Créer la ruche</span>
                  </>
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default AjouterRucheModal; 