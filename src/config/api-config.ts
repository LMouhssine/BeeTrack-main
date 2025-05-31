/**
 * Configuration de l'API Spring Boot
 */

// URL de base de l'API Spring Boot
// En développement: http://localhost:8080
// En production: remplacer par l'URL du serveur déployé
export const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

// Endpoints de l'API
export const API_ENDPOINTS = {
  // Endpoints publics
  RUCHES: '/api/ruches',
  RUCHERS: '/api/ruchers',
  
  // Endpoints mobiles (avec authentification)
  MOBILE_RUCHES: '/api/mobile/ruches',
  MOBILE_RUCHERS: '/api/mobile/ruchers',
  
  // Endpoints de test (développement uniquement)
  TEST: '/api/test',
  TEST_HEALTH: '/api/test/health',
  
  // Endpoints de développement (sans authentification)
  DEV_HEALTH: '/dev/health',
  DEV_CREATE_TEST_DATA: (rucheId: string) => `/dev/create-test-data/${rucheId}`,
  DEV_GET_TEST_DATA: (rucheId: string) => `/dev/test-data/${rucheId}`,
  
  // Endpoints spécifiques
  MESURES_7_JOURS: (rucheId: string) => `/api/mobile/ruches/${rucheId}/mesures-7-jours`,
  CREER_DONNEES_TEST: (rucheId: string) => `/api/test/ruche/${rucheId}/creer-donnees-test`,
} as const;

// Headers par défaut pour les requêtes
export const DEFAULT_HEADERS = {
  'Content-Type': 'application/json',
} as const;

// Configuration des timeouts
export const API_CONFIG = {
  TIMEOUT: 30000, // 30 secondes
  RETRY_ATTEMPTS: 3,
  RETRY_DELAY: 1000, // 1 seconde
} as const;

/**
 * Utilitaire pour construire les headers avec authentification
 */
export const getAuthHeaders = (apiculteurId: string, token?: string) => {
  const headers: Record<string, string> = {
    ...DEFAULT_HEADERS,
    'X-Apiculteur-ID': apiculteurId,
  };
  
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  
  return headers;
};

/**
 * Utilitaire pour construire une URL complète
 */
export const buildApiUrl = (endpoint: string) => {
  return `${API_BASE_URL}${endpoint}`;
}; 