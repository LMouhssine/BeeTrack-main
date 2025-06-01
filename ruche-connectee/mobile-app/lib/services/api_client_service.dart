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

  /// Effectue une requête GET
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      LoggerService.error('Erreur GET $path', e);
      rethrow;
    }
  }

  /// Effectue une requête POST
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      LoggerService.error('Erreur POST $path', e);
      rethrow;
    }
  }

  /// Effectue une requête PUT
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(path, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      LoggerService.error('Erreur PUT $path', e);
      rethrow;
    }
  }

  /// Effectue une requête DELETE
  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(path, queryParameters: queryParameters);
      return response;
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
      await _addAuthHeaders(options);
      
      // Ajouter des headers supplémentaires pour le debug
      options.headers['Content-Type'] = 'application/json';
      options.headers['Accept'] = 'application/json';
      
      handler.next(options);
    } catch (e) {
      LoggerService.error('Erreur dans l\'interceptor d\'auth', e);
      // Continuer même en cas d'erreur d'auth
      handler.next(options);
    }
  }

  /// Ajoute les headers d'authentification à la requête
  Future<void> _addAuthHeaders(RequestOptions options) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Obtenir le token d'authentification
        final idToken = await currentUser.getIdToken();
        
        if (idToken != null && idToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $idToken';
          options.headers['X-Apiculteur-ID'] = currentUser.uid;
        } else {
          LoggerService.warning('Token d\'authentification vide');
        }
      } else {
        LoggerService.warning('Utilisateur non connecté');
      }
    } catch (e) {
      LoggerService.error('Erreur lors de l\'ajout des headers d\'auth', e);
    }
  }
}

/// Interceptor pour gérer les erreurs de manière uniforme
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerService.error('Erreur HTTP ${err.response?.statusCode}: ${err.message}');

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
              message = 'Erreur $statusCode: ${responseData.toString()}';
            }
          }
        } catch (parseError) {
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