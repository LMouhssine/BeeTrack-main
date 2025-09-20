import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruche_connectee/services/firebase_realtime_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';

class RucherService {
  final FirebaseRealtimeService _firebaseService;

  RucherService(this._firebaseService);

  // Collection Realtime Database pour les ruchers
  static const String _collectionRuchers = 'ruchers';

  /// Ajoute un nouveau rucher dans Firebase Realtime Database
  ///
  /// Paramètres :
  /// - [nom] : nom du rucher
  /// - [adresse] : adresse texte du rucher
  /// - [description] : description du rucher
  ///
  /// Retourne l'ID du document créé
  ///
  /// Lève une exception si l'utilisateur n'est pas connecté
  Future<String> ajouterRucher({
    required String nom,
    required String adresse,
    required String description,
  }) async {
    try {
      LoggerService.info('Tentative d\'ajout d\'un nouveau rucher: $nom');

      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        LoggerService.error(
            'Tentative d\'ajout de rucher sans utilisateur connecté');
        throw Exception(
            'Utilisateur non connecté. Veuillez vous connecter pour ajouter un rucher.');
      }

      LoggerService.debug('Utilisateur connecté: ${currentUser.uid}');

      // Préparer les données du rucher
      final Map<String, dynamic> rucherData = {
        'idApiculteur': currentUser.uid,
        'nom': nom.trim(),
        'adresse': adresse.trim(),
        'description': description.trim(),
        'dateCreation': DateTime.now().millisecondsSinceEpoch,
        // Champs additionnels pour la compatibilité avec le backend
        'actif': true,
        'nombreRuches': 0,
      };

      LoggerService.debug('Données du rucher à créer: $rucherData');

      // Générer un ID unique pour le rucher
      final String rucherId = DateTime.now().millisecondsSinceEpoch.toString();

      // Ajouter le document dans Realtime Database
      await _firebaseService.setDocument(_collectionRuchers, rucherId, rucherData);

      LoggerService.info('Rucher créé avec succès. ID: $rucherId');

      return rucherId;
    } catch (e) {
      LoggerService.error('Erreur lors de l\'ajout du rucher', e);

      // Re-lancer l'exception si elle est déjà formatée
      if (e is Exception) {
        rethrow;
      }

      // Erreur générique
      throw Exception(
          'Une erreur inattendue s\'est produite lors de l\'ajout du rucher: $e');
    }
  }

  /// Récupère tous les ruchers de l'utilisateur connecté
  ///
  /// Retourne une liste triée par date de création (plus récent en premier)
  Future<List<Map<String, dynamic>>> obtenirRuchersUtilisateurOptimise() async {
    try {
      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        LoggerService.error(
            'Tentative de récupération des ruchers sans utilisateur connecté');
        throw Exception(
            'Utilisateur non connecté. Veuillez vous connecter pour accéder aux ruchers.');
      }

      LoggerService.info(
          'Récupération des ruchers pour l\'utilisateur: ${currentUser.uid}');

      // Récupérer tous les ruchers et filtrer par utilisateur
      final List<Map<String, dynamic>> tousRuchers = await _firebaseService
          .getAllDocuments(_collectionRuchers);

      final List<Map<String, dynamic>> ruchers = tousRuchers
          .where((rucher) =>
              rucher['idApiculteur'] == currentUser.uid && rucher['actif'] == true)
          .toList();

      // Trier par date de création décroissante (plus récent en premier)
      ruchers.sort((a, b) {
        final dateA = a['dateCreation'] as int? ?? 0;
        final dateB = b['dateCreation'] as int? ?? 0;
        return dateB.compareTo(dateA);
      });

      LoggerService.info(
          '${ruchers.length} rucher(s) trouvé(s) pour l\'utilisateur');

      return ruchers;
    } catch (e) {
      LoggerService.error(
          'Erreur lors de la récupération des ruchers utilisateur', e);
      rethrow;
    }
  }

  /// Récupère tous les ruchers de l'utilisateur connecté (alias pour la compatibilité)
  ///
  /// Retourne une liste triée par date de création (plus récent en premier)
  Future<List<Map<String, dynamic>>> obtenirRuchersUtilisateur() async {
    return obtenirRuchersUtilisateurOptimise();
  }

  /// Récupère un rucher spécifique par son ID
  ///
  /// Paramètres :
  /// - [rucherId] : ID du rucher
  ///
  /// Retourne les données du rucher ou null si non trouvé
  Future<Map<String, dynamic>?> obtenirRucherParId(String rucherId) async {
    try {
      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      LoggerService.info('Récupération du rucher: $rucherId');

      final Map<String, dynamic>? data = await _firebaseService
          .getDocument(_collectionRuchers, rucherId);

      if (data == null) {
        LoggerService.warning('Rucher non trouvé: $rucherId');
        return null;
      }

      // Vérifier que le rucher appartient à l'utilisateur connecté
      if (data['idApiculteur'] != currentUser.uid) {
        LoggerService.warning(
            'Tentative d\'accès à un rucher non autorisé: $rucherId');
        throw Exception('Accès non autorisé à ce rucher');
      }

      data['id'] = rucherId;

      LoggerService.info('Rucher récupéré avec succès: $rucherId');

      return data;
    } catch (e) {
      LoggerService.error('Erreur lors de la récupération du rucher', e);
      rethrow;
    }
  }

  /// Met à jour un rucher existant
  ///
  /// Paramètres :
  /// - [rucherId] : ID du rucher à mettre à jour
  /// - [nom] : nouveau nom du rucher (optionnel)
  /// - [adresse] : nouvelle adresse du rucher (optionnel)
  /// - [description] : nouvelle description du rucher (optionnel)
  Future<void> mettreAJourRucher({
    required String rucherId,
    String? nom,
    String? adresse,
    String? description,
  }) async {
    try {
      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      LoggerService.info('Mise à jour du rucher: $rucherId');

      // Vérifier que le rucher existe et appartient à l'utilisateur
      final rucherExistante = await obtenirRucherParId(rucherId);
      if (rucherExistante == null) {
        throw Exception('Rucher non trouvé');
      }

      // Préparer les données de mise à jour
      final Map<String, dynamic> updateData = {
        'dateModification': DateTime.now().millisecondsSinceEpoch,
      };

      if (nom != null) updateData['nom'] = nom.trim();
      if (adresse != null) updateData['adresse'] = adresse.trim();
      if (description != null) updateData['description'] = description.trim();

      // Mettre à jour le document
      await _firebaseService.updateDocument(
          _collectionRuchers, rucherId, updateData);

      LoggerService.info('Rucher mis à jour avec succès: $rucherId');
    } catch (e) {
      LoggerService.error('Erreur lors de la mise à jour du rucher', e);
      rethrow;
    }
  }

  /// Supprime un rucher (suppression logique)
  ///
  /// Paramètres :
  /// - [rucherId] : ID du rucher à supprimer
  Future<void> supprimerRucher(String rucherId) async {
    try {
      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      LoggerService.info('Suppression du rucher: $rucherId');

      // Vérifier que le rucher existe et appartient à l'utilisateur
      final rucherExistante = await obtenirRucherParId(rucherId);
      if (rucherExistante == null) {
        throw Exception('Rucher non trouvé');
      }

      // Suppression logique du rucher
      await _firebaseService.updateDocument(_collectionRuchers, rucherId, {
        'actif': false,
        'dateSuppression': DateTime.now().millisecondsSinceEpoch,
      });

      LoggerService.info('Rucher supprimé avec succès: $rucherId');
    } catch (e) {
      LoggerService.error('Erreur lors de la suppression du rucher', e);
      rethrow;
    }
  }

  /// Stream pour écouter les changements des ruchers de l'utilisateur en temps réel
  ///
  /// Retourne un stream de la liste des ruchers triés par date de création
  Stream<List<Map<String, dynamic>>> ecouterRuchersUtilisateur() {
    final User? currentUser = _firebaseService.currentUser;
    if (currentUser == null) {
      return Stream.error(Exception('Utilisateur non connecté'));
    }

    LoggerService.info(
        'Démarrage de l\'écoute temps réel des ruchers utilisateur');

    return _firebaseService
        .watchCollection(_collectionRuchers)
        .map((tousRuchers) {
      final ruchers = tousRuchers
          .where((rucher) =>
              rucher['idApiculteur'] == currentUser.uid && rucher['actif'] == true)
          .toList();

      // Trier par date de création décroissante (plus récent en premier)
      ruchers.sort((a, b) {
        final dateA = a['dateCreation'] as int? ?? 0;
        final dateB = b['dateCreation'] as int? ?? 0;
        return dateB.compareTo(dateA);
      });

      LoggerService.debug(
          'Mise à jour temps réel: ${ruchers.length} rucher(s) utilisateur');

      return ruchers;
    });
  }

  /// Récupère tous les ruchers de l'utilisateur avec tri par nom
  ///
  /// Retourne une liste triée par nom croissant (insensible à la casse)
  Future<List<Map<String, dynamic>>> obtenirRuchersUtilisateurTriesParNom() async {
    try {
      final List<Map<String, dynamic>> ruchers = await obtenirRuchersUtilisateur();

      // Trier par nom croissant (insensible à la casse)
      ruchers.sort((a, b) {
        final nomA = (a['nom'] as String?)?.toLowerCase() ?? '';
        final nomB = (b['nom'] as String?)?.toLowerCase() ?? '';
        return nomA.compareTo(nomB);
      });

      LoggerService.info(
          '${ruchers.length} rucher(s) trié(s) par nom pour l\'utilisateur');

      return ruchers;
    } catch (e) {
      LoggerService.error(
          'Erreur lors de la récupération des ruchers triés par nom', e);
      rethrow;
    }
  }
}
