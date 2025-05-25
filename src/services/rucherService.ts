import { 
  collection, 
  addDoc, 
  getDocs, 
  doc, 
  getDoc, 
  updateDoc, 
  deleteDoc, 
  query, 
  where, 
  orderBy, 
  onSnapshot,
  Timestamp 
} from 'firebase/firestore';
import { db } from '../firebase-config';

export interface Rucher {
  id?: string;
  nom: string;
  adresse: string;
  description: string;
  idApiculteur: string;
  dateCreation?: Date;
  nombreRuches?: number;
  actif?: boolean;
}

export class RucherService {
  private static readonly COLLECTION_NAME = 'ruchers';

  /**
   * Ajoute un nouveau rucher
   */
  static async ajouterRucher(rucher: Omit<Rucher, 'id' | 'dateCreation' | 'nombreRuches' | 'actif'>): Promise<string> {
    try {
      const nouveauRucher = {
        ...rucher,
        dateCreation: Timestamp.now(),
        nombreRuches: 0,
        actif: true
      };

      const docRef = await addDoc(collection(db, this.COLLECTION_NAME), nouveauRucher);
      console.log('Rucher ajouté avec succès, ID:', docRef.id);
      return docRef.id;
    } catch (error) {
      console.error('Erreur lors de l\'ajout du rucher:', error);
      throw new Error('Impossible d\'ajouter le rucher. Vérifiez votre connexion.');
    }
  }

  /**
   * Récupère tous les ruchers d'un apiculteur
   */
  static async obtenirRuchersUtilisateur(idApiculteur: string): Promise<Rucher[]> {
    try {
      const q = query(
        collection(db, this.COLLECTION_NAME),
        where('idApiculteur', '==', idApiculteur),
        where('actif', '==', true),
        orderBy('dateCreation', 'desc')
      );

      const querySnapshot = await getDocs(q);
      const ruchers: Rucher[] = [];

      querySnapshot.forEach((doc) => {
        const data = doc.data();
        ruchers.push({
          id: doc.id,
          nom: data.nom,
          adresse: data.adresse,
          description: data.description,
          idApiculteur: data.idApiculteur,
          dateCreation: data.dateCreation?.toDate(),
          nombreRuches: data.nombreRuches || 0,
          actif: data.actif ?? true
        });
      });

      return ruchers;
    } catch (error) {
      console.error('Erreur lors de la récupération des ruchers:', error);
      throw new Error('Impossible de récupérer les ruchers. Vérifiez votre connexion.');
    }
  }

  /**
   * Récupère un rucher par son ID
   */
  static async obtenirRucherParId(id: string): Promise<Rucher | null> {
    try {
      const docRef = doc(db, this.COLLECTION_NAME, id);
      const docSnap = await getDoc(docRef);

      if (docSnap.exists()) {
        const data = docSnap.data();
        return {
          id: docSnap.id,
          nom: data.nom,
          adresse: data.adresse,
          description: data.description,
          idApiculteur: data.idApiculteur,
          dateCreation: data.dateCreation?.toDate(),
          nombreRuches: data.nombreRuches || 0,
          actif: data.actif ?? true
        };
      }

      return null;
    } catch (error) {
      console.error('Erreur lors de la récupération du rucher:', error);
      throw new Error('Impossible de récupérer le rucher.');
    }
  }

  /**
   * Met à jour un rucher
   */
  static async mettreAJourRucher(id: string, rucher: Partial<Rucher>): Promise<void> {
    try {
      const docRef = doc(db, this.COLLECTION_NAME, id);
      const updateData = { ...rucher };
      
      // Supprimer l'ID des données à mettre à jour
      delete updateData.id;
      delete updateData.dateCreation; // Ne pas modifier la date de création

      await updateDoc(docRef, updateData);
      console.log('Rucher mis à jour avec succès');
    } catch (error) {
      console.error('Erreur lors de la mise à jour du rucher:', error);
      throw new Error('Impossible de mettre à jour le rucher.');
    }
  }

  /**
   * Supprime un rucher (suppression logique)
   */
  static async supprimerRucher(id: string): Promise<void> {
    try {
      const docRef = doc(db, this.COLLECTION_NAME, id);
      await updateDoc(docRef, { actif: false });
      console.log('Rucher supprimé avec succès');
    } catch (error) {
      console.error('Erreur lors de la suppression du rucher:', error);
      throw new Error('Impossible de supprimer le rucher.');
    }
  }

  /**
   * Écoute les changements des ruchers d'un utilisateur en temps réel
   */
  static ecouterRuchersUtilisateur(
    idApiculteur: string, 
    callback: (ruchers: Rucher[]) => void
  ): () => void {
    const q = query(
      collection(db, this.COLLECTION_NAME),
      where('idApiculteur', '==', idApiculteur),
      where('actif', '==', true),
      orderBy('dateCreation', 'desc')
    );

    return onSnapshot(q, (querySnapshot) => {
      const ruchers: Rucher[] = [];
      querySnapshot.forEach((doc) => {
        const data = doc.data();
        ruchers.push({
          id: doc.id,
          nom: data.nom,
          adresse: data.adresse,
          description: data.description,
          idApiculteur: data.idApiculteur,
          dateCreation: data.dateCreation?.toDate(),
          nombreRuches: data.nombreRuches || 0,
          actif: data.actif ?? true
        });
      });
      callback(ruchers);
    }, (error) => {
      console.error('Erreur lors de l\'écoute des ruchers:', error);
    });
  }
} 