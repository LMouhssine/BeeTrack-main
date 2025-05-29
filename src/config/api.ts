/**
 * Configuration de l'API Spring Boot
 */

// TODO: Uncomment when ApiRucheService is implemented
// import { ApiRucheService, initializeApiAuth } from '../services/apiRucheService';
import { auth } from '../firebase-config';
import { onAuthStateChanged } from 'firebase/auth';

// Configuration de l'URL de base de l'API
export const API_CONFIG = {
  baseUrl: process.env.REACT_APP_API_URL || 'http://localhost:8080',
  endpoints: {
    ruches: '/api/mobile/ruches',
    ruchers: '/api/mobile/ruchers',
    health: '/api/mobile/health'
  }
};

/**
 * Initialise l'authentification avec l'API Spring Boot
 * TODO: Uncomment when ApiRucheService is implemented
 */
export const initializeApiAuthentication = () => {
  onAuthStateChanged(auth, async (user) => {
    if (user) {
      try {
        // Obtenir le token Firebase
        const token = await user.getIdToken();
        
        // TODO: Uncomment when ApiRucheService is implemented
        // Configurer l'authentification API
        // ApiRucheService.setAuth(token, user.uid);
        
        console.log('🔑 Authentification Firebase configurée pour l\'utilisateur:', user.uid);
        
        // TODO: Uncomment when ApiRucheService is implemented
        // Tester la connectivité
        // const isHealthy = await ApiRucheService.healthCheck();
        // if (isHealthy) {
        //   console.log('✅ API Spring Boot accessible');
        // } else {
        //   console.warn('⚠️ API Spring Boot non accessible');
        // }
        
      } catch (error) {
        console.error('Erreur lors de l\'initialisation de l\'authentification:', error);
      }
    } else {
      console.log('👤 Utilisateur déconnecté');
    }
  });
};

/**
 * Vérifie si l'API est disponible
 */
export const checkApiHealth = async (): Promise<boolean> => {
  try {
    const response = await fetch(`${API_CONFIG.baseUrl}${API_CONFIG.endpoints.health}`);
    return response.ok;
  } catch {
    return false;
  }
};

/**
 * Configuration des headers par défaut
 */
export const getDefaultHeaders = (includeAuth = false) => {
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
  };

  if (includeAuth && auth.currentUser) {
    // TODO: Ces headers seront gérés par ApiRucheService quand il sera implémenté
    console.log('Headers d\'authentification à implémenter avec ApiRucheService');
  }

  return headers;
};

// Initialiser automatiquement l'authentification Firebase
initializeApiAuthentication(); 