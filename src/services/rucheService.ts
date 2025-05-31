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
import { API_BASE_URL, API_ENDPOINTS, getAuthHeaders, buildApiUrl } from '../config/api-config';

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

export interface DonneesCapteur {
  id?: string;
  rucheId: string;
  timestamp: Date;
  temperature?: number;
  humidity?: number;
  couvercleOuvert?: boolean;
  batterie?: number;
  signalQualite?: number;
  erreur?: string;
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
   * Récupère les mesures des 7 derniers jours d'une ruche depuis l'API Spring Boot
   */
  static async obtenirMesures7DerniersJours(rucheId: string): Promise<DonneesCapteur[]> {
    try {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        throw new Error('Utilisateur non connecté');
      }

      // Obtenir le token d'authentification Firebase
      const token = await currentUser.getIdToken();

      // Construire l'URL avec la nouvelle configuration
      const url = buildApiUrl(API_ENDPOINTS.MESURES_7_JOURS(rucheId));

      // Appeler l'API Spring Boot
      const response = await fetch(url, {
        method: 'GET',
        headers: getAuthHeaders(currentUser.uid, token),
      });

      if (!response.ok) {
        if (response.status === 404) {
          throw new Error('Ruche non trouvée');
        } else if (response.status === 403) {
          throw new Error('Accès non autorisé à cette ruche');
        } else if (response.status >= 500) {
          throw new Error('Erreur du serveur. Veuillez réessayer plus tard.');
        } else {
          throw new Error(`Erreur HTTP: ${response.status}`);
        }
      }

      const data = await response.json();
      
      // Vérifier si c'est une réponse d'erreur
      if (data.code && data.message) {
        throw new Error(data.message);
      }

      // Convertir les données en objets DonneesCapteur
      const mesures: DonneesCapteur[] = (data as any[]).map(item => ({
        id: item.id,
        rucheId: item.rucheId,
        timestamp: new Date(item.timestamp),
        temperature: item.temperature,
        humidity: item.humidity,
        couvercleOuvert: item.couvercleOuvert,
        batterie: item.batterie,
        signalQualite: item.signalQualite,
        erreur: item.erreur,
      }));

      console.log(`📊 ${mesures.length} mesures récupérées pour la ruche ${rucheId}`);
      return mesures;

    } catch (error: any) {
      console.error('Erreur lors de la récupération des mesures:', error);
      
      if (error.message) {
        throw error; // Relancer les erreurs personnalisées
      } else if (error.name === 'TypeError' || error.message?.includes('fetch')) {
        throw new Error('Impossible de contacter le serveur. Vérifiez votre connexion internet.');
      } else {
        throw new Error('Erreur lors de la récupération des mesures');
      }
    }
  }

  /**
   * Récupère les mesures des 7 derniers jours directement depuis Firestore (fallback)
   */
  static async obtenirMesures7DerniersJoursFirestore(rucheId: string): Promise<DonneesCapteur[]> {
    try {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        throw new Error('Utilisateur non connecté');
      }

      // Calculer la date d'il y a 7 jours
      const dateLimite = new Date();
      dateLimite.setDate(dateLimite.getDate() - 7);

      console.log(`🔍 Recherche des mesures depuis le ${dateLimite.toLocaleDateString()} pour la ruche ${rucheId}`);

      // Version simplifiée sans index - récupérer toutes les mesures de la ruche
      const q = query(
        collection(db, 'donneesCapteurs'),
        where('rucheId', '==', rucheId)
      );

      const querySnapshot = await getDocs(q);
      const toutesLesMesures: DonneesCapteur[] = [];

      querySnapshot.forEach((doc) => {
        const data = doc.data();
        const timestamp = data.timestamp?.toDate() || new Date();
        
        // Filtrer côté client pour les 7 derniers jours
        if (timestamp >= dateLimite) {
          toutesLesMesures.push({
            id: doc.id,
            rucheId: data.rucheId,
            timestamp: timestamp,
            temperature: data.temperature,
            humidity: data.humidity,
            couvercleOuvert: data.couvercleOuvert,
            batterie: data.batterie,
            signalQualite: data.signalQualite,
            erreur: data.erreur,
          });
        }
      });

      // Trier par timestamp croissant côté client
      const mesures = toutesLesMesures.sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime());

      console.log(`🔥 ${mesures.length} mesures récupérées depuis Firestore pour la ruche ${rucheId} (filtrage client)`);
      return mesures;

    } catch (error: any) {
      console.error('Erreur lors de la récupération des mesures Firestore:', error);
      
      if (error.code === 'permission-denied') {
        throw new Error('Permissions insuffisantes pour accéder aux données');
      } else if (error.code === 'unavailable') {
        throw new Error('Firestore temporairement indisponible');
      } else {
        throw new Error('Erreur lors de la récupération des mesures depuis Firestore');
      }
    }
  }

  /**
   * Méthode robuste qui essaie l'API puis Firestore en fallback
   */
  static async obtenirMesures7DerniersJoursRobuste(rucheId: string): Promise<DonneesCapteur[]> {
    try {
      // Essayer d'abord l'API Spring Boot
      console.log('🌐 Tentative de récupération via API Spring Boot...');
      return await this.obtenirMesures7DerniersJours(rucheId);
    } catch (error: any) {
      console.log('⚠️ Échec de l\'API Spring Boot, fallback vers Firestore...');
      // En cas d'échec, utiliser Firestore directement
      return await this.obtenirMesures7DerniersJoursFirestore(rucheId);
    }
  }

  /**
   * Crée des données de test pour une ruche (utilise l'API de test)
   */
  static async creerDonneesTest(rucheId: string, nombreJours: number = 10, mesuresParJour: number = 8): Promise<number> {
    try {
      // Construire l'URL avec la nouvelle configuration
      const url = buildApiUrl(API_ENDPOINTS.CREER_DONNEES_TEST(rucheId)) + `?nombreJours=${nombreJours}&mesuresParJour=${mesuresParJour}`;

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error(`Erreur HTTP: ${response.status}`);
      }

      const data = await response.json();
      console.log(`🧪 ${data.mesuresCreees} mesures de test créées pour la ruche ${rucheId}`);
      return data.mesuresCreees;

    } catch (error: any) {
      console.error('Erreur lors de la création des données de test:', error);
      throw new Error('Erreur lors de la création des données de test');
    }
  }

  /**
   * Crée des données de test via l'endpoint de développement (sans authentification)
   */
  static async creerDonneesTestDev(rucheId: string, nombreJours: number = 10, mesuresParJour: number = 8): Promise<number> {
    try {
      // Construire l'URL avec l'endpoint de développement
      const url = buildApiUrl(API_ENDPOINTS.DEV_CREATE_TEST_DATA(rucheId)) + `?nombreJours=${nombreJours}&mesuresParJour=${mesuresParJour}`;

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error(`Erreur HTTP: ${response.status}`);
      }

      const data = await response.json();
      console.log(`🧪 ${data.totalMesures} mesures de test créées pour la ruche ${rucheId} via l'endpoint de développement`);
      return data.totalMesures;

    } catch (error: any) {
      console.error('Erreur lors de la création des données de test (dev):', error);
      throw new Error('Erreur lors de la création des données de test (dev)');
    }
  }

  /**
   * Teste la connectivité avec l'endpoint de développement
   */
  static async testerConnectiviteDev(): Promise<boolean> {
    try {
      const url = buildApiUrl(API_ENDPOINTS.DEV_HEALTH);
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      return response.ok;
    } catch (error) {
      console.error('Erreur de connectivité dev:', error);
      return false;
    }
  }
} 