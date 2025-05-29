import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruche_connectee/config/api_config.dart';
import 'package:ruche_connectee/services/logger_service.dart';
import 'package:ruche_connectee/models/api_models.dart';

/// Service pour les appels API vers le backend Spring Boot
class ApiClientService {
  late final Dio _dio;
  final FirebaseAuth _auth;

  ApiClientService(this._auth) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: ApiConfig.defaultHeaders,
    ));

    // Ajouter l'interceptor d'authentification
    _dio.interceptors.add(AuthInterceptor(_auth));
    
    // Ajouter l'interceptor de logging en mode debug
    if (ApiConfig.isDevelopment) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => LoggerService.debug('HTTP: $object'),
      ));
    }
    
    // Ajouter l'interceptor de gestion d'erreurs
    _dio.interceptors.add(ErrorInterceptor());
  }

  /// Effectue un appel GET
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      LoggerService.debug('API GET: $path');
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      LoggerService.error('Erreur GET $path', e);
      rethrow;
    }
  }

  /// Effectue un appel POST
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      LoggerService.debug('API POST: $path');
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      LoggerService.error('Erreur POST $path', e);
      rethrow;
    }
  }

  /// Effectue un appel PUT
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      LoggerService.debug('API PUT: $path');
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      LoggerService.error('Erreur PUT $path', e);
      rethrow;
    }
  }

  /// Effectue un appel DELETE
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      LoggerService.debug('API DELETE: $path');
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      LoggerService.error('Erreur DELETE $path', e);
      rethrow;
    }
  }

  /// Vérifie la santé de l'API
  Future<HealthResponse> checkHealth() async {
    try {
      final response = await get(ApiConfig.healthEndpoint);
      return HealthResponse.fromJson(response.data);
    } catch (e) {
      LoggerService.error('Erreur health check', e);
      throw ApiException('Impossible de vérifier la santé de l\'API', 500);
    }
  }
}

/// Interceptor pour ajouter automatiquement l'authentification Firebase
class AuthInterceptor extends Interceptor {
  final FirebaseAuth _auth;

  AuthInterceptor(this._auth);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final User? currentUser = _auth.currentUser;
      
      if (currentUser != null) {
        LoggerService.debug('Utilisateur connecté: $currentUser.uid ($currentUser.email)');
        
        // Obtenir le token JWT Firebase
        final String? idToken = await currentUser.getIdToken(false); // false = ne pas forcer le refresh
        
        if (idToken != null && idToken.isNotEmpty) {
          // Ajouter le token d'authentification
          options.headers['Authorization'] = 'Bearer $idToken';
          
          // Ajouter l'ID de l'apiculteur pour l'API Spring Boot
          options.headers['X-Apiculteur-ID'] = currentUser.uid;
          
          LoggerService.debug('Headers d\'authentification ajoutés:');
          LoggerService.debug('- Authorization: Bearer $idToken.substring(0, 20)...');
          LoggerService.debug('- X-Apiculteur-ID: $currentUser.uid');
        } else {
          LoggerService.warning('Token d\'authentification vide ou null');
          // Essayer de forcer un refresh du token
          try {
            final String? refreshedToken = await currentUser.getIdToken(true); // true = forcer le refresh
            if (refreshedToken != null && refreshedToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $refreshedToken';
              options.headers['X-Apiculteur-ID'] = currentUser.uid;
              LoggerService.info('Token rafraîchi avec succès');
            } else {
              LoggerService.error('Impossible de rafraîchir le token d\'authentification');
            }
          } catch (tokenError) {
            LoggerService.error('Erreur lors du rafraîchissement du token', tokenError);
          }
        }
      } else {
        LoggerService.warning('Aucun utilisateur connecté pour l\'authentification');
        LoggerService.debug('État de Firebase Auth: $_auth.currentUser');
      }
      
      // Ajouter des headers supplémentaires pour le debug
      options.headers['Content-Type'] = 'application/json';
      options.headers['Accept'] = 'application/json';
      
      LoggerService.debug('Requête préparée: $options.method $options.uri');
      LoggerService.debug('Headers finaux: $options.headers');
      
      handler.next(options);
    } catch (e) {
      LoggerService.error('Erreur critique dans l\'interceptor d\'authentification', e);
      // Continuer même en cas d'erreur d'auth, mais logguer l'erreur
      handler.next(options);
    }
  }
}

/// Interceptor pour gérer les erreurs de manière uniforme
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerService.error('Erreur HTTP $err.response?.statusCode: $err.message', err);

    // Logguer les détails de la réponse pour le debug
    if (err.response != null) {
      LoggerService.debug('Status Code: $err.response!.statusCode');
      LoggerService.debug('Headers: $err.response!.headers');
      LoggerService.debug('Données de réponse: $err.response!.data');
    }

    ApiException apiException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        apiException = ApiException('Délai d\'attente dépassé', 408);
        break;
        
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 500;
        String message = 'Erreur du serveur';
        
        try {
          if (err.response?.data != null) {
            LoggerService.debug('Tentative de parsing de la réponse d\'erreur: $err.response!.data');
            
            // Essayer différents formats de réponse d'erreur
            final responseData = err.response!.data;
            
            if (responseData is Map<String, dynamic>) {
              // Format ErrorResponse du contrôleur Spring Boot
              if (responseData.containsKey('message')) {
                message = responseData['message'].toString();
              } else if (responseData.containsKey('error')) {
                message = responseData['error'].toString();
              } else {
                message = 'Erreur $statusCode: $responseData';
              }
            } else if (responseData is String) {
              message = responseData;
            } else {
              message = 'Erreur $statusCode: $responseData.toString()';
            }
            
            LoggerService.debug('Message d\'erreur parsé: $message');
          }
        } catch (parseError) {
          LoggerService.debug('Impossible de parser la réponse d\'erreur: $parseError');
          // Utiliser le message d'erreur de base en cas d'échec de parsing
          if (statusCode == 401) {
            message = 'Authentification requise ou token invalide';
          } else if (statusCode == 403) {
            message = 'Accès refusé';
          } else if (statusCode == 404) {
            message = 'Ressource non trouvée';
          } else {
            message = 'Erreur du serveur ($statusCode)';
          }
        }
        
        apiException = ApiException(message, statusCode);
        break;
        
      case DioExceptionType.cancel:
        apiException = ApiException('Requête annulée', 499);
        break;
        
      case DioExceptionType.connectionError:
        apiException = ApiException('Erreur de connexion au serveur. Vérifiez que l\'API Spring Boot est démarrée.', 503);
        break;
        
      default:
        apiException = ApiException('Erreur réseau inattendue', 500);
    }

    LoggerService.error('ApiException générée: $apiException.toString()');

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: apiException,
    ));
  }
}

/// Exception personnalisée pour les erreurs API
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? details;

  ApiException(this.message, this.statusCode, [this.details]);

  @override
  String toString() {
    return 'ApiException($statusCode): $message${details != null ? ' - $details' : ''}';
  }

  /// Vérifie si l'erreur est due à un problème d'authentification
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// Vérifie si l'erreur est due à un problème de réseau
  bool get isNetworkError => statusCode >= 500 || statusCode == 503 || statusCode == 408;

  /// Vérifie si l'erreur est due à une mauvaise requête
  bool get isBadRequest => statusCode >= 400 && statusCode < 500;
} 