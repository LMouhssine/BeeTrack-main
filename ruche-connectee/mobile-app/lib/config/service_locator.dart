import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:ruche_connectee/services/api_client_service.dart';
import 'package:ruche_connectee/services/api_ruche_service.dart';
import 'package:ruche_connectee/services/auth_service.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';
import 'package:ruche_connectee/services/alerte_couvercle_service.dart';

/// Service Locator pour l'injection de dépendances
final GetIt getIt = GetIt.instance;

/// Configure tous les services dans le service locator
Future<void> setupServiceLocator() async {
  // Services Firebase existants
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
  
  // Service d'authentification
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<FirebaseService>()),
  );
  
  // Client API pour Spring Boot
  getIt.registerLazySingleton<ApiClientService>(
    () => ApiClientService(FirebaseAuth.instance),
  );
  
  // Service des ruches via API
  getIt.registerLazySingleton<ApiRucheService>(
    () => ApiRucheService(getIt<ApiClientService>()),
  );
  
  // Service d'alerte couvercle (utilise le singleton)
  getIt.registerLazySingleton<AlerteCouvercleService>(
    () => AlerteCouvercleService.instance..init(getIt<ApiRucheService>()),
  );
  
  LoggerService.info('📦 Service Locator configuré avec succès');
}

/// Nettoie et réinitialise le service locator
Future<void> resetServiceLocator() async {
  await getIt.reset();
  LoggerService.info('📦 Service Locator réinitialisé');
} 