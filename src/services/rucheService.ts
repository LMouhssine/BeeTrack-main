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
  Timestamp,
  runTransaction,
  WriteBatch,
  writeBatch
} from 'firebase/firestore';
import { auth, db } from '../firebase-config';
import { DonneesCapteursService, DonneesCapteur } from './donneesCapteursService';

export interface Ruche {
  id?: string;
  idRucher: string;
  nom: string;
  position: string;
  enService: boolean;
  dateInstallation: Date;
  dateCreation?: Date;
  dateMiseAJour?: Date;
  idApiculteur: string;
  actif?: boolean;
  // Champs optionnels pour les extensions futures
  nombreCadres?: number;
  typeRuche?: string;
  notes?: string;
}

export interface RucheAvecRucher extends Ruche {
  rucherNom?: string;
  rucherAdresse?: string;
}



export class RucheService {
  private static readonly COLLECTION_NAME = 'ruches';
  private static readonly RUCHERS_COLLECTION = 'ruchers';

  /**
   * Ajoute une nouvelle ruche avec validation complète
   */
  static async ajouterRuche(rucheData: {
    idRucher: string;
    nom: string;
    position: string;
    enService?: boolean;
    dateInstallation?: Date;
  }): Promise<string> {
    const currentUser = auth.currentUser;
    if (!currentUser) {
      throw new Error('Aucun utilisateur connecté. Veuillez vous connecter pour ajouter une ruche.');
    }

    console.log('🐝 Ajout d\'une ruche pour l\'utilisateur:', currentUser.uid);

    try {
      // Utiliser une transaction pour assurer la cohérence
      const result = await runTransaction(db, async (transaction) => {
        // 1. Vérifier que le rucher existe et appartient à l'utilisateur
        const rucherRef = doc(db, this.RUCHERS_COLLECTION, rucheData.idRucher);
        const rucherDoc = await transaction.get(rucherRef);

        if (!rucherDoc.exists()) {
          throw new Error('Le rucher spécifié n\'existe pas.');
        }

        const rucherData = rucherDoc.data();
        if (rucherData.idApiculteur !== currentUser.uid) {
          throw new Error('Vous n\'avez pas les permissions pour ajouter une ruche à ce rucher.');
        }

        if (!rucherData.actif) {
          throw new Error('Impossible d\'ajouter une ruche à un rucher inactif.');
        }

        // 2. Vérifier l'unicité de la position dans le rucher
        const q = query(
          collection(db, this.COLLECTION_NAME),
          where('idRucher', '==', rucheData.idRucher),
          where('position', '==', rucheData.position.trim()),
          where('actif', '==', true)
        );
        const existingRuches = await getDocs(q);

        if (!existingRuches.empty) {
          throw new Error(`Une ruche existe déjà à la position "${rucheData.position}" dans ce rucher.`);
        }

        // 3. Vérifier l'unicité du nom dans le rucher
        const qNom = query(
          collection(db, this.COLLECTION_NAME),
          where('idRucher', '==', rucheData.idRucher),
          where('nom', '==', rucheData.nom.trim()),
          where('actif', '==', true)
        );
        const existingNoms = await getDocs(qNom);

        if (!existingNoms.empty) {
          throw new Error(`Une ruche avec le nom "${rucheData.nom}" existe déjà dans ce rucher.`);
        }

        // 4. Créer la nouvelle ruche
        const nouvelleRuche: Omit<Ruche, 'id'> = {
          idRucher: rucheData.idRucher,
          nom: rucheData.nom.trim(),
          position: rucheData.position.trim(),
          enService: rucheData.enService ?? true,
          dateInstallation: rucheData.dateInstallation || new Date(),
          dateCreation: new Date(),
          dateMiseAJour: new Date(),
          idApiculteur: currentUser.uid,
          actif: true
        };

        // 5. Ajouter la ruche
        const rucheRef = await addDoc(collection(db, this.COLLECTION_NAME), {
          ...nouvelleRuche,
          dateInstallation: Timestamp.fromDate(nouvelleRuche.dateInstallation),
          dateCreation: Timestamp.now(),
          dateMiseAJour: Timestamp.now()
        });

        // 6. Mettre à jour le nombre de ruches dans le rucher
        const currentNombreRuches = rucherData.nombreRuches || 0;
        transaction.update(rucherRef, {
          nombreRuches: currentNombreRuches + 1
        });

        return rucheRef.id;
      });

      console.log('🐝 Ruche ajoutée avec succès, ID:', result);
      return result;

    } catch (error: any) {
      console.error('Erreur lors de l\'ajout de la ruche:', error);
      
      if (error.code === 'permission-denied') {
        throw new Error('Permissions insuffisantes pour ajouter une ruche.');
      } else if (error.code === 'unavailable') {
        throw new Error('Service Firestore temporairement indisponible. Veuillez réessayer.');
      } else if (error.message) {
        throw error; // Relancer les erreurs de validation personnalisées
      } else {
        throw new Error('Impossible d\'ajouter la ruche. Vérifiez votre connexion internet.');
      }
    }
  }

  /**
   * Récupère toutes les ruches d'un rucher
   */
  static async obtenirRuchesParRucher(idRucher: string): Promise<Ruche[]> {
    try {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        throw new Error('Utilisateur non connecté');
      }

      const q = query(
        collection(db, this.COLLECTION_NAME),
        where('idRucher', '==', idRucher),
        where('idApiculteur', '==', currentUser.uid),
        where('actif', '==', true),
        orderBy('position')
      );

      const querySnapshot = await getDocs(q);
      const ruches: Ruche[] = [];

      querySnapshot.forEach((doc) => {
        const data = doc.data();
        ruches.push({
          id: doc.id,
          idRucher: data.idRucher,
          nom: data.nom,
          position: data.position,
          enService: data.enService,
          dateInstallation: data.dateInstallation?.toDate() || new Date(),
          dateCreation: data.dateCreation?.toDate(),
          dateMiseAJour: data.dateMiseAJour?.toDate(),
          idApiculteur: data.idApiculteur,
          actif: data.actif ?? true,
          nombreCadres: data.nombreCadres,
          typeRuche: data.typeRuche,
          notes: data.notes
        });
      });

      return ruches;
    } catch (error) {
      console.error('Erreur lors de la récupération des ruches:', error);
      throw new Error('Impossible de récupérer les ruches.');
    }
  }

  /**
   * Récupère toutes les ruches de l'utilisateur connecté
   */
  static async obtenirRuchesUtilisateur(): Promise<RucheAvecRucher[]> {
    try {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        throw new Error('Utilisateur non connecté');
      }

      const q = query(
        collection(db, this.COLLECTION_NAME),
        where('idApiculteur', '==', currentUser.uid),
        where('actif', '==', true),
        orderBy('dateCreation', 'desc')
      );

      const querySnapshot = await getDocs(q);
      const ruchesAvecRucher: RucheAvecRucher[] = [];

      // Récupérer les informations des ruchers
      for (const docSnapshot of querySnapshot.docs) {
        const data = docSnapshot.data();
        const ruche: RucheAvecRucher = {
          id: docSnapshot.id,
          idRucher: data.idRucher,
          nom: data.nom,
          position: data.position,
          enService: data.enService,
          dateInstallation: data.dateInstallation?.toDate() || new Date(),
          dateCreation: data.dateCreation?.toDate(),
          dateMiseAJour: data.dateMiseAJour?.toDate(),
          idApiculteur: data.idApiculteur,
          actif: data.actif ?? true,
          nombreCadres: data.nombreCadres,
          typeRuche: data.typeRuche,
          notes: data.notes
        };

        // Récupérer les infos du rucher
        try {
          const rucherDoc = await getDoc(doc(db, this.RUCHERS_COLLECTION, data.idRucher));
          if (rucherDoc.exists()) {
            const rucherData = rucherDoc.data();
            ruche.rucherNom = rucherData.nom;
            ruche.rucherAdresse = rucherData.adresse;
          }
        } catch (error) {
          console.warn('Impossible de récupérer les infos du rucher:', data.idRucher);
        }

        ruchesAvecRucher.push(ruche);
      }

      return ruchesAvecRucher;
    } catch (error) {
      console.error('Erreur lors de la récupération des ruches:', error);
      throw new Error('Impossible de récupérer les ruches.');
    }
  }

  /**
   * Récupère une ruche par son ID
   */
  static async obtenirRucheParId(id: string): Promise<Ruche | null> {
    try {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        throw new Error('Utilisateur non connecté');
      }

      const docRef = doc(db, this.COLLECTION_NAME, id);
      const docSnap = await getDoc(docRef);

      if (docSnap.exists()) {
        const data = docSnap.data();
        
        // Vérifier que la ruche appartient à l'utilisateur
        if (data.idApiculteur !== currentUser.uid) {
          throw new Error('Accès non autorisé à cette ruche');
        }

        return {
          id: docSnap.id,
          idRucher: data.idRucher,
          nom: data.nom,
          position: data.position,
          enService: data.enService,
          dateInstallation: data.dateInstallation?.toDate() || new Date(),
          dateCreation: data.dateCreation?.toDate(),
          dateMiseAJour: data.dateMiseAJour?.toDate(),
          idApiculteur: data.idApiculteur,
          actif: data.actif ?? true,
          nombreCadres: data.nombreCadres,
          typeRuche: data.typeRuche,
          notes: data.notes
        };
      }

      return null;
    } catch (error) {
      console.error('Erreur lors de la récupération de la ruche:', error);
      throw new Error('Impossible de récupérer la ruche.');
    }
  }

  /**
   * Met à jour une ruche
   */
  static async mettreAJourRuche(id: string, donnees: Partial<Ruche>): Promise<void> {
    try {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        throw new Error('Utilisateur non connecté');
      }

      await runTransaction(db, async (transaction) => {
        const rucheRef = doc(db, this.COLLECTION_NAME, id);
        const rucheDoc = await transaction.get(rucheRef);

        if (!rucheDoc.exists()) {
          throw new Error('Ruche non trouvée');
        }

        const rucheData = rucheDoc.data();
        if (rucheData.idApiculteur !== currentUser.uid) {
          throw new Error('Accès non autorisé à cette ruche');
        }

        // Préparer les données de mise à jour
        const updateData: any = { ...donnees };
        delete updateData.id;
        delete updateData.dateCreation;
        delete updateData.idApiculteur;
        
        // Convertir les dates
        if (updateData.dateInstallation instanceof Date) {
          updateData.dateInstallation = Timestamp.fromDate(updateData.dateInstallation);
        }
        
        updateData.dateMiseAJour = Timestamp.now();

        transaction.update(rucheRef, updateData);
      });

      console.log('Ruche mise à jour avec succès');
    } catch (error) {
      console.error('Erreur lors de la mise à jour de la ruche:', error);
      throw new Error('Impossible de mettre à jour la ruche.');
    }
  }

  /**
   * Supprime une ruche (suppression logique)
   */
  static async supprimerRuche(id: string): Promise<void> {
    try {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        throw new Error('Utilisateur non connecté');
      }

      await runTransaction(db, async (transaction) => {
        const rucheRef = doc(db, this.COLLECTION_NAME, id);
        const rucheDoc = await transaction.get(rucheRef);

        if (!rucheDoc.exists()) {
          throw new Error('Ruche non trouvée');
        }

        const rucheData = rucheDoc.data();
        if (rucheData.idApiculteur !== currentUser.uid) {
          throw new Error('Accès non autorisé à cette ruche');
        }

        // Suppression logique
        transaction.update(rucheRef, {
          actif: false,
          dateMiseAJour: Timestamp.now()
        });

        // Mettre à jour le nombre de ruches dans le rucher
        const rucherRef = doc(db, this.RUCHERS_COLLECTION, rucheData.idRucher);
        const rucherDoc = await transaction.get(rucherRef);
        
        if (rucherDoc.exists()) {
          const rucherData = rucherDoc.data();
          const currentNombreRuches = rucherData.nombreRuches || 0;
          transaction.update(rucherRef, {
            nombreRuches: Math.max(0, currentNombreRuches - 1)
          });
        }
      });

      console.log('Ruche supprimée avec succès');
    } catch (error) {
      console.error('Erreur lors de la suppression de la ruche:', error);
      throw new Error('Impossible de supprimer la ruche.');
    }
  }

  /**
   * Écoute les changements des ruches d'un rucher en temps réel
   */
  static ecouterRuchesParRucher(
    idRucher: string,
    callback: (ruches: Ruche[]) => void
  ): () => void {
    const currentUser = auth.currentUser;
    if (!currentUser) {
      throw new Error('Utilisateur non connecté');
    }

    const q = query(
      collection(db, this.COLLECTION_NAME),
      where('idRucher', '==', idRucher),
      where('idApiculteur', '==', currentUser.uid),
      where('actif', '==', true),
      orderBy('position')
    );

    return onSnapshot(q, (querySnapshot) => {
      const ruches: Ruche[] = [];
      querySnapshot.forEach((doc) => {
        const data = doc.data();
        ruches.push({
          id: doc.id,
          idRucher: data.idRucher,
          nom: data.nom,
          position: data.position,
          enService: data.enService,
          dateInstallation: data.dateInstallation?.toDate() || new Date(),
          dateCreation: data.dateCreation?.toDate(),
          dateMiseAJour: data.dateMiseAJour?.toDate(),
          idApiculteur: data.idApiculteur,
          actif: data.actif ?? true,
          nombreCadres: data.nombreCadres,
          typeRuche: data.typeRuche,
          notes: data.notes
        });
      });
      callback(ruches);
    });
  }

  /**
   * Écoute les changements de toutes les ruches de l'utilisateur en temps réel
   */
  static ecouterRuchesUtilisateur(
    callback: (ruches: RucheAvecRucher[]) => void
  ): () => void {
    const currentUser = auth.currentUser;
    if (!currentUser) {
      throw new Error('Utilisateur non connecté');
    }

    const q = query(
      collection(db, this.COLLECTION_NAME),
      where('idApiculteur', '==', currentUser.uid),
      where('actif', '==', true),
      orderBy('dateCreation', 'desc')
    );

    return onSnapshot(q, async (querySnapshot) => {
      const ruchesAvecRucher: RucheAvecRucher[] = [];
      
      for (const docSnapshot of querySnapshot.docs) {
        const data = docSnapshot.data();
        const ruche: RucheAvecRucher = {
          id: docSnapshot.id,
          idRucher: data.idRucher,
          nom: data.nom,
          position: data.position,
          enService: data.enService,
          dateInstallation: data.dateInstallation?.toDate() || new Date(),
          dateCreation: data.dateCreation?.toDate(),
          dateMiseAJour: data.dateMiseAJour?.toDate(),
          idApiculteur: data.idApiculteur,
          actif: data.actif ?? true,
          nombreCadres: data.nombreCadres,
          typeRuche: data.typeRuche,
          notes: data.notes
        };

        // Récupérer les infos du rucher (de manière asynchrone)
        try {
          const rucherDoc = await getDoc(doc(db, this.RUCHERS_COLLECTION, data.idRucher));
          if (rucherDoc.exists()) {
            const rucherData = rucherDoc.data();
            ruche.rucherNom = rucherData.nom;
            ruche.rucherAdresse = rucherData.adresse;
          }
        } catch (error) {
          console.warn('Impossible de récupérer les infos du rucher:', data.idRucher);
        }

        ruchesAvecRucher.push(ruche);
      }
      
      callback(ruchesAvecRucher);
    });
  }

  /**
   * Récupère les mesures des 7 derniers jours d'une ruche depuis Firebase
   */
  static async obtenirMesures7DerniersJours(rucheId: string): Promise<DonneesCapteur[]> {
    return await DonneesCapteursService.getMesures7DerniersJours(rucheId);
  }





  /**
   * Crée des données de test pour une ruche (utilise Firebase)
   */
  static async creerDonneesTest(rucheId: string, nombreJours: number = 10, mesuresParJour: number = 8): Promise<number> {
    return await DonneesCapteursService.creerDonneesTest(rucheId, nombreJours, mesuresParJour);
  }
} 