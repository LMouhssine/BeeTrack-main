/// Configuration centralisée pour la gestion des logs
class LoggingConfig {
  /// Niveau de log par défaut (peut être modifié selon l'environnement)
  static const bool enableDebugLogs = false;
  static const bool enableTraceLogs = false;
  static const bool enableVerboseLogs = false;
  
  /// Niveau de log pour l'environnement de production
  static const bool productionMode = true;
  
  /// Afficher les logs HTTP détaillés
  static const bool showHttpDetails = false;
  
  /// Afficher les logs de Firebase
  static const bool showFirebaseLogs = true;
  
  /// Afficher les logs d'authentification
  static const bool showAuthLogs = true;
  
  /// Afficher les logs d'API
  static const bool showApiLogs = true;
}






