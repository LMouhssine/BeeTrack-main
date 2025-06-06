import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ruche_connectee/models/api_models.dart';
import 'package:ruche_connectee/services/api_ruche_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';

/// Interface pour les règles d'ignore d'alerte
class AlerteIgnoreRule {
  final String rucheId;
  final int timestamp;
  final int dureeMs;
  final String type; // 'session' | 'temporaire'

  AlerteIgnoreRule({
    required this.rucheId,
    required this.timestamp,
    required this.dureeMs,
    required this.type,
  });

  factory AlerteIgnoreRule.fromJson(Map<String, dynamic> json) {
    return AlerteIgnoreRule(
      rucheId: json['rucheId'] as String,
      timestamp: json['timestamp'] as int,
      dureeMs: json['dureeMs'] as int,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rucheId': rucheId,
      'timestamp': timestamp,
      'dureeMs': dureeMs,
      'type': type,
    };
  }
}

/// Callback pour les événements d'alerte
typedef AlerteCallback = void Function(String rucheId, DonneesCapteur mesure);
typedef ErreurCallback = void Function(String rucheId, String erreur);

/// Service singleton pour la gestion des alertes de couvercle
class AlerteCouvercleService {
  static AlerteCouvercleService? _instance;
  static AlerteCouvercleService get instance {
    _instance ??= AlerteCouvercleService._();
    return _instance!;
  }

  AlerteCouvercleService._();

  final Map<String, Timer> _surveillanceTimers = {};
  final Map<String, AlerteCallback> _alerteCallbacks = {};
  final Map<String, ErreurCallback> _erreurCallbacks = {};
  final Map<String, String> _ruchesNoms = {};
  
  static const String _storageKey = 'beetrackAlertesIgnore';
  static const int _intervalMs = 30000; // 30 secondes
  
  late ApiRucheService _apiRucheService;

  /// Initialise le service avec les dépendances
  void init(ApiRucheService apiRucheService) {
    _apiRucheService = apiRucheService;
  }

  /// Démarre la surveillance d'une ruche
  void demarrerSurveillance(
    String rucheId,
    String apiculteurId, {
    String? rucheNom,
    AlerteCallback? onAlerte,
    ErreurCallback? onErreur,
  }) {
    LoggerService.info('🚨 Démarrage surveillance ruche $rucheId');
    
    // Arrêter la surveillance existante si elle existe
    arreterSurveillance(rucheId);
    
    // Enregistrer le nom de la ruche
    if (rucheNom != null) {
      _ruchesNoms[rucheId] = rucheNom;
    }
    
    // Enregistrer les callbacks
    if (onAlerte != null) {
      _alerteCallbacks[rucheId] = onAlerte;
    }
    if (onErreur != null) {
      _erreurCallbacks[rucheId] = onErreur;
    }
    
    // Fonction de surveillance
    void surveillerRuche() async {
      try {
        LoggerService.info('🔍 Vérification ruche $rucheId');
        
        // Récupérer la dernière mesure (plus efficace que les 7 derniers jours)
        final derniereMesure = await _apiRucheService.obtenirDerniereMesure(rucheId);
        
        if (derniereMesure != null) {
          if (derniereMesure.couvercleOuvert == true) {
            LoggerService.info('⚠️ Couvercle ouvert détecté pour ruche $rucheId');
            
            // Vérifier si l'alerte doit être ignorée
            if (!await _doitIgnorerAlerte(rucheId)) {
              final callback = _alerteCallbacks[rucheId];
              callback?.call(rucheId, derniereMesure);
            } else {
              LoggerService.info('🔇 Alerte ignorée pour ruche $rucheId');
            }
          } else {
            LoggerService.info('✅ Couvercle fermé pour ruche $rucheId');
          }
        } else {
          LoggerService.info('📊 Aucune mesure disponible pour ruche $rucheId');
        }
        
      } catch (e) {
        LoggerService.error('❌ Erreur surveillance ruche $rucheId', e);
        final erreurCallback = _erreurCallbacks[rucheId];
        erreurCallback?.call(rucheId, e.toString());
      }
    }
    
    // Première vérification immédiate
    surveillerRuche();
    
    // Programmer les vérifications périodiques
    final timer = Timer.periodic(
      const Duration(milliseconds: _intervalMs),
      (_) => surveillerRuche(),
    );
    
    _surveillanceTimers[rucheId] = timer;
  }

  /// Arrête la surveillance d'une ruche
  void arreterSurveillance(String rucheId) {
    final timer = _surveillanceTimers[rucheId];
    if (timer != null) {
      timer.cancel();
      _surveillanceTimers.remove(rucheId);
      _alerteCallbacks.remove(rucheId);
      _erreurCallbacks.remove(rucheId);
      LoggerService.info('🛑 Surveillance arrêtée pour ruche $rucheId');
    }
  }

  /// Arrête toutes les surveillances
  void arreterToutesSurveillances() {
    for (final timer in _surveillanceTimers.values) {
      timer.cancel();
    }
    _surveillanceTimers.clear();
    _alerteCallbacks.clear();
    _erreurCallbacks.clear();
    LoggerService.info('🛑 Toutes les surveillances arrêtées');
  }

  /// Ignore temporairement l'alerte pour une ruche
  Future<void> ignorerAlerte(String rucheId, double dureeHeures) async {
    final rule = AlerteIgnoreRule(
      rucheId: rucheId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      dureeMs: (dureeHeures * 60 * 60 * 1000).round(), // Convertir heures en millisecondes
      type: 'temporaire',
    );
    
    await _sauvegarderRegleIgnore(rule);
    LoggerService.info('🔇 Alerte ignorée pour ${dureeHeures}h pour ruche $rucheId');
  }

  /// Ignore l'alerte pour la session courante
  Future<void> ignorerPourSession(String rucheId) async {
    final rule = AlerteIgnoreRule(
      rucheId: rucheId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      dureeMs: 0, // Pas de limite de temps pour session
      type: 'session',
    );
    
    await _sauvegarderRegleIgnore(rule);
    LoggerService.info('🔇 Alerte ignorée pour la session pour ruche $rucheId');
  }

  /// Vérifie si une alerte doit être ignorée
  Future<bool> _doitIgnorerAlerte(String rucheId) async {
    final rules = await _obtenirReglesIgnore();
    final maintenant = DateTime.now().millisecondsSinceEpoch;
    
    for (final rule in rules) {
      if (rule.rucheId == rucheId) {
        if (rule.type == 'session') {
          return true; // Ignorer pour toute la session
        }
        
        if (rule.type == 'temporaire') {
          final finIgnore = rule.timestamp + rule.dureeMs;
          if (maintenant < finIgnore) {
            return true; // Encore dans la période d'ignore
          }
        }
      }
    }
    
    // Nettoyer les règles expirées
    await _nettoyerReglesExpirees();
    return false;
  }

  /// Sauvegarde une règle d'ignore dans SharedPreferences
  Future<void> _sauvegarderRegleIgnore(AlerteIgnoreRule rule) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rules = await _obtenirReglesIgnore();
      
      // Supprimer les anciennes règles pour cette ruche
      final rulesFiltrees = rules.where((r) => r.rucheId != rule.rucheId).toList();
      rulesFiltrees.add(rule);
      
      // Convertir en JSON et sauvegarder
      final rulesJsonList = rulesFiltrees.map((r) => r.toJson()).toList();
      final jsonString = jsonEncode(rulesJsonList);
      await prefs.setString(_storageKey, jsonString);
      
      LoggerService.info('💾 Règle ignore sauvegardée pour ruche ${rule.rucheId}');
    } catch (e) {
      LoggerService.error('Erreur sauvegarde règle ignore', e);
    }
  }

  /// Récupère les règles d'ignore depuis SharedPreferences
  Future<List<AlerteIgnoreRule>> _obtenirReglesIgnore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final rules = jsonList
            .map((json) => AlerteIgnoreRule.fromJson(json as Map<String, dynamic>))
            .toList();
        
        LoggerService.info('📖 ${rules.length} règle(s) ignore récupérée(s)');
        return rules;
      }
      return [];
    } catch (e) {
      LoggerService.error('Erreur lecture règles ignore', e);
      // En cas d'erreur, nettoyer les données corrompues
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_storageKey);
      } catch (cleanupError) {
        LoggerService.error('Erreur nettoyage données corrompues', cleanupError);
      }
      return [];
    }
  }

  /// Nettoie les règles expirées
  Future<void> _nettoyerReglesExpirees() async {
    try {
      final rules = await _obtenirReglesIgnore();
      final maintenant = DateTime.now().millisecondsSinceEpoch;
      
      final rulesValides = rules.where((rule) {
        if (rule.type == 'session') return true; // Les règles de session ne expirent pas automatiquement
        if (rule.type == 'temporaire') {
          return maintenant < (rule.timestamp + rule.dureeMs);
        }
        return false;
      }).toList();
      
      if (rulesValides.length != rules.length) {
        final prefs = await SharedPreferences.getInstance();
        final rulesJsonList = rulesValides.map((r) => r.toJson()).toList();
        final jsonString = jsonEncode(rulesJsonList);
        await prefs.setString(_storageKey, jsonString);
        
        final nombreSupprimees = rules.length - rulesValides.length;
        LoggerService.info('🧹 $nombreSupprimees règle(s) expirée(s) nettoyée(s)');
      }
    } catch (e) {
      LoggerService.error('Erreur nettoyage règles', e);
    }
  }

  /// Réactive les alertes pour une ruche
  Future<void> reactiverAlertes(String rucheId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rules = await _obtenirReglesIgnore();
      final rulesFiltrees = rules.where((r) => r.rucheId != rucheId).toList();
      
      final rulesJsonList = rulesFiltrees.map((r) => r.toJson()).toList();
      final jsonString = jsonEncode(rulesJsonList);
      await prefs.setString(_storageKey, jsonString);
      
      LoggerService.info('🔊 Alertes réactivées pour ruche $rucheId');
    } catch (e) {
      LoggerService.error('Erreur réactivation alertes', e);
    }
  }

  /// Supprime toutes les règles de session (utile lors de la fermeture de l'app)
  Future<void> nettoyerReglesSession() async {
    try {
      final rules = await _obtenirReglesIgnore();
      final rulesNonSession = rules.where((rule) => rule.type != 'session').toList();
      
      if (rulesNonSession.length != rules.length) {
        final prefs = await SharedPreferences.getInstance();
        final rulesJsonList = rulesNonSession.map((r) => r.toJson()).toList();
        final jsonString = jsonEncode(rulesJsonList);
        await prefs.setString(_storageKey, jsonString);
        
        final nombreSupprimees = rules.length - rulesNonSession.length;
        LoggerService.info('🧹 $nombreSupprimees règle(s) de session nettoyée(s)');
      }
    } catch (e) {
      LoggerService.error('Erreur nettoyage règles session', e);
    }
  }

  /// Obtient le statut d'ignore pour une ruche
  Future<Map<String, dynamic>> obtenirStatutIgnore(String rucheId) async {
    final rules = await _obtenirReglesIgnore();
    final maintenant = DateTime.now().millisecondsSinceEpoch;
    
    for (final rule in rules) {
      if (rule.rucheId == rucheId) {
        if (rule.type == 'session') {
          return {
            'ignore': true, 
            'type': 'session',
            'message': 'Ignoré pour cette session'
          };
        }
        
        if (rule.type == 'temporaire') {
          final finIgnore = rule.timestamp + rule.dureeMs;
          if (maintenant < finIgnore) {
            return {
              'ignore': true,
              'type': 'temporaire',
              'finIgnore': DateTime.fromMillisecondsSinceEpoch(finIgnore),
              'tempsRestant': finIgnore - maintenant,
            };
          }
        }
      }
    }
    
    return {'ignore': false};
  }

  /// Obtient la liste des ruches en surveillance
  Set<String> get ruchesEnSurveillance => _surveillanceTimers.keys.toSet();

  /// Obtient le nom d'une ruche
  String? obtenirNomRuche(String rucheId) => _ruchesNoms[rucheId];

  /// Obtient des statistiques sur les règles d'ignore
  Future<Map<String, dynamic>> obtenirStatistiques() async {
    final rules = await _obtenirReglesIgnore();
    final maintenant = DateTime.now().millisecondsSinceEpoch;
    
    int reglesSession = 0;
    int reglesTemporaireActives = 0;
    int reglesTemporaireExpirees = 0;
    
    for (final rule in rules) {
      if (rule.type == 'session') {
        reglesSession++;
      } else if (rule.type == 'temporaire') {
        final finIgnore = rule.timestamp + rule.dureeMs;
        if (maintenant < finIgnore) {
          reglesTemporaireActives++;
        } else {
          reglesTemporaireExpirees++;
        }
      }
    }
    
    return {
      'totalRuchers': rules.length,
      'reglesSession': reglesSession,
      'reglesTemporaireActives': reglesTemporaireActives,
      'reglesTemporaireExpirees': reglesTemporaireExpirees,
      'ruchesEnSurveillance': _surveillanceTimers.length,
    };
  }
} 