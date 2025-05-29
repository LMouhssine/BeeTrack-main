import 'package:ruche_connectee/config/api_config.dart';
import 'package:ruche_connectee/models/api_models.dart';
import 'package:ruche_connectee/services/api_client_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';

/// Service pour la gestion des ruches via l'API Spring Boot
class ApiRucheService {
  final ApiClientService _apiClient;
  
  ApiRucheService(this._apiClient);
  
  /// Ajoute une nouvelle ruche via l'API Spring Boot
  /// 
  /// Paramètres :
  /// - [idRucher] : ID du rucher auquel appartient la ruche
  /// - [nom] : nom de la ruche
  /// - [position] : position de la ruche dans le rucher
  /// - [typeRuche] : type de ruche (optionnel)
  /// - [description] : description de la ruche (optionnel)
  /// - [enService] : statut de service (par défaut true)
  /// - [dateInstallation] : date d'installation (optionnel)
  /// 
  /// Retourne l'objet RucheResponse créé
  /// 
  /// Lève une ApiException en cas d'erreur
  Future<RucheResponse> ajouterRuche({
    required String idRucher,
    required String nom,
    required String position,
    String? typeRuche,
    String? description,
    bool enService = true,
    DateTime? dateInstallation,
  }) async {
    try {
      LoggerService.info('🐝 Tentative d\'ajout d\'une nouvelle ruche: $nom dans le rucher: $idRucher');
      
      final request = CreateRucheRequest(
        idRucher: idRucher,
        nom: nom,
        position: position,
        typeRuche: typeRuche,
        description: description,
        enService: enService,
        dateInstallation: dateInstallation,
      );
      
      final response = await _apiClient.post(
        ApiConfig.ruchesEndpoint,
        data: request.toJson(),
      );
      
      final rucheResponse = RucheResponse.fromJson(response.data);
      
      LoggerService.info('🐝 Ruche créée avec succès. ID: ${rucheResponse.id}');
      
      return rucheResponse;
      
    } catch (e) {
      LoggerService.error('Erreur lors de l\'ajout de la ruche', e);
      
      if (e is ApiException) {
        rethrow;
      }
      
      throw ApiException('Une erreur inattendue s\'est produite lors de l\'ajout de la ruche', 500);
    }
  }

  /// Récupère toutes les ruches de l'utilisateur connecté
  /// 
  /// Retourne une liste des ruches triées par date de création
  Future<List<RucheResponse>> obtenirRuchesUtilisateur() async {
    try {
      LoggerService.info('🐝 Récupération des ruches de l\'utilisateur');
      
      final response = await _apiClient.get(ApiConfig.ruchesEndpoint);
      
      final List<dynamic> ruchesJson = response.data as List<dynamic>;
      final List<RucheResponse> ruches = ruchesJson
          .map((json) => RucheResponse.fromJson(json as Map<String, dynamic>))
          .toList();
      
      LoggerService.info('🐝 ${ruches.length} ruche(s) récupérée(s) avec succès');
      
      return ruches;
      
    } catch (e) {
      LoggerService.error('Erreur lors de la récupération des ruches utilisateur', e);
      
      if (e is ApiException) {
        rethrow;
      }
      
      throw ApiException('Une erreur inattendue s\'est produite lors de la récupération des ruches', 500);
    }
  }

  /// Récupère toutes les ruches d'un rucher spécifique
  /// 
  /// Paramètres :
  /// - [idRucher] : ID du rucher
  /// 
  /// Retourne une liste des ruches triées par position
  Future<List<RucheResponse>> obtenirRuchesParRucher(String idRucher) async {
    try {
      LoggerService.info('🐝 Récupération des ruches pour le rucher: $idRucher');
      
      final response = await _apiClient.get(
        '${ApiConfig.ruchesEndpoint}/rucher/$idRucher',
      );
      
      final List<dynamic> ruchesJson = response.data as List<dynamic>;
      final List<RucheResponse> ruches = ruchesJson
          .map((json) => RucheResponse.fromJson(json as Map<String, dynamic>))
          .toList();
      
      LoggerService.info('🐝 ${ruches.length} ruche(s) récupérée(s) avec succès pour le rucher: $idRucher');
      
      return ruches;
      
    } catch (e) {
      LoggerService.error('Erreur lors de la récupération des ruches par rucher', e);
      
      if (e is ApiException) {
        rethrow;
      }
      
      throw ApiException('Une erreur inattendue s\'est produite lors de la récupération des ruches', 500);
    }
  }

  /// Récupère une ruche par son ID
  /// 
  /// Paramètres :
  /// - [rucheId] : ID de la ruche
  /// 
  /// Retourne l'objet RucheResponse ou null si non trouvé
  Future<RucheResponse?> obtenirRucheParId(String rucheId) async {
    try {
      LoggerService.info('🐝 Récupération de la ruche: $rucheId');
      
      final response = await _apiClient.get(
        '${ApiConfig.ruchesEndpoint}/$rucheId',
      );
      
      final rucheResponse = RucheResponse.fromJson(response.data);
      
      LoggerService.info('🐝 Ruche récupérée avec succès: $rucheId');
      
      return rucheResponse;
      
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        LoggerService.warning('Ruche non trouvée: $rucheId');
        return null;
      }
      
      LoggerService.error('Erreur lors de la récupération de la ruche par ID', e);
      
      if (e is ApiException) {
        rethrow;
      }
      
      throw ApiException('Une erreur inattendue s\'est produite lors de la récupération de la ruche', 500);
    }
  }

  /// Met à jour une ruche existante
  /// 
  /// Paramètres :
  /// - [rucheId] : ID de la ruche à mettre à jour
  /// - [nom] : nouveau nom (optionnel)
  /// - [position] : nouvelle position (optionnel)
  /// - [typeRuche] : nouveau type de ruche (optionnel)
  /// - [description] : nouvelle description (optionnel)
  /// - [enService] : nouveau statut de service (optionnel)
  /// - [dateInstallation] : nouvelle date d'installation (optionnel)
  /// 
  /// Retourne l'objet RucheResponse mis à jour
  Future<RucheResponse> mettreAJourRuche({
    required String rucheId,
    String? nom,
    String? position,
    String? typeRuche,
    String? description,
    bool? enService,
    DateTime? dateInstallation,
  }) async {
    try {
      LoggerService.info('🐝 Mise à jour de la ruche: $rucheId');
      
      final Map<String, dynamic> updateData = {};
      
      if (nom != null) updateData['nom'] = nom.trim();
      if (position != null) updateData['position'] = position.trim();
      if (typeRuche != null) updateData['typeRuche'] = typeRuche;
      if (description != null) updateData['description'] = description;
      if (enService != null) updateData['enService'] = enService;
      if (dateInstallation != null) {
        updateData['dateInstallation'] = dateInstallation.toIso8601String();
      }
      
      if (updateData.isEmpty) {
        throw ApiException('Aucune donnée à mettre à jour', 400);
      }
      
      final response = await _apiClient.put(
        '${ApiConfig.ruchesEndpoint}/$rucheId',
        data: updateData,
      );
      
      final rucheResponse = RucheResponse.fromJson(response.data);
      
      LoggerService.info('🐝 Ruche mise à jour avec succès: $rucheId');
      
      return rucheResponse;
      
    } catch (e) {
      LoggerService.error('Erreur lors de la mise à jour de la ruche', e);
      
      if (e is ApiException) {
        rethrow;
      }
      
      throw ApiException('Une erreur inattendue s\'est produite lors de la mise à jour de la ruche', 500);
    }
  }

  /// Supprime une ruche (suppression logique)
  /// 
  /// Paramètres :
  /// - [rucheId] : ID de la ruche à supprimer
  /// 
  /// Retourne true si la suppression a réussi
  Future<bool> supprimerRuche(String rucheId) async {
    try {
      LoggerService.info('🐝 Suppression de la ruche: $rucheId');
      
      await _apiClient.delete('${ApiConfig.ruchesEndpoint}/$rucheId');
      
      LoggerService.info('🐝 Ruche supprimée avec succès: $rucheId');
      
      return true;
      
    } catch (e) {
      LoggerService.error('Erreur lors de la suppression de la ruche', e);
      
      if (e is ApiException) {
        rethrow;
      }
      
      throw ApiException('Une erreur inattendue s\'est produite lors de la suppression de la ruche', 500);
    }
  }

  /// Vérifie la santé de l'API
  /// 
  /// Retourne un objet HealthResponse avec le statut de l'API
  Future<HealthResponse> verifierSanteAPI() async {
    try {
      LoggerService.debug('Vérification de la santé de l\'API');
      
      return await _apiClient.checkHealth();
      
    } catch (e) {
      LoggerService.error('Erreur lors de la vérification de la santé de l\'API', e);
      
      if (e is ApiException) {
        rethrow;
      }
      
      throw ApiException('Impossible de vérifier la santé de l\'API', 500);
    }
  }

  /// Méthode utilitaire pour convertir une ApiException en message utilisateur
  String getErrorMessage(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 400:
          return 'Données invalides. Veuillez vérifier vos informations.';
        case 401:
          return 'Authentification requise. Veuillez vous reconnecter.';
        case 403:
          return 'Accès refusé. Vous n\'avez pas les permissions nécessaires.';
        case 404:
          return 'Élément non trouvé.';
        case 409:
          return 'Conflit de données. L\'élément existe déjà.';
        case 500:
          return 'Erreur du serveur. Veuillez réessayer plus tard.';
        case 503:
          return 'Service temporairement indisponible.';
        default:
          return error.message;
      }
    }
    
    return 'Une erreur inattendue s\'est produite.';
  }
} 