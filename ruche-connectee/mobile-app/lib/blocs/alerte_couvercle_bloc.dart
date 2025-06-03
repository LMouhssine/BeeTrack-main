import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ruche_connectee/models/api_models.dart';
import 'package:ruche_connectee/services/alerte_couvercle_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';

// Events
abstract class AlerteCouvercleEvent extends Equatable {
  const AlerteCouvercleEvent();

  @override
  List<Object?> get props => [];
}

class DemarrerSurveillanceEvent extends AlerteCouvercleEvent {
  final String rucheId;
  final String apiculteurId;
  final String? rucheNom;

  const DemarrerSurveillanceEvent({
    required this.rucheId,
    required this.apiculteurId,
    this.rucheNom,
  });

  @override
  List<Object?> get props => [rucheId, apiculteurId, rucheNom];
}

class ArreterSurveillanceEvent extends AlerteCouvercleEvent {
  final String rucheId;

  const ArreterSurveillanceEvent(this.rucheId);

  @override
  List<Object?> get props => [rucheId];
}

class ArreterToutesSurveillancesEvent extends AlerteCouvercleEvent {}

class AlerteDeclenCheeEvent extends AlerteCouvercleEvent {
  final String rucheId;
  final DonneesCapteur mesure;

  const AlerteDeclenCheeEvent({
    required this.rucheId,
    required this.mesure,
  });

  @override
  List<Object?> get props => [rucheId, mesure];
}

class IgnorerAlerteEvent extends AlerteCouvercleEvent {
  final String rucheId;
  final double dureeHeures;

  const IgnorerAlerteEvent({
    required this.rucheId,
    required this.dureeHeures,
  });

  @override
  List<Object?> get props => [rucheId, dureeHeures];
}

class IgnorerPourSessionEvent extends AlerteCouvercleEvent {
  final String rucheId;

  const IgnorerPourSessionEvent(this.rucheId);

  @override
  List<Object?> get props => [rucheId];
}

class FermerAlerteEvent extends AlerteCouvercleEvent {}

class ReactiverAlertesEvent extends AlerteCouvercleEvent {
  final String rucheId;

  const ReactiverAlertesEvent(this.rucheId);

  @override
  List<Object?> get props => [rucheId];
}

class VerifierStatutIgnoreEvent extends AlerteCouvercleEvent {
  final String rucheId;

  const VerifierStatutIgnoreEvent(this.rucheId);

  @override
  List<Object?> get props => [rucheId];
}

class ErreurSurveillanceEvent extends AlerteCouvercleEvent {
  final String rucheId;
  final String erreur;

  const ErreurSurveillanceEvent({
    required this.rucheId,
    required this.erreur,
  });

  @override
  List<Object?> get props => [rucheId, erreur];
}

// State
class AlerteCouvercleState extends Equatable {
  final Set<String> ruchesEnSurveillance;
  final AlerteActive? alerteActive;
  final Map<String, StatutIgnore> statutsIgnore;
  final String? messageErreur;
  final String? messageSucces;

  const AlerteCouvercleState({
    this.ruchesEnSurveillance = const {},
    this.alerteActive,
    this.statutsIgnore = const {},
    this.messageErreur,
    this.messageSucces,
  });

  AlerteCouvercleState copyWith({
    Set<String>? ruchesEnSurveillance,
    AlerteActive? alerteActive,
    Map<String, StatutIgnore>? statutsIgnore,
    String? messageErreur,
    String? messageSucces,
    bool clearAlerte = false,
    bool clearErreur = false,
    bool clearSucces = false,
  }) {
    return AlerteCouvercleState(
      ruchesEnSurveillance: ruchesEnSurveillance ?? this.ruchesEnSurveillance,
      alerteActive: clearAlerte ? null : (alerteActive ?? this.alerteActive),
      statutsIgnore: statutsIgnore ?? this.statutsIgnore,
      messageErreur: clearErreur ? null : (messageErreur ?? this.messageErreur),
      messageSucces: clearSucces ? null : (messageSucces ?? this.messageSucces),
    );
  }

  @override
  List<Object?> get props => [
        ruchesEnSurveillance,
        alerteActive,
        statutsIgnore,
        messageErreur,
        messageSucces,
      ];
}

// Classes utilitaires
class AlerteActive extends Equatable {
  final String rucheId;
  final String? rucheNom;
  final DonneesCapteur mesure;

  const AlerteActive({
    required this.rucheId,
    this.rucheNom,
    required this.mesure,
  });

  @override
  List<Object?> get props => [rucheId, rucheNom, mesure];
}

class StatutIgnore extends Equatable {
  final bool ignore;
  final String? type;
  final DateTime? finIgnore;

  const StatutIgnore({
    required this.ignore,
    this.type,
    this.finIgnore,
  });

  factory StatutIgnore.fromMap(Map<String, dynamic> map) {
    return StatutIgnore(
      ignore: map['ignore'] as bool,
      type: map['type'] as String?,
      finIgnore: map['finIgnore'] as DateTime?,
    );
  }

  @override
  List<Object?> get props => [ignore, type, finIgnore];
}

// BLoC
class AlerteCouvercleBloc extends Bloc<AlerteCouvercleEvent, AlerteCouvercleState> {
  final AlerteCouvercleService _alerteService;

  AlerteCouvercleBloc(this._alerteService) : super(const AlerteCouvercleState()) {
    on<DemarrerSurveillanceEvent>(_onDemarrerSurveillance);
    on<ArreterSurveillanceEvent>(_onArreterSurveillance);
    on<ArreterToutesSurveillancesEvent>(_onArreterToutesSurveillances);
    on<AlerteDeclenCheeEvent>(_onAlerteDeClenchee);
    on<IgnorerAlerteEvent>(_onIgnorerAlerte);
    on<IgnorerPourSessionEvent>(_onIgnorerPourSession);
    on<FermerAlerteEvent>(_onFermerAlerte);
    on<ReactiverAlertesEvent>(_onReactiverAlertes);
    on<VerifierStatutIgnoreEvent>(_onVerifierStatutIgnore);
    on<ErreurSurveillanceEvent>(_onErreurSurveillance);
  }

  Future<void> _onDemarrerSurveillance(
    DemarrerSurveillanceEvent event,
    Emitter<AlerteCouvercleState> emit,
  ) async {
    try {
      _alerteService.demarrerSurveillance(
        event.rucheId,
        event.apiculteurId,
        rucheNom: event.rucheNom,
        onAlerte: (rucheId, mesure) {
          add(AlerteDeclenCheeEvent(rucheId: rucheId, mesure: mesure));
        },
        onErreur: (rucheId, erreur) {
          add(ErreurSurveillanceEvent(rucheId: rucheId, erreur: erreur));
        },
      );

      final nouvelleSurveillance = Set<String>.from(state.ruchesEnSurveillance)
        ..add(event.rucheId);

      emit(state.copyWith(
        ruchesEnSurveillance: nouvelleSurveillance,
        messageSucces: 'Surveillance démarrée pour ${event.rucheNom ?? "ruche ${event.rucheId}"}',
        clearErreur: true,
      ));

      // Vérifier le statut d'ignore pour cette ruche
      add(VerifierStatutIgnoreEvent(event.rucheId));

    } catch (e) {
      LoggerService.error('Erreur démarrage surveillance', e);
      emit(state.copyWith(
        messageErreur: 'Erreur lors du démarrage de la surveillance: ${e.toString()}',
        clearSucces: true,
      ));
    }
  }

  Future<void> _onArreterSurveillance(
    ArreterSurveillanceEvent event,
    Emitter<AlerteCouvercleState> emit,
  ) async {
    try {
      _alerteService.arreterSurveillance(event.rucheId);

      final nouvelleSurveillance = Set<String>.from(state.ruchesEnSurveillance)
        ..remove(event.rucheId);

      final nouvelleAlerte = state.alerteActive?.rucheId == event.rucheId ? null : state.alerteActive;

      final rucheNom = _alerteService.obtenirNomRuche(event.rucheId);

      emit(state.copyWith(
        ruchesEnSurveillance: nouvelleSurveillance,
        alerteActive: nouvelleAlerte,
        messageSucces: 'Surveillance arrêtée pour ${rucheNom ?? "ruche ${event.rucheId}"}',
        clearErreur: true,
      ));

    } catch (e) {
      LoggerService.error('Erreur arrêt surveillance', e);
      emit(state.copyWith(
        messageErreur: 'Erreur lors de l\'arrêt de la surveillance: ${e.toString()}',
        clearSucces: true,
      ));
    }
  }

  Future<void> _onArreterToutesSurveillances(
    ArreterToutesSurveillancesEvent event,
    Emitter<AlerteCouvercleState> emit,
  ) async {
    try {
      _alerteService.arreterToutesSurveillances();

      emit(state.copyWith(
        ruchesEnSurveillance: const {},
        clearAlerte: true,
        messageSucces: 'Toutes les surveillances ont été arrêtées',
        clearErreur: true,
      ));

    } catch (e) {
      LoggerService.error('Erreur arrêt toutes surveillances', e);
      emit(state.copyWith(
        messageErreur: 'Erreur lors de l\'arrêt des surveillances: ${e.toString()}',
        clearSucces: true,
      ));
    }
  }

  Future<void> _onAlerteDeClenchee(
    AlerteDeclenCheeEvent event,
    Emitter<AlerteCouvercleState> emit,
  ) async {
    final rucheNom = _alerteService.obtenirNomRuche(event.rucheId);
    
    final nouvelleAlerte = AlerteActive(
      rucheId: event.rucheId,
      rucheNom: rucheNom,
      mesure: event.mesure,
    );

    emit(state.copyWith(
      alerteActive: nouvelleAlerte,
      clearErreur: true,
      clearSucces: true,
    ));

    LoggerService.info('🚨 Alerte déclenchée pour ruche ${event.rucheId}');
  }

  Future<void> _onIgnorerAlerte(
    IgnorerAlerteEvent event,
    Emitter<AlerteCouvercleState> emit,
  ) async {
    try {
      await _alerteService.ignorerAlerte(event.rucheId, event.dureeHeures);

      final dureeText = event.dureeHeures == 0.5 ? '30 minutes' : 
                       event.dureeHeures == 1 ? '1 heure' : 
                       '${event.dureeHeures} heures';

      final rucheNom = _alerteService.obtenirNomRuche(event.rucheId);

      emit(state.copyWith(
        clearAlerte: true,
        messageSucces: 'Alerte ignorée pour $dureeText pour ${rucheNom ?? "ruche ${event.rucheId}"}',
        clearErreur: true,
      ));

      // Mettre à jour le statut d'ignore
      add(VerifierStatutIgnoreEvent(event.rucheId));

    } catch (e) {
      LoggerService.error('Erreur ignore alerte', e);
      emit(state.copyWith(
        messageErreur: 'Erreur lors de l\'ignore de l\'alerte: ${e.toString()}',
        clearSucces: true,
      ));
    }
  }

  Future<void> _onIgnorerPourSession(
    IgnorerPourSessionEvent event,
    Emitter<AlerteCouvercleState> emit,
  ) async {
    try {
      await _alerteService.ignorerPourSession(event.rucheId);

      final rucheNom = _alerteService.obtenirNomRuche(event.rucheId);

      emit(state.copyWith(
        clearAlerte: true,
        messageSucces: 'Alerte ignorée pour cette session pour ${rucheNom ?? "ruche ${event.rucheId}"}',
        clearErreur: true,
      ));

      // Mettre à jour le statut d'ignore
      add(VerifierStatutIgnoreEvent(event.rucheId));

    } catch (e) {
      LoggerService.error('Erreur ignore session', e);
      emit(state.copyWith(
        messageErreur: 'Erreur lors de l\'ignore pour session: ${e.toString()}',
        clearSucces: true,
      ));
    }
  }

  Future<void> _onFermerAlerte(
    FermerAlerteEvent event,
    Emitter<AlerteCouvercleState> emit,
  ) async {
    emit(state.copyWith(clearAlerte: true));
  }

  Future<void> _onReactiverAlertes(
    ReactiverAlertesEvent event,
    Emitter<AlerteCouvercleState> emit,
  ) async {
    try {
      await _alerteService.reactiverAlertes(event.rucheId);

      final rucheNom = _alerteService.obtenirNomRuche(event.rucheId);

      emit(state.copyWith(
        messageSucces: 'Alertes réactivées pour ${rucheNom ?? "ruche ${event.rucheId}"}',
        clearErreur: true,
      ));

      // Mettre à jour le statut d'ignore
      add(VerifierStatutIgnoreEvent(event.rucheId));

    } catch (e) {
      LoggerService.error('Erreur réactivation alertes', e);
      emit(state.copyWith(
        messageErreur: 'Erreur lors de la réactivation des alertes: ${e.toString()}',
        clearSucces: true,
      ));
    }
  }

  Future<void> _onVerifierStatutIgnore(
    VerifierStatutIgnoreEvent event,
    Emitter<AlerteCouvercleState> emit,
  ) async {
    try {
      final statutMap = await _alerteService.obtenirStatutIgnore(event.rucheId);
      final statut = StatutIgnore.fromMap(statutMap);

      final nouveauxStatuts = Map<String, StatutIgnore>.from(state.statutsIgnore);
      nouveauxStatuts[event.rucheId] = statut;

      emit(state.copyWith(statutsIgnore: nouveauxStatuts));

    } catch (e) {
      LoggerService.error('Erreur vérification statut ignore', e);
    }
  }

  Future<void> _onErreurSurveillance(
    ErreurSurveillanceEvent event,
    Emitter<AlerteCouvercleState> emit,
  ) async {
    final rucheNom = _alerteService.obtenirNomRuche(event.rucheId);
    
    emit(state.copyWith(
      messageErreur: 'Erreur de surveillance pour ${rucheNom ?? "ruche ${event.rucheId}"}: ${event.erreur}',
      clearSucces: true,
    ));
  }

  @override
  Future<void> close() {
    _alerteService.arreterToutesSurveillances();
    return super.close();
  }
} 