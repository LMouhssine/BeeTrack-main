import 'package:ruche_connectee/config/api_config.dart';
import 'package:ruche_connectee/models/api_models.dart';
import 'package:ruche_connectee/services/api_client_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';

/// Exception personnalisée pour les erreurs d'API de ruches
class RucheApiException implements Exception {
  final String message;
  final int statusCode;
  final String? code;

  RucheApiException(this.message, this.statusCode, [this.code]);

  @override
  String toString() {
    return 'RucheApiException: $message (Status: $statusCode)';
  }
}

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
  /// Lève une RucheApiException en cas d'erreur
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
      LoggerService.info('🐝 Ajout d\'une nouvelle ruche via API: $nom dans le rucher: $idRucher');
      
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
      
      final rucheResponse = RucheResponse.fromJson(response.data as Map<String, dynamic>);
      
      LoggerService.info('🐝 Ruche créée avec succès via API. ID: ${rucheResponse.id}');
      
      return rucheResponse;
      
    } catch (e) {
      LoggerService.error('Erreur lors de l\'ajout de la ruche via API', e);
      
      if (e is ApiException) {
        throw RucheApiException(e.message, e.statusCode);
      }
      
      throw RucheApiException('Une erreur inattendue s\'est produite lors de l\'ajout de la ruche', 500);
    }
  }
  
  /// Récupère toutes les ruches d'un utilisateur
  /// 
  /// Retourne une liste des ruches de l'utilisateur connecté
  Future<List<RucheResponse>> obtenirRuchesUtilisateur() async {
    try {
      LoggerService.info('🐝 Récupération des ruches de l\'utilisateur (API)');
      
      final response = await _apiClient.get(ApiConfig.ruchesEndpoint);
      
      final List<dynamic> ruchesJson = response.data as List<dynamic>;
      final List<RucheResponse> ruches = ruchesJson
          .map((json) => RucheResponse.fromJson(json as Map<String, dynamic>))
          .toList();
      
      LoggerService.info('🐝 ${ruches.length} ruche(s) récupérée(s) avec succès (API)');
      
      return ruches;
      
    } catch (e) {
      LoggerService.error('Erreur lors de la récupération des ruches utilisateur', e);
      
      if (e is ApiException) {
        throw RucheApiException(e.message, e.statusCode);
      }
      
      throw RucheApiException('Une erreur inattendue s\'est produite lors de la récupération des ruches', 500);
    }
  }
  
  /// Récupère toutes les ruches d'un rucher spécifique
  /// 
  /// Paramètres :
  /// - [idRucher] : ID du rucher
  /// 
  /// Retourne une liste des ruches triées par nom croissant
  Future<List<RucheResponse>> obtenirRuchesParRucher(String idRucher) async {
    try {
      LoggerService.info('🐝 Récupération des ruches pour le rucher: $idRucher (API - triées par nom)');
      
      final response = await _apiClient.get(
        '${ApiConfig.ruchesEndpoint}/rucher/$idRucher',
      );
      
      final List<dynamic> ruchesJson = response.data as List<dynamic>;
      final List<RucheResponse> ruches = ruchesJson
          .map((json) => RucheResponse.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Tri supplémentaire côté client pour garantir l'ordre par nom
      // (le backend Spring Boot fait déjà le tri, mais on s'assure)
      _trierRuchesParNom(ruches);
      
      LoggerService.info('🐝 ${ruches.length} ruche(s) récupérée(s) avec succès pour le rucher: $idRucher (API - triées par nom)');
      
      return ruches;
      
    } catch (e) {
      LoggerService.error('Erreur lors de la récupération des ruches par rucher', e);
      
      if (e is ApiException) {
        throw RucheApiException(e.message, e.statusCode);
      }
      
      throw RucheApiException('Une erreur inattendue s\'est produite lors de la récupération des ruches', 500);
    }
  }

  /// Récupère les mesures des 7 derniers jours d'une ruche
  /// 
  /// Paramètres :
  /// - [idRuche] : ID de la ruche
  /// 
  /// Retourne une liste des mesures triées par date croissante
  Future<List<DonneesCapteur>> obtenirMesures7DerniersJours(String idRuche) async {
    try {
      LoggerService.info('📊 Récupération des mesures des 7 derniers jours pour la ruche: $idRuche (API)');
      
      final response = await _apiClient.get(
        ApiConfig.mesures7JoursUrl(idRuche),
      );
      
      final List<dynamic> mesuresJson = response.data as List<dynamic>;
      final List<DonneesCapteur> mesures = mesuresJson
          .map((json) => DonneesCapteur.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Tri par timestamp croissant (au cas où le backend n'aurait pas trié)
      mesures.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      LoggerService.info('📊 ${mesures.length} mesure(s) récupérée(s) avec succès pour la ruche: $idRuche (7 derniers jours)');
      
      return mesures;
      
    } catch (e) {
      LoggerService.error('Erreur lors de la récupération des mesures des 7 derniers jours', e);
      
      if (e is ApiException) {
        throw RucheApiException(e.message, e.statusCode);
      }
      
      throw RucheApiException('Une erreur inattendue s\'est produite lors de la récupération des mesures', 500);
    }
  }

  /// Récupère la dernière mesure d'une ruche
  /// 
  /// Paramètres :
  /// - [idRuche] : ID de la ruche
  /// 
  /// Retourne la dernière mesure ou null si aucune mesure n'est disponible
  Future<DonneesCapteur?> obtenirDerniereMesure(String idRuche) async {
    try {
      LoggerService.info('📊 Récupération de la dernière mesure pour la ruche: $idRuche (API)');
      
      final response = await _apiClient.get(
        ApiConfig.derniereMesureUrl(idRuche),
      );
      
      if (response.data == null) {
        LoggerService.info('📊 Aucune mesure disponible pour la ruche: $idRuche');
        return null;
      }
      
      final mesure = DonneesCapteur.fromJson(response.data as Map<String, dynamic>);
      
      LoggerService.info('📊 Dernière mesure récupérée avec succès pour la ruche: $idRuche (${mesure.timestamp})');
      
      return mesure;
      
    } catch (e) {
      LoggerService.error('Erreur lors de la récupération de la dernière mesure', e);
      
      if (e is ApiException && e.statusCode == 404) {
        return null; // Aucune mesure trouvée
      }
      
      if (e is ApiException) {
        throw RucheApiException(e.message, e.statusCode);
      }
      
      throw RucheApiException('Une erreur inattendue s\'est produite lors de la récupération de la dernière mesure', 500);
    }
  }

  /// Trie une liste de ruches par nom croissant (insensible à la casse)
  /// 
  /// Paramètres :
  /// - [ruches] : liste des ruches à trier (modifiée en place)
  void _trierRuchesParNom(List<RucheResponse> ruches) {
    ruches.sort((a, b) {
      final nomA = a.nom.toLowerCase();
      final nomB = b.nom.toLowerCase();
      return nomA.compareTo(nomB);
    });
  }

  /// Récupère une ruche par son ID
  /// 
  /// Paramètres :
  /// - [idRuche] : ID de la ruche
  /// 
  /// Retourne l'objet RucheResponse ou null si non trouvé
  Future<RucheResponse?> obtenirRucheParId(String idRuche) async {
    try {
      LoggerService.info('🐝 Récupération de la ruche: $idRuche (API)');
      
      final response = await _apiClient.get(
        ApiConfig.rucheByIdUrl(idRuche),
      );
      
      final rucheResponse = RucheResponse.fromJson(response.data as Map<String, dynamic>);
      
      LoggerService.info('🐝 Ruche récupérée avec succès: ${rucheResponse.nom}');
      
      return rucheResponse;
      
    } catch (e) {
      LoggerService.error('Erreur lors de la récupération de la ruche par ID', e);
      
      if (e is ApiException && e.statusCode == 404) {
        return null; // Ruche non trouvée
      }
      
      if (e is ApiException) {
        throw RucheApiException(e.message, e.statusCode);
      }
      
      throw RucheApiException('Une erreur inattendue s\'est produite lors de la récupération de la ruche', 500);
    }
  }

  /// Supprime une ruche
  /// 
  /// Paramètres :
  /// - [idRuche] : ID de la ruche à supprimer
  Future<void> supprimerRuche(String idRuche) async {
    try {
      LoggerService.info('🐝 Suppression de la ruche: $idRuche (API)');
      
      await _apiClient.delete(ApiConfig.rucheByIdUrl(idRuche));
      
      LoggerService.info('🐝 Ruche supprimée avec succès: $idRuche');
      
    } catch (e) {
      LoggerService.error('Erreur lors de la suppression de la ruche', e);
      
      if (e is ApiException) {
        throw RucheApiException(e.message, e.statusCode);
      }
      
      throw RucheApiException('Une erreur inattendue s\'est produite lors de la suppression de la ruche', 500);
    }
  }

  /// Vérifie la santé de l'API
  Future<HealthResponse> verifierSanteAPI() async {
    try {
      LoggerService.info('🏥 Vérification de la santé de l\'API ruches');
      
      final response = await _apiClient.get(ApiConfig.healthEndpoint);
      
      final healthResponse = HealthResponse.fromJson(response.data as Map<String, dynamic>);
      
      LoggerService.info('🏥 Santé de l\'API: ${healthResponse.status}');
      
      return healthResponse;
      
    } catch (e) {
      LoggerService.error('Erreur lors de la vérification de la santé de l\'API', e);
      
      if (e is ApiException) {
        throw RucheApiException(e.message, e.statusCode);
      }
      
      throw RucheApiException('Une erreur inattendue s\'est produite lors de la vérification de la santé de l\'API', 500);
    }
  }
} 