class ApiConfig {
  // URL de base de l'API Spring Boot
  // En développement : localhost
  // En production : URL du serveur déployé
  static const String _baseUrlDev = 'http://localhost:8080';
  
  // Utiliser l'URL de développement par défaut
  // TODO: Adapter selon l'environnement (dev/prod)
  static const String baseUrl = _baseUrlDev;
  
  // Endpoints de l'API
  static const String apiPrefix = '/api/mobile';
  
  // Endpoints des ruches
  static const String ruchesEndpoint = '$apiPrefix/ruches';
  static const String ruchersEndpoint = '$apiPrefix/ruchers';
  static const String healthEndpoint = '$apiPrefix/ruches/health';
  static const String healthAuthEndpoint = '$apiPrefix/ruches/health/auth';
  
  // Timeout pour les requêtes
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
  
  // Headers par défaut
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Méthodes utilitaires pour construire les URLs
  static String get fullRuchesUrl => '$baseUrl$ruchesEndpoint';
  static String get fullRuchersUrl => '$baseUrl$ruchersEndpoint';
  static String get fullHealthUrl => '$baseUrl$healthEndpoint';
  static String get fullHealthAuthUrl => '$baseUrl$healthAuthEndpoint';
  
  static String rucheByIdUrl(String rucheId) => '$fullRuchesUrl/$rucheId';
  static String ruchesByRucherUrl(String rucherId) => '$fullRuchesUrl/rucher/$rucherId';
  
  // Vérifier si on est en mode développement
  static bool get isDevelopment => baseUrl == _baseUrlDev;
} 