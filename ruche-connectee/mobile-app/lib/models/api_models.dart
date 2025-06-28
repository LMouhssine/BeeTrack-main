import 'dart:convert';

/// Modèle pour la création d'une ruche (requête)
class CreateRucheRequest {
  final String idRucher;
  final String nom;
  final String position;
  final String? typeRuche;
  final String? description;
  final bool enService;
  final DateTime? dateInstallation;

  CreateRucheRequest({
    required this.idRucher,
    required this.nom,
    required this.position,
    this.typeRuche,
    this.description,
    this.enService = true,
    this.dateInstallation,
  });

  Map<String, dynamic> toJson() {
    return {
      'idRucher': idRucher,
      'nom': nom,
      'position': position,
      if (typeRuche != null) 'typeRuche': typeRuche,
      if (description != null) 'description': description,
      'enService': enService,
      if (dateInstallation != null)
        'dateInstallation': dateInstallation!.toIso8601String(),
    };
  }

  String toJsonString() => json.encode(toJson());
}

/// Modèle pour la réponse d'une ruche
class RucheResponse {
  final String id;
  final String idRucher;
  final String nom;
  final String position;
  final String? typeRuche;
  final String? description;
  final bool enService;
  final DateTime? dateInstallation;
  final DateTime dateCreation;
  final bool actif;
  final String idApiculteur;

  // Informations du rucher (enrichies par l'API)
  final String? rucherNom;
  final String? rucherVille;
  final String? rucherAdresse;

  RucheResponse({
    required this.id,
    required this.idRucher,
    required this.nom,
    required this.position,
    this.typeRuche,
    this.description,
    required this.enService,
    this.dateInstallation,
    required this.dateCreation,
    required this.actif,
    required this.idApiculteur,
    this.rucherNom,
    this.rucherVille,
    this.rucherAdresse,
  });

  factory RucheResponse.fromJson(Map<String, dynamic> json) {
    return RucheResponse(
      id: json['id'] as String,
      idRucher: json['idRucher'] as String,
      nom: json['nom'] as String,
      position: json['position'] as String,
      typeRuche: json['typeRuche'] as String?,
      description: json['description'] as String?,
      enService: json['enService'] as bool,
      dateInstallation: json['dateInstallation'] != null
          ? DateTime.parse(json['dateInstallation'] as String)
          : null,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      actif: json['actif'] as bool,
      idApiculteur: json['idApiculteur'] as String,
      rucherNom: json['rucherNom'] as String?,
      rucherVille: json['rucherVille'] as String?,
      rucherAdresse: json['rucherAdresse'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idRucher': idRucher,
      'nom': nom,
      'position': position,
      if (typeRuche != null) 'typeRuche': typeRuche,
      if (description != null) 'description': description,
      'enService': enService,
      if (dateInstallation != null)
        'dateInstallation': dateInstallation!.toIso8601String(),
      'dateCreation': dateCreation.toIso8601String(),
      'actif': actif,
      'idApiculteur': idApiculteur,
      if (rucherNom != null) 'rucherNom': rucherNom,
      if (rucherVille != null) 'rucherVille': rucherVille,
      if (rucherAdresse != null) 'rucherAdresse': rucherAdresse,
    };
  }
}

/// Modèle pour les données des capteurs IoT d'une ruche
class DonneesCapteur {
  final String id;
  final String rucheId;
  final DateTime timestamp;
  final double? temperature;
  final double? humidity;
  final bool? couvercleOuvert;
  final int? batterie;
  final int? signalQualite;
  final String? erreur;

  DonneesCapteur({
    required this.id,
    required this.rucheId,
    required this.timestamp,
    this.temperature,
    this.humidity,
    this.couvercleOuvert,
    this.batterie,
    this.signalQualite,
    this.erreur,
  });

  factory DonneesCapteur.fromJson(Map<String, dynamic> json) {
    return DonneesCapteur(
      id: json['id'] as String,
      rucheId: json['rucheId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      temperature: json['temperature'] as double?,
      humidity: json['humidity'] as double?,
      couvercleOuvert: json['couvercleOuvert'] as bool?,
      batterie: json['batterie'] as int?,
      signalQualite: json['signalQualite'] as int?,
      erreur: json['erreur'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rucheId': rucheId,
      'timestamp': timestamp.toIso8601String(),
      if (temperature != null) 'temperature': temperature,
      if (humidity != null) 'humidity': humidity,
      if (couvercleOuvert != null) 'couvercleOuvert': couvercleOuvert,
      if (batterie != null) 'batterie': batterie,
      if (signalQualite != null) 'signalQualite': signalQualite,
      if (erreur != null) 'erreur': erreur,
    };
  }
}

/// Modèle pour les réponses d'erreur de l'API
class ApiErrorResponse {
  final int status;
  final String message;
  final String? details;
  final DateTime timestamp;

  ApiErrorResponse({
    required this.status,
    required this.message,
    this.details,
    required this.timestamp,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      details: json['details'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Modèle pour la réponse de health check
class HealthResponse {
  final String status;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  HealthResponse({
    required this.status,
    required this.timestamp,
    this.details,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  bool get isHealthy =>
      status.toLowerCase() == 'up' || status.toLowerCase() == 'ok';
}
