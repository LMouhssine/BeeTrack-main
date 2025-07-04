import { 
  collection, 
  addDoc, 
  getDocs, 
  doc, 
  getDoc, 
  query, 
  where, 
  orderBy, 
  limit,
  Timestamp,
  onSnapshot
} from 'firebase/firestore';
import { auth, db } from '../firebase-config';

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

export class DonneesCapteursService {
  private static readonly COLLECTION_NAME = 'donneesCapteurs';

  /**
   * Récupère la dernière mesure d'une ruche
   */
  static async getDerniereMesure(rucheId: string): Promise<DonneesCapteur | null> {
    try {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        throw new Error('Utilisateur non connecté');
      }

      const q = query(
        collection(db, this.COLLECTION_NAME),
        where('rucheId', '==', rucheId),
        orderBy('timestamp', 'desc'),
        limit(1)
      );

      const querySnapshot = await getDocs(q);
      
      if (querySnapshot.empty) {
        return null;
      }

      const doc = querySnapshot.docs[0];
      const data = doc.data();
      
      return {
        id: doc.id,
        rucheId: data.rucheId,
        timestamp: data.timestamp?.toDate() || new Date(data.timestamp),
        temperature: data.temperature,
        humidity: data.humidity,
        couvercleOuvert: data.couvercleOuvert,
        batterie: data.batterie,
        signalQualite: data.signalQualite,
        erreur: data.erreur
      };

    } catch (error: any) {
      console.error('Erreur lors de la récupération de la dernière mesure:', error);
      throw new Error(`Impossible de récupérer la dernière mesure: ${error.message}`);
    }
  }

  /**
   * Récupère les mesures des 7 derniers jours pour une ruche
   */
  static async getMesures7DerniersJours(rucheId: string): Promise<DonneesCapteur[]> {
    try {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        throw new Error('Utilisateur non connecté');
      }

      const maintenant = new Date();
      const il7Jours = new Date(maintenant.getTime() - (7 * 24 * 60 * 60 * 1000));

      const q = query(
        collection(db, this.COLLECTION_NAME),
        where('rucheId', '==', rucheId),
        where('timestamp', '>=', Timestamp.fromDate(il7Jours)),
        orderBy('timestamp', 'asc')
      );

      const querySnapshot = await getDocs(q);
      const mesures: DonneesCapteur[] = [];

      querySnapshot.forEach((doc) => {
        const data = doc.data();
        mesures.push({
          id: doc.id,
          rucheId: data.rucheId,
          timestamp: data.timestamp?.toDate() || new Date(data.timestamp),
          temperature: data.temperature,
          humidity: data.humidity,
          couvercleOuvert: data.couvercleOuvert,
          batterie: data.batterie,
          signalQualite: data.signalQualite,
          erreur: data.erreur
        });
      });

      return mesures;

    } catch (error: any) {
      console.error('Erreur lors de la récupération des mesures:', error);
      throw new Error(`Impossible de récupérer les mesures: ${error.message}`);
    }
  }

  /**
   * Récupère toutes les mesures d'une ruche avec pagination
   */
  static async getMesuresParRuche(
    rucheId: string, 
    nombreMesures: number = 100
  ): Promise<DonneesCapteur[]> {
    try {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        throw new Error('Utilisateur non connecté');
      }

      const q = query(
        collection(db, this.COLLECTION_NAME),
        where('rucheId', '==', rucheId),
        orderBy('timestamp', 'desc'),
        limit(nombreMesures)
      );

      const querySnapshot = await getDocs(q);
      const mesures: DonneesCapteur[] = [];

      querySnapshot.forEach((doc) => {
        const data = doc.data();
        mesures.push({
          id: doc.id,
          rucheId: data.rucheId,
          timestamp: data.timestamp?.toDate() || new Date(data.timestamp),
          temperature: data.temperature,
          humidity: data.humidity,
          couvercleOuvert: data.couvercleOuvert,
          batterie: data.batterie,
          signalQualite: data.signalQualite,
          erreur: data.erreur
        });
      });

      return mesures.reverse(); // Retourner dans l'ordre chronologique

    } catch (error: any) {
      console.error('Erreur lors de la récupération des mesures:', error);
      throw new Error(`Impossible de récupérer les mesures: ${error.message}`);
    }
  }

  /**
   * Ajoute une nouvelle mesure de capteur
   */
  static async ajouterMesure(donnees: Omit<DonneesCapteur, 'id'>): Promise<string> {
    try {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        throw new Error('Utilisateur non connecté');
      }

      const nouvelleMesure = {
        ...donnees,
        timestamp: Timestamp.fromDate(donnees.timestamp)
      };

      const docRef = await addDoc(collection(db, this.COLLECTION_NAME), nouvelleMesure);
      
      console.log('✅ Mesure ajoutée avec succès:', docRef.id);
      return docRef.id;

    } catch (error: any) {
      console.error('Erreur lors de l\'ajout de la mesure:', error);
      throw new Error(`Impossible d'ajouter la mesure: ${error.message}`);
    }
  }

  /**
   * Écoute en temps réel les nouvelles mesures d'une ruche
   */
  static ecouterMesuresEnTempsReel(
    rucheId: string,
    callback: (mesures: DonneesCapteur[]) => void
  ): () => void {
    const currentUser = auth.currentUser;
    if (!currentUser) {
      throw new Error('Utilisateur non connecté');
    }

    // Écouter les mesures des dernières 24 heures
    const hier = new Date(Date.now() - 24 * 60 * 60 * 1000);

    const q = query(
      collection(db, this.COLLECTION_NAME),
      where('rucheId', '==', rucheId),
      where('timestamp', '>=', Timestamp.fromDate(hier)),
      orderBy('timestamp', 'desc')
    );

    const unsubscribe = onSnapshot(q, (querySnapshot) => {
      const mesures: DonneesCapteur[] = [];
      
      querySnapshot.forEach((doc) => {
        const data = doc.data();
        mesures.push({
          id: doc.id,
          rucheId: data.rucheId,
          timestamp: data.timestamp?.toDate() || new Date(data.timestamp),
          temperature: data.temperature,
          humidity: data.humidity,
          couvercleOuvert: data.couvercleOuvert,
          batterie: data.batterie,
          signalQualite: data.signalQualite,
          erreur: data.erreur
        });
      });

      callback(mesures);
    }, (error) => {
      console.error('Erreur dans l\'écoute en temps réel:', error);
    });

    return unsubscribe;
  }

  /**
   * Crée des données de test pour une ruche
   */
  static async creerDonneesTest(
    rucheId: string, 
    nombreJours: number = 7, 
    mesuresParJour: number = 8
  ): Promise<number> {
    try {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        throw new Error('Utilisateur non connecté');
      }

      let nombreMesuresCreees = 0;
      const maintenant = new Date();

      for (let jour = 0; jour < nombreJours; jour++) {
        for (let mesure = 0; mesure < mesuresParJour; mesure++) {
          const horaireAleatoire = Math.floor(Math.random() * 24 * 60);
          const timestamp = new Date(maintenant.getTime() - (jour * 24 * 60 * 60 * 1000) + (horaireAleatoire * 60 * 1000));

          const donneesTest: Omit<DonneesCapteur, 'id'> = {
            rucheId,
            timestamp,
            temperature: Math.round((15 + Math.random() * 20) * 10) / 10,
            humidity: Math.round((40 + Math.random() * 40) * 10) / 10,
            couvercleOuvert: Math.random() > 0.9,
            batterie: Math.round((60 + Math.random() * 40) * 10) / 10,
            signalQualite: Math.round((50 + Math.random() * 50) * 10) / 10
          };

          await this.ajouterMesure(donneesTest);
          nombreMesuresCreees++;
        }
      }

      console.log(`✅ ${nombreMesuresCreees} mesures de test créées pour la ruche ${rucheId}`);
      return nombreMesuresCreees;

    } catch (error: any) {
      console.error('Erreur lors de la création des données de test:', error);
      throw new Error(`Impossible de créer les données de test: ${error.message}`);
    }
  }

  /**
   * Test de connectivité avec Firebase
   */
  static async testConnectivite(): Promise<boolean> {
    try {
      const currentUser = auth.currentUser;
      if (!currentUser) {
        return false;
      }

      const q = query(
        collection(db, this.COLLECTION_NAME),
        limit(1)
      );
      
      await getDocs(q);
      return true;

    } catch (error) {
      console.error('Erreur de connectivité Firebase:', error);
      return false;
    }
  }
} 