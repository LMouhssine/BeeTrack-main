import { DonneesCapteur } from './rucheService';

const API_BASE_URL = 'http://localhost:8080';

export interface ApiResponse<T> {
  status: string;
  data?: T;
  message?: string;
  error?: string;
}

export class ApiRucheService {
  
  /**
   * Récupère la dernière mesure d'une ruche via l'API Spring Boot
   */
  static async getDerniereMesure(rucheId: string, apiculteurId: string): Promise<DonneesCapteur | null> {
    try {
      const response = await fetch(
        `${API_BASE_URL}/api/mobile/ruches/${rucheId}/derniere-mesure`,
        {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            'X-Apiculteur-ID': apiculteurId
          }
        }
      );

      if (response.status === 404) {
        return null; // Aucune mesure trouvée
      }

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || `Erreur HTTP ${response.status}`);
      }

      const data = await response.json();
      
      // Convertir la réponse en objet DonneesCapteur
      return {
        id: data.id,
        rucheId: data.rucheId,
        timestamp: new Date(data.timestamp),
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
   * Récupère les mesures des 7 derniers jours via l'API Spring Boot
   */
  static async getMesures7DerniersJours(rucheId: string, apiculteurId: string): Promise<DonneesCapteur[]> {
    try {
      const response = await fetch(
        `${API_BASE_URL}/api/mobile/ruches/${rucheId}/mesures-7-jours`,
        {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            'X-Apiculteur-ID': apiculteurId
          }
        }
      );

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.message || `Erreur HTTP ${response.status}`);
      }

      const data = await response.json();
      
      // Convertir la réponse en tableau de DonneesCapteur
      return data.map((item: any) => ({
        id: item.id,
        rucheId: item.rucheId,
        timestamp: new Date(item.timestamp),
        temperature: item.temperature,
        humidity: item.humidity,
        couvercleOuvert: item.couvercleOuvert,
        batterie: item.batterie,
        signalQualite: item.signalQualite,
        erreur: item.erreur
      }));

    } catch (error: any) {
      console.error('Erreur lors de la récupération des mesures:', error);
      throw new Error(`Impossible de récupérer les mesures: ${error.message}`);
    }
  }

  /**
   * Test de connectivité avec l'API
   */
  static async testConnectivite(): Promise<boolean> {
    try {
      const response = await fetch(`${API_BASE_URL}/api/mobile/ruches/health`);
      return response.ok;
    } catch (error) {
      console.error('Erreur de connectivité API:', error);
      return false;
    }
  }

  /**
   * Test de la dernière mesure (endpoint de test sans auth)
   */
  static async testDerniereMesure(rucheId: string): Promise<any> {
    try {
      const response = await fetch(`${API_BASE_URL}/test/derniere-mesure/${rucheId}`);
      
      if (!response.ok) {
        throw new Error(`Erreur HTTP ${response.status}`);
      }

      return await response.json();
    } catch (error: any) {
      console.error('Erreur lors du test:', error);
      throw error;
    }
  }

  /**
   * Crée des données de test pour une ruche
   */
  static async creerDonneesTest(rucheId: string, nombreJours: number = 7, mesuresParJour: number = 8): Promise<any> {
    try {
      const response = await fetch(
        `${API_BASE_URL}/dev/create-test-data/${rucheId}?nombreJours=${nombreJours}&mesuresParJour=${mesuresParJour}`,
        { method: 'POST' }
      );
      
      if (!response.ok) {
        throw new Error(`Erreur HTTP ${response.status}`);
      }

      return await response.json();
    } catch (error: any) {
      console.error('Erreur lors de la création des données de test:', error);
      throw error;
    }
  }
} 