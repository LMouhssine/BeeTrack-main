import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruche_connectee/services/firebase_realtime_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';

class RucheService {
  final FirebaseRealtimeService _firebaseService;

  RucheService(this._firebaseService);

  // Collections Realtime Database pour les ruches
  static const String _collectionRuches = 'ruches';
  static const String _collectionRuchers = 'ruchers';

  /// Ajoute une nouvelle ruche dans Firebase Realtime Database
  ///
  /// Paramètres :
  /// - [idRucher] : ID du rucher auquel appartient la ruche
  /// - [nom] : nom de la ruche
  /// - [position] : position de la ruche dans le rucher
  /// - [enService] : statut de service (par défaut true)
  /// - [dateInstallation] : date d'installation (optionnel, utilise la date actuelle par défaut)
  ///
  /// Retourne l'ID du document créé
  ///
  /// Lève une exception si l'utilisateur n'est pas connecté ou si le rucher n'existe pas
  Future<String> ajouterRuche({
    required String idRucher,
    required String nom,
    required String position,
    bool enService = true,
    DateTime? dateInstallation,
  }) async {
    try {
      LoggerService.info(
          '🐝 Tentative d\'ajout d\'une nouvelle ruche: $nom dans le rucher: $idRucher');

      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        LoggerService.error(
            'Tentative d\'ajout de ruche sans utilisateur connecté');
        throw Exception(
            'Utilisateur non connecté. Veuillez vous connecter pour ajouter une ruche.');
      }

      LoggerService.debug('Utilisateur connecté: ${currentUser.uid}');

      // Vérifier que le rucher existe et appartient à l'utilisateur
      final Map<String, dynamic>? rucherDoc = await _firebaseService
          .getDocument(_collectionRuchers, idRucher);

      if (rucherDoc == null) {
        LoggerService.error('Rucher non trouvé: $idRucher');
        throw Exception('Le rucher spécifié n\'existe pas.');
      }

      // Vérifier que le rucher appartient à l'utilisateur connecté
      if (rucherDoc['idApiculteur'] != currentUser.uid) {
        LoggerService.error(
            'Tentative d\'ajout de ruche dans un rucher non autorisé: $idRucher');
        throw Exception(
            'Vous n\'êtes pas autorisé à ajouter une ruche dans ce rucher.');
      }

      // Vérifier que le rucher est actif
      if (rucherDoc['actif'] != true) {
        LoggerService.error(
            'Tentative d\'ajout de ruche dans un rucher inactif: $idRucher');
        throw Exception(
            'Impossible d\'ajouter une ruche dans un rucher inactif.');
      }

      LoggerService.debug('Rucher validé pour l\'ajout de ruche');

      // Préparer les données de la ruche
      final Map<String, dynamic> rucheData = {
        'idRucher': idRucher,
        'nom': nom.trim(),
        'position': position.trim(),
        'enService': enService,
        'dateInstallation': dateInstallation != null
            ? dateInstallation.millisecondsSinceEpoch
            : DateTime.now().millisecondsSinceEpoch,
        'dateCreation': DateTime.now().millisecondsSinceEpoch,
        // Champs additionnels pour la compatibilité
        'actif': true,
        'idApiculteur': currentUser.uid, // Pour faciliter les requêtes
      };

      LoggerService.debug('Données de la ruche à créer: $rucheData');

      // Générer un ID unique pour la ruche
      final String rucheId = DateTime.now().millisecondsSinceEpoch.toString();

      // Ajouter la ruche
      await _firebaseService.setDocument(_collectionRuches, rucheId, rucheData);

      // Mettre à jour le nombre de ruches dans le rucher
      final int nombreRuchesActuel = rucherDoc['nombreRuches'] ?? 0;
      await _firebaseService.updateDocument(_collectionRuchers, idRucher, {
        'nombreRuches': nombreRuchesActuel + 1,
        'dateModification': DateTime.now().millisecondsSinceEpoch,
      });

      LoggerService.info('🐝 Ruche créée avec succès. ID: $rucheId');

      return rucheId;
    } catch (e) {
      LoggerService.error('Erreur lors de l\'ajout de la ruche', e);

      // Gestion spécifique des erreurs Firebase
      if (e is Exception) {
        rethrow;
      }

      // Erreur générique
      throw Exception(
          'Une erreur inattendue s\'est produite lors de l\'ajout de la ruche: $e');
    }
  }

  /// Récupère toutes les ruches d'un rucher spécifique, triées par nom croissant
  ///
  /// Paramètres :
  /// - [idRucher] : ID du rucher
  ///
  /// Retourne une liste des ruches triées par nom croissant
  Future<List<Map<String, dynamic>>> obtenirRuchesParRucherTrieesParNom(
      String idRucher) async {
    try {
      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        LoggerService.error(
            'Tentative de récupération des ruches sans utilisateur connecté');
        throw Exception(
            'Utilisateur non connecté. Veuillez vous connecter pour accéder aux ruches.');
      }

      LoggerService.info(
          '🐝 Récupération des ruches pour le rucher: $idRucher (triées par nom)');

      // Vérifier que le rucher existe et appartient à l'utilisateur
      final Map<String, dynamic>? rucherDoc = await _firebaseService
          .getDocument(_collectionRuchers, idRucher);

      if (rucherDoc == null) {
        throw Exception('Le rucher spécifié n\'existe pas.');
      }

      if (rucherDoc['idApiculteur'] != currentUser.uid) {
        throw Exception(
            'Vous n\'êtes pas autorisé à accéder aux ruches de ce rucher.');
      }

      // Récupérer toutes les ruches et filtrer par rucher
      final List<Map<String, dynamic>> toutesRuches = await _firebaseService
          .getAllDocuments(_collectionRuches);

      final List<Map<String, dynamic>> ruches = toutesRuches
          .where((ruche) =>
              ruche['idRucher'] == idRucher && ruche['actif'] == true)
          .toList();

      // Trier par nom croissant (insensible à la casse)
      ruches.sort((a, b) {
        final nomA = (a['nom'] as String?)?.toLowerCase() ?? '';
        final nomB = (b['nom'] as String?)?.toLowerCase() ?? '';
        return nomA.compareTo(nomB);
      });

      LoggerService.info(
          '🐝 ${ruches.length} ruche(s) récupérée(s) avec succès pour le rucher: $idRucher (triées par nom)');

      return ruches;
    } catch (e) {
      LoggerService.error(
          'Erreur lors de la récupération des ruches triées par nom', e);
      rethrow;
    }
  }

  /// Récupère toutes les ruches d'un rucher spécifique
  ///
  /// Paramètres :
  /// - [idRucher] : ID du rucher
  ///
  /// Retourne une liste des ruches triées par nom croissant (nouvelle version)
  Future<List<Map<String, dynamic>>> obtenirRuchesParRucher(
      String idRucher) async {
    // Utiliser la nouvelle méthode avec tri par nom
    return obtenirRuchesParRucherTrieesParNom(idRucher);
  }

  /// Récupère toutes les ruches de l'utilisateur connecté
  ///
  /// Retourne une liste de toutes les ruches appartenant à l'utilisateur
  Future<List<Map<String, dynamic>>> obtenirRuchesUtilisateur() async {
    try {
      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      LoggerService.info(
          'Récupération de toutes les ruches pour l\'utilisateur: ${currentUser.uid}');

      final List<Map<String, dynamic>> toutesRuches = await _firebaseService
          .getAllDocuments(_collectionRuches);

      final List<Map<String, dynamic>> ruches = toutesRuches
          .where((ruche) =>
              ruche['idApiculteur'] == currentUser.uid && ruche['actif'] == true)
          .toList();

      // Trier par date de création décroissante
      ruches.sort((a, b) {
        final dateA = a['dateCreation'] as int? ?? 0;
        final dateB = b['dateCreation'] as int? ?? 0;
        return dateB.compareTo(dateA);
      });

      LoggerService.info(
          '${ruches.length} ruche(s) trouvée(s) pour l\'utilisateur');

      return ruches;
    } catch (e) {
      LoggerService.error(
          'Erreur lors de la récupération des ruches utilisateur', e);
      rethrow;
    }
  }

  /// Récupère une ruche spécifique par son ID
  ///
  /// Paramètres :
  /// - [rucheId] : ID de la ruche
  ///
  /// Retourne les données de la ruche ou null si non trouvée
  Future<Map<String, dynamic>?> obtenirRucheParId(String rucheId) async {
    try {
      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      LoggerService.info('Récupération de la ruche: $rucheId');

      final Map<String, dynamic>? data = await _firebaseService
          .getDocument(_collectionRuches, rucheId);

      if (data == null) {
        LoggerService.warning('Ruche non trouvée: $rucheId');
        return null;
      }

      // Vérifier que la ruche appartient à l'utilisateur connecté
      if (data['idApiculteur'] != currentUser.uid) {
        LoggerService.warning(
            'Tentative d\'accès à une ruche non autorisée: $rucheId');
        throw Exception('Accès non autorisé à cette ruche');
      }

      data['id'] = rucheId;

      LoggerService.info('Ruche récupérée avec succès: $rucheId');

      return data;
    } catch (e) {
      LoggerService.error('Erreur lors de la récupération de la ruche', e);
      rethrow;
    }
  }

  /// Met à jour une ruche existante
  ///
  /// Paramètres :
  /// - [rucheId] : ID de la ruche à mettre à jour
  /// - [nom] : nouveau nom de la ruche (optionnel)
  /// - [position] : nouvelle position de la ruche (optionnel)
  /// - [enService] : nouveau statut de service (optionnel)
  /// - [dateInstallation] : nouvelle date d'installation (optionnel)
  Future<void> mettreAJourRuche({
    required String rucheId,
    String? nom,
    String? position,
    bool? enService,
    DateTime? dateInstallation,
  }) async {
    try {
      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      LoggerService.info('Mise à jour de la ruche: $rucheId');

      // Vérifier que la ruche existe et appartient à l'utilisateur
      final rucheExistante = await obtenirRucheParId(rucheId);
      if (rucheExistante == null) {
        throw Exception('Ruche non trouvée');
      }

      // Préparer les données de mise à jour
      final Map<String, dynamic> updateData = {
        'dateModification': DateTime.now().millisecondsSinceEpoch,
      };

      if (nom != null) updateData['nom'] = nom.trim();
      if (position != null) updateData['position'] = position.trim();
      if (enService != null) updateData['enService'] = enService;
      if (dateInstallation != null) {
        updateData['dateInstallation'] = dateInstallation.millisecondsSinceEpoch;
      }

      // Mettre à jour le document
      await _firebaseService.updateDocument(
          _collectionRuches, rucheId, updateData);

      LoggerService.info('Ruche mise à jour avec succès: $rucheId');
    } catch (e) {
      LoggerService.error('Erreur lors de la mise à jour de la ruche', e);
      rethrow;
    }
  }

  /// Supprime une ruche (suppression logique)
  ///
  /// Paramètres :
  /// - [rucheId] : ID de la ruche à supprimer
  Future<void> supprimerRuche(String rucheId) async {
    try {
      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      LoggerService.info('Suppression de la ruche: $rucheId');

      // Vérifier que la ruche existe et appartient à l'utilisateur
      final rucheExistante = await obtenirRucheParId(rucheId);
      if (rucheExistante == null) {
        throw Exception('Ruche non trouvée');
      }

      final String idRucher = rucheExistante['idRucher'];

      // Suppression logique de la ruche
      await _firebaseService.updateDocument(_collectionRuches, rucheId, {
        'actif': false,
        'dateSuppression': DateTime.now().millisecondsSinceEpoch,
      });

      // Décrémenter le nombre de ruches dans le rucher
      final Map<String, dynamic>? rucherDoc = await _firebaseService
          .getDocument(_collectionRuchers, idRucher);
      
      if (rucherDoc != null) {
        final int nombreRuchesActuel = rucherDoc['nombreRuches'] ?? 0;
        await _firebaseService.updateDocument(_collectionRuchers, idRucher, {
          'nombreRuches': nombreRuchesActuel - 1,
          'dateModification': DateTime.now().millisecondsSinceEpoch,
        });
      }

      LoggerService.info('Ruche supprimée avec succès: $rucheId');
    } catch (e) {
      LoggerService.error('Erreur lors de la suppression de la ruche', e);
      rethrow;
    }
  }

  /// Stream pour écouter les changements des ruches d'un rucher en temps réel
  ///
  /// Paramètres :
  /// - [idRucher] : ID du rucher
  ///
  /// Retourne un stream de la liste des ruches triées par nom croissant
  Stream<List<Map<String, dynamic>>> ecouterRuchesParRucher(String idRucher) {
    final User? currentUser = _firebaseService.currentUser;
    if (currentUser == null) {
      LoggerService.error(
          'Tentative d\'écoute des ruches sans utilisateur connecté');
      return Stream.error(Exception(
          'Utilisateur non connecté. Veuillez vous connecter pour écouter les ruches.'));
    }

    LoggerService.info(
        '🐝 Démarrage de l\'écoute temps réel des ruches pour le rucher: $idRucher (triées par nom)');

    return _firebaseService
        .watchCollection(_collectionRuches)
        .map((toutesRuches) {
      final ruches = toutesRuches
          .where((ruche) =>
              ruche['idRucher'] == idRucher && ruche['actif'] == true)
          .toList();

      // Trier par nom croissant (insensible à la casse)
      ruches.sort((a, b) {
        final nomA = (a['nom'] as String?)?.toLowerCase() ?? '';
        final nomB = (b['nom'] as String?)?.toLowerCase() ?? '';
        return nomA.compareTo(nomB);
      });

      LoggerService.debug(
          '🐝 Mise à jour temps réel: ${ruches.length} ruche(s) pour le rucher: $idRucher (triées par nom)');

      return ruches;
    }).handleError((error) {
      LoggerService.error('Erreur dans l\'écoute temps réel des ruches', error);
      throw error;
    });
  }

  /// Stream pour écouter les changements de toutes les ruches de l'utilisateur
  ///
  /// Retourne un stream de la liste de toutes les ruches de l'utilisateur
  Stream<List<Map<String, dynamic>>> ecouterRuchesUtilisateur() {
    final User? currentUser = _firebaseService.currentUser;
    if (currentUser == null) {
      return Stream.error(Exception('Utilisateur non connecté'));
    }

    LoggerService.info(
        'Démarrage de l\'écoute temps réel de toutes les ruches utilisateur');

    return _firebaseService
        .watchCollection(_collectionRuches)
        .map((toutesRuches) {
      final ruches = toutesRuches
          .where((ruche) =>
              ruche['idApiculteur'] == currentUser.uid && ruche['actif'] == true)
          .toList();

      // Trier par date de création décroissante
      ruches.sort((a, b) {
        final dateA = a['dateCreation'] as int? ?? 0;
        final dateB = b['dateCreation'] as int? ?? 0;
        return dateB.compareTo(dateA);
      });

      LoggerService.debug(
          'Mise à jour temps réel: ${ruches.length} ruche(s) utilisateur');

      return ruches;
    });
  }
}
