import React, { useState } from 'react';
import { useRuchers } from '../hooks/useRuchers';
import { Plus, Home, MapPin, FileText, Calendar, Trash2, Edit, RefreshCw } from 'lucide-react';

const RuchersListV2: React.FC = () => {
  const { 
    ruchers, 
    loading, 
    error, 
    rechargerRuchers, 
    ajouterRucher, 
    supprimerRucher,
    clearError 
  } = useRuchers();
  
  const [showAddForm, setShowAddForm] = useState(false);

  const handleDeleteRucher = async (id: string, nom: string) => {
    if (window.confirm(`Êtes-vous sûr de vouloir supprimer le rucher "${nom}" ?`)) {
      try {
        await supprimerRucher(id);
        console.log('🐝 Rucher supprimé avec succès');
      } catch (error) {
        console.error('Erreur lors de la suppression:', error);
        // L'erreur est déjà gérée par le hook
      }
    }
  };

  const formatDate = (date: Date | undefined) => {
    if (!date) return 'Date inconnue';
    return date.toLocaleDateString('fr-FR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-amber-600"></div>
        <span className="ml-2 text-amber-800">Chargement des ruchers...</span>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div className="flex items-center space-x-2">
          <Home className="text-amber-600" size={24} />
          <h2 className="text-2xl font-bold text-gray-800">Mes Ruchers</h2>
          <span className="bg-amber-100 text-amber-800 text-sm px-2 py-1 rounded-full">
            Temps réel
          </span>
        </div>
        <div className="flex space-x-2">
          <button
            onClick={rechargerRuchers}
            className="flex items-center space-x-2 bg-gray-100 hover:bg-gray-200 text-gray-700 px-3 py-2 rounded-lg transition duration-200"
            title="Actualiser"
          >
            <RefreshCw size={16} />
          </button>
          <button
            onClick={() => setShowAddForm(true)}
            className="flex items-center space-x-2 bg-amber-600 hover:bg-amber-700 text-white px-4 py-2 rounded-lg transition duration-200"
          >
            <Plus size={20} />
            <span>Ajouter un Rucher</span>
          </button>
        </div>
      </div>

      {/* Messages d'erreur */}
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg flex justify-between items-center">
          <span>{error}</span>
          <button
            onClick={clearError}
            className="text-red-500 hover:text-red-700 ml-2"
          >
            ✕
          </button>
        </div>
      )}

      {/* Liste des ruchers */}
      {ruchers.length === 0 ? (
        <div className="text-center py-12 bg-white rounded-lg shadow-sm border border-gray-200">
          <Home className="mx-auto text-gray-400 mb-4" size={48} />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Aucun rucher trouvé</h3>
          <p className="text-gray-500 mb-4">Créez votre premier rucher pour commencer à gérer vos ruches</p>
          <button
            onClick={() => setShowAddForm(true)}
            className="inline-flex items-center space-x-2 bg-amber-600 hover:bg-amber-700 text-white px-4 py-2 rounded-lg transition duration-200"
          >
            <Plus size={20} />
            <span>Créer un rucher</span>
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {ruchers.map((rucher) => (
            <div key={rucher.id} className="bg-white rounded-lg shadow-sm border border-gray-200 hover:shadow-md transition duration-200">
              <div className="p-6">
                {/* Header de la carte */}
                <div className="flex justify-between items-start mb-4">
                  <h3 className="text-lg font-semibold text-gray-900 truncate">{rucher.nom}</h3>
                  <div className="flex space-x-1">
                    <button
                      onClick={() => {/* TODO: Implémenter l'édition */}}
                      className="p-1 text-gray-400 hover:text-amber-600 transition duration-200"
                      title="Modifier"
                    >
                      <Edit size={16} />
                    </button>
                    <button
                      onClick={() => handleDeleteRucher(rucher.id!, rucher.nom)}
                      className="p-1 text-gray-400 hover:text-red-600 transition duration-200"
                      title="Supprimer"
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                </div>

                {/* Informations du rucher */}
                <div className="space-y-3">
                  <div className="flex items-start space-x-2">
                    <MapPin className="text-gray-400 mt-0.5 flex-shrink-0" size={16} />
                    <span className="text-sm text-gray-600">{rucher.adresse}</span>
                  </div>
                  
                  <div className="flex items-start space-x-2">
                    <FileText className="text-gray-400 mt-0.5 flex-shrink-0" size={16} />
                    <span className="text-sm text-gray-600 line-clamp-2">{rucher.description}</span>
                  </div>
                </div>

                {/* Footer de la carte */}
                <div className="mt-4 pt-4 border-t border-gray-100 flex justify-between items-center text-sm text-gray-500">
                  <div className="flex items-center space-x-1">
                    <Home size={14} />
                    <span>{rucher.nombreRuches || 0} ruche(s)</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <Calendar size={14} />
                    <span>{formatDate(rucher.dateCreation)}</span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Formulaire d'ajout */}
      {showAddForm && (
        <AddRucherFormV2
          onClose={() => setShowAddForm(false)}
          onSuccess={() => {
            setShowAddForm(false);
            // Pas besoin de recharger, l'écoute temps réel se charge de la mise à jour
          }}
          ajouterRucher={ajouterRucher}
        />
      )}
    </div>
  );
};

// Composant pour le formulaire d'ajout amélioré
interface AddRucherFormV2Props {
  onClose: () => void;
  onSuccess: () => void;
  ajouterRucher: (rucher: { nom: string; adresse: string; description: string }) => Promise<string>;
}

const AddRucherFormV2: React.FC<AddRucherFormV2Props> = ({ onClose, onSuccess, ajouterRucher }) => {
  const [formData, setFormData] = useState({
    nom: '',
    adresse: '',
    description: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.nom.trim() || !formData.adresse.trim() || !formData.description.trim()) {
      setError('Veuillez remplir tous les champs');
      return;
    }

    try {
      setLoading(true);
      setError('');
      
      await ajouterRucher({
        nom: formData.nom.trim(),
        adresse: formData.adresse.trim(),
        description: formData.description.trim()
      });

      console.log('🐝 Rucher créé avec succès');
      onSuccess();
    } catch (error: any) {
      console.error('Erreur lors de la création du rucher:', error);
      setError(error.message || 'Erreur lors de la création du rucher');
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Ajouter un Rucher</h3>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600 transition duration-200"
            >
              ✕
            </button>
          </div>

          {error && (
            <div className="mb-4 bg-red-50 border border-red-200 text-red-700 px-3 py-2 rounded-lg text-sm">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label htmlFor="nom" className="block text-sm font-medium text-gray-700 mb-1">
                Nom du rucher *
              </label>
              <input
                type="text"
                id="nom"
                name="nom"
                value={formData.nom}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
                placeholder="Ex: Rucher des Tilleuls"
                required
              />
            </div>

            <div>
              <label htmlFor="adresse" className="block text-sm font-medium text-gray-700 mb-1">
                Adresse *
              </label>
              <input
                type="text"
                id="adresse"
                name="adresse"
                value={formData.adresse}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
                placeholder="Ex: 123 Rue des Abeilles, 75001 Paris"
                required
              />
            </div>

            <div>
              <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-1">
                Description *
              </label>
              <textarea
                id="description"
                name="description"
                value={formData.description}
                onChange={handleChange}
                rows={3}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500"
                placeholder="Décrivez votre rucher..."
                required
              />
            </div>

            <div className="flex space-x-3 pt-4">
              <button
                type="button"
                onClick={onClose}
                className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition duration-200"
              >
                Annuler
              </button>
              <button
                type="submit"
                disabled={loading}
                className="flex-1 px-4 py-2 bg-amber-600 text-white rounded-lg hover:bg-amber-700 disabled:opacity-50 disabled:cursor-not-allowed transition duration-200"
              >
                {loading ? 'Création...' : 'Créer'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default RuchersListV2; 