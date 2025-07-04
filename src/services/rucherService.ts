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
import { auth, db } from '../firebase-config';

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
   * Ajoute un nouveau rucher pour l'utilisateur connecté
   * Utilise automatiquement l'UID de l'utilisateur connecté
   */
  static async ajouterRucherUtilisateurConnecte(rucher: Omit<Rucher, 'id' | 'dateCreation' | 'nombreRuches' | 'actif' | 'idApiculteur'>): Promise<string> {
    // Vérifier que l'utilisateur est connecté
    const currentUser = auth.currentUser;
    if (!currentUser) {
      throw new Error('Aucun utilisateur connecté. Veuillez vous connecter pour ajouter un rucher.');
    }

    console.log('Ajout d\'un rucher pour l\'utilisateur:', currentUser.uid);

    try {
      const nouveauRucher = {
        ...rucher,
        idApiculteur: currentUser.uid,
        dateCreation: Timestamp.now(),
        nombreRuches: 0,
        actif: true
      };

      const docRef = await addDoc(collection(db, this.COLLECTION_NAME), nouveauRucher);
      console.log('Rucher ajouté avec succès, ID:', docRef.id);
      return docRef.id;
    } catch (error: any) {
      console.error('Erreur lors de l\'ajout du rucher:', error);
      
      if (error.code === 'permission-denied') {
        throw new Error('Permissions insuffisantes pour ajouter un rucher.');
      } else if (error.code === 'unavailable') {
        throw new Error('Service Firestore temporairement indisponible. Veuillez réessayer.');
      } else {
        throw new Error('Impossible d\'ajouter le rucher. Vérifiez votre connexion internet.');
      }
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

  /**
   * Récupère tous les ruchers de l'utilisateur actuellement connecté
   * Utilise automatiquement l'UID de l'utilisateur connecté via Firebase Auth
   * @returns Promise<Rucher[]> - Liste des ruchers triée par date de création (plus récent en premier)
   * @throws Error si l'utilisateur n'est pas connecté ou en cas d'erreur Firestore
   */
  static async obtenirRuchersUtilisateurConnecte(): Promise<Rucher[]> {
    // Vérifier que l'utilisateur est connecté
    const currentUser = auth.currentUser;
    if (!currentUser) {
      throw new Error('Aucun utilisateur connecté. Veuillez vous connecter pour accéder à vos ruchers.');
    }

    console.log('Récupération des ruchers pour l\'utilisateur:', currentUser.uid);

    try {
      // Requête Firestore avec filtres et tri
      const q = query(
        collection(db, this.COLLECTION_NAME),
        where('idApiculteur', '==', currentUser.uid),
        where('actif', '==', true),
        orderBy('dateCreation', 'desc') // Plus récent en premier
      );

      const querySnapshot = await getDocs(q);
      const ruchers: Rucher[] = [];

      querySnapshot.forEach((docSnapshot) => {
        const data = docSnapshot.data();
        ruchers.push({
          id: docSnapshot.id,
          nom: data.nom,
          adresse: data.adresse,
          description: data.description,
          idApiculteur: data.idApiculteur,
          dateCreation: data.dateCreation?.toDate(),
          nombreRuches: data.nombreRuches || 0,
          actif: data.actif ?? true
        });
      });

      console.log(`${ruchers.length} rucher(s) récupéré(s) avec succès`);
      return ruchers;

    } catch (error: any) {
      console.error('Erreur lors de la récupération des ruchers:', error);
      
      // Gestion spécifique des erreurs Firestore
      if (error.code === 'failed-precondition') {
        throw new Error('Index Firestore manquant. Veuillez créer un index composite pour la collection "ruchers".');
      } else if (error.code === 'permission-denied') {
        throw new Error('Permissions insuffisantes pour accéder aux ruchers.');
      } else if (error.code === 'unavailable') {
        throw new Error('Service Firestore temporairement indisponible. Veuillez réessayer.');
      } else {
        throw new Error('Impossible de récupérer les ruchers. Vérifiez votre connexion internet.');
      }
    }
  }

  /**
   * Écoute en temps réel les ruchers de l'utilisateur connecté
   * @param callback - Fonction appelée à chaque changement avec la liste mise à jour
   * @returns Fonction pour arrêter l'écoute
   * @throws Error si l'utilisateur n'est pas connecté
   */
  static ecouterRuchersUtilisateurConnecte(
    callback: (ruchers: Rucher[]) => void
  ): () => void {
    // Vérifier que l'utilisateur est connecté
    const currentUser = auth.currentUser;
    if (!currentUser) {
      throw new Error('Aucun utilisateur connecté. Veuillez vous connecter pour écouter vos ruchers.');
    }

    console.log('Démarrage de l\'écoute temps réel pour l\'utilisateur:', currentUser.uid);

    const q = query(
      collection(db, this.COLLECTION_NAME),
      where('idApiculteur', '==', currentUser.uid),
      where('actif', '==', true),
      orderBy('dateCreation', 'desc')
    );

    return onSnapshot(q, 
      (querySnapshot) => {
        const ruchers: Rucher[] = [];
        querySnapshot.forEach((docSnapshot) => {
          const data = docSnapshot.data();
          ruchers.push({
            id: docSnapshot.id,
            nom: data.nom,
            adresse: data.adresse,
            description: data.description,
            idApiculteur: data.idApiculteur,
            dateCreation: data.dateCreation?.toDate(),
            nombreRuches: data.nombreRuches || 0,
            actif: data.actif ?? true
          });
        });
        
        console.log(`Mise à jour temps réel: ${ruchers.length} rucher(s)`);
        callback(ruchers);
      },
      (error) => {
        console.error('Erreur lors de l\'écoute des ruchers:', error);
        // Appeler le callback avec une liste vide en cas d'erreur
        callback([]);
      }
    );
  }
} 