import { 
  collection, 
  addDoc,
  Timestamp
} from 'firebase/firestore';
import { db } from '../firebase-config';

export interface DonneesTest {
  rucheId: string;
  timestamp: Date;
  temperature: number;
  humidity: number;
  batterie: number;
  couvercleOuvert: boolean;
  signalQualite: number;
}

export class TestDataService {
  
  /**
   * Génère des données de test réalistes
   */
  private static genererDonneesRealistesTest(rucheId: string, nombreJours: number = 10, mesuresParJour: number = 8): DonneesTest[] {
    const donnees: DonneesTest[] = [];
    const maintenant = new Date();
    
    for (let jour = nombreJours; jour >= 0; jour--) {
      const dateJour = new Date(maintenant);
      dateJour.setDate(maintenant.getDate() - jour);
      
      for (let mesure = 0; mesure < mesuresParJour; mesure++) {
        const timestampMesure = new Date(dateJour);
        timestampMesure.setHours(Math.floor(mesure * (24 / mesuresParJour)));
        timestampMesure.setMinutes(Math.floor(Math.random() * 60));
        timestampMesure.setSeconds(Math.floor(Math.random() * 60));
        
        // Générer des valeurs réalistes avec variations
        const temperature = 15 + (Math.random() - 0.5) * 10; // 10°C à 20°C
        const humidity = 45 + (Math.random() - 0.5) * 30; // 30% à 60%
        const batterie = Math.max(20, 100 - jour * 2 + (Math.random() - 0.5) * 20); // Déclin progressif
        const couvercleOuvert = Math.random() < 0.05; // 5% de chance d'être ouvert
        const signalQualite = 70 + Math.random() * 30; // 70% à 100%
        
        donnees.push({
          rucheId,
          timestamp: timestampMesure,
          temperature: Math.round(temperature * 10) / 10,
          humidity: Math.round(humidity * 10) / 10,
          batterie: Math.round(batterie),
          couvercleOuvert,
          signalQualite: Math.round(signalQualite),
        });
      }
    }
    
    return donnees;
  }
  
  /**
   * Crée des données de test directement dans Firestore
   */
  static async creerDonneesTestFirestore(rucheId: string, nombreJours: number = 10, mesuresParJour: number = 8): Promise<number> {
    try {
      const donnees = this.genererDonneesRealistesTest(rucheId, nombreJours, mesuresParJour);
      let mesuresCreees = 0;
      
      console.log(`🧪 Création de ${donnees.length} mesures de test pour la ruche ${rucheId}...`);
      
      // Ajouter chaque mesure à Firestore
      for (const donnee of donnees) {
        await addDoc(collection(db, 'donneesCapteurs'), {
          rucheId: donnee.rucheId,
          timestamp: Timestamp.fromDate(donnee.timestamp),
          temperature: donnee.temperature,
          humidity: donnee.humidity,
          batterie: donnee.batterie,
          couvercleOuvert: donnee.couvercleOuvert,
          signalQualite: donnee.signalQualite,
        });
        mesuresCreees++;
        
        // Petite pause pour éviter de surcharger Firestore
        if (mesuresCreees % 10 === 0) {
          await new Promise(resolve => setTimeout(resolve, 100));
        }
      }
      
      console.log(`✅ ${mesuresCreees} mesures de test créées avec succès dans Firestore`);
      return mesuresCreees;
      
    } catch (error: any) {
      console.error('❌ Erreur lors de la création des données de test:', error);
      throw new Error(`Erreur lors de la création des données de test: ${error.message}`);
    }
  }
  
  /**
   * Génère des données de test avec variation de température saisonnière
   */
  static async creerDonneesTestAvecSaison(rucheId: string, nombreJours: number = 30): Promise<number> {
    try {
      const donnees: DonneesTest[] = [];
      const maintenant = new Date();
      const moisActuel = maintenant.getMonth(); // 0-11
      
      // Température de base selon la saison
      let tempBase = 15;
      if (moisActuel >= 5 && moisActuel <= 7) { // Juin-Août
        tempBase = 25;
      } else if (moisActuel >= 2 && moisActuel <= 4) { // Mars-Mai
        tempBase = 18;
      } else if (moisActuel >= 8 && moisActuel <= 10) { // Sep-Nov
        tempBase = 12;
      } else { // Déc-Fév
        tempBase = 8;
      }
      
      for (let jour = nombreJours; jour >= 0; jour--) {
        const dateJour = new Date(maintenant);
        dateJour.setDate(maintenant.getDate() - jour);
        
        // 4 mesures par jour (matin, midi, soir, nuit)
        const heures = [6, 12, 18, 23];
        
        for (const heure of heures) {
          const timestampMesure = new Date(dateJour);
          timestampMesure.setHours(heure, Math.floor(Math.random() * 60), Math.floor(Math.random() * 60));
          
          // Variation de température selon l'heure
          let tempVariation = 0;
          if (heure === 6) tempVariation = -3; // Plus froid le matin
          if (heure === 12) tempVariation = +5; // Plus chaud à midi
          if (heure === 18) tempVariation = +2; // Encore chaud le soir
          if (heure === 23) tempVariation = -2; // Plus frais la nuit
          
          const temperature = tempBase + tempVariation + (Math.random() - 0.5) * 4;
          const humidity = 50 + (Math.random() - 0.5) * 20;
          const batterie = Math.max(15, 95 - jour * 1.5 + (Math.random() - 0.5) * 10);
          
          donnees.push({
            rucheId,
            timestamp: timestampMesure,
            temperature: Math.round(temperature * 10) / 10,
            humidity: Math.round(Math.max(0, Math.min(100, humidity)) * 10) / 10,
            batterie: Math.round(Math.max(0, Math.min(100, batterie))),
            couvercleOuvert: Math.random() < 0.02, // 2% de chance
            signalQualite: Math.round(75 + Math.random() * 25),
          });
        }
      }
      
      console.log(`🌟 Création de ${donnees.length} mesures saisonnières pour la ruche ${rucheId}...`);
      
      let mesuresCreees = 0;
      for (const donnee of donnees) {
        await addDoc(collection(db, 'donneesCapteurs'), {
          rucheId: donnee.rucheId,
          timestamp: Timestamp.fromDate(donnee.timestamp),
          temperature: donnee.temperature,
          humidity: donnee.humidity,
          batterie: donnee.batterie,
          couvercleOuvert: donnee.couvercleOuvert,
          signalQualite: donnee.signalQualite,
        });
        mesuresCreees++;
        
        if (mesuresCreees % 10 === 0) {
          await new Promise(resolve => setTimeout(resolve, 50));
        }
      }
      
      console.log(`✅ ${mesuresCreees} mesures saisonnières créées avec succès`);
      return mesuresCreees;
      
    } catch (error: any) {
      console.error('❌ Erreur lors de la création des données saisonnières:', error);
      throw new Error(`Erreur lors de la création des données saisonnières: ${error.message}`);
    }
  }
} 