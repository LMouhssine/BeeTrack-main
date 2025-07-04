import { useState, useEffect } from 'react';
import { RucherService, Rucher } from '../services/rucherService';

/**
 * Hook personnalisé pour gérer les ruchers de l'utilisateur connecté
 * Fournit une écoute en temps réel des changements
 */
export const useRuchers = () => {
  const [ruchers, setRuchers] = useState<Rucher[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string>('');

  useEffect(() => {
    let unsubscribe: (() => void) | null = null;

    const setupRealTimeListener = () => {
      try {
        console.log('Configuration de l\'écoute temps réel des ruchers...');
        
        // Démarrer l'écoute en temps réel
        unsubscribe = RucherService.ecouterRuchersUtilisateurConnecte((ruchersData) => {
          setRuchers(ruchersData);
          setLoading(false);
          setError('');
          console.log(`Mise à jour temps réel: ${ruchersData.length} rucher(s) reçu(s)`);
        });

      } catch (err: any) {
        console.error('Erreur lors de la configuration de l\'écoute:', err);
        setError(err.message || 'Impossible de configurer l\'écoute des ruchers');
        setLoading(false);
      }
    };

    setupRealTimeListener();

    // Nettoyage lors du démontage du composant
    return () => {
      if (unsubscribe) {
        console.log('Arrêt de l\'écoute temps réel des ruchers');
        unsubscribe();
      }
    };
  }, []);

  /**
   * Recharge manuellement les ruchers (utile après une action)
   */
  const rechargerRuchers = async () => {
    try {
      setLoading(true);
      setError('');
      const ruchersData = await RucherService.obtenirRuchersUtilisateurConnecte();
      setRuchers(ruchersData);
      console.log(`Rechargement manuel: ${ruchersData.length} rucher(s) récupéré(s)`);
    } catch (err: any) {
      console.error('Erreur lors du rechargement:', err);
      setError(err.message || 'Impossible de recharger les ruchers');
    } finally {
      setLoading(false);
    }
  };

  /**
   * Ajoute un nouveau rucher
   */
  const ajouterRucher = async (rucher: Omit<Rucher, 'id' | 'dateCreation' | 'nombreRuches' | 'actif' | 'idApiculteur'>) => {
    try {
      setError('');
      const id = await RucherService.ajouterRucherUtilisateurConnecte(rucher);
      console.log('Rucher ajouté avec succès, ID:', id);
      // Pas besoin de recharger, l'écoute temps réel se chargera de la mise à jour
      return id;
    } catch (err: any) {
      console.error('Erreur lors de l\'ajout:', err);
      setError(err.message || 'Impossible d\'ajouter le rucher');
      throw err;
    }
  };

  /**
   * Supprime un rucher
   */
  const supprimerRucher = async (id: string) => {
    try {
      setError('');
      await RucherService.supprimerRucher(id);
      console.log('Rucher supprimé avec succès, ID:', id);
      // Pas besoin de recharger, l'écoute temps réel se chargera de la mise à jour
    } catch (err: any) {
      console.error('Erreur lors de la suppression:', err);
      setError(err.message || 'Impossible de supprimer le rucher');
      throw err;
    }
  };

  /**
   * Met à jour un rucher
   */
  const mettreAJourRucher = async (id: string, rucher: Partial<Rucher>) => {
    try {
      setError('');
      await RucherService.mettreAJourRucher(id, rucher);
      console.log('Rucher mis à jour avec succès, ID:', id);
      // Pas besoin de recharger, l'écoute temps réel se chargera de la mise à jour
    } catch (err: any) {
      console.error('Erreur lors de la mise à jour:', err);
      setError(err.message || 'Impossible de mettre à jour le rucher');
      throw err;
    }
  };

  return {
    ruchers,
    loading,
    error,
    rechargerRuchers,
    ajouterRucher,
    supprimerRucher,
    mettreAJourRucher,
    clearError: () => setError('')
  };
}; 