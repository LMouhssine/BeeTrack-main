import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';

class RucherService {
  final FirebaseService _firebaseService;
  
  RucherService(this._firebaseService);
  
  // Collection Firestore pour les ruchers
  static const String _collectionRuchers = 'ruchers';
  
  /// Ajoute un nouveau rucher dans Firebase Firestore
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
      final User? currentUser = _firebaseService.auth.currentUser;
      if (currentUser == null) {
        LoggerService.error('Tentative d\'ajout de rucher sans utilisateur connecté');
        throw Exception('Utilisateur non connecté. Veuillez vous connecter pour ajouter un rucher.');
      }
      
      LoggerService.debug('Utilisateur connecté: ${currentUser.uid}');
      
      // Préparer les données du rucher
      final Map<String, dynamic> rucherData = {
        'idApiculteur': currentUser.uid,
        'nom': nom.trim(),
        'adresse': adresse.trim(),
        'description': description.trim(),
        'dateCreation': FieldValue.serverTimestamp(),
        // Champs additionnels pour la compatibilité avec le backend
        'actif': true,
        'nombreRuches': 0,
      };
      
      LoggerService.debug('Données du rucher à créer: $rucherData');
      
      // Ajouter le document dans Firestore
      final DocumentReference docRef = await _firebaseService.firestore
          .collection(_collectionRuchers)
          .add(rucherData);
      
      LoggerService.info('Rucher créé avec succès. ID: ${docRef.id}');
      
      return docRef.id;
      
    } catch (e) {
      LoggerService.error('Erreur lors de l\'ajout du rucher', e);
      
      // Gestion spécifique des erreurs Firebase
      if (e is FirebaseException) {
        switch (e.code) {
          case 'permission-denied':
            throw Exception('Permissions insuffisantes pour créer un rucher');
          case 'unavailable':
            throw Exception('Service temporairement indisponible. Veuillez réessayer.');
          default:
            throw Exception('Erreur Firebase: ${e.message}');
        }
      }
      
      // Re-lancer l'exception si elle est déjà formatée
      if (e is Exception) {
        rethrow;
      }
      
      // Erreur générique
      throw Exception('Une erreur inattendue s\'est produite lors de l\'ajout du rucher: $e');
    }
  }
  
  /// Récupère tous les ruchers de l'utilisateur connecté
  Future<List<Map<String, dynamic>>> obtenirRuchersUtilisateur() async {
    try {
      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      LoggerService.info('Récupération des ruchers pour l\'utilisateur: ${currentUser.uid}');
      
      final QuerySnapshot querySnapshot = await _firebaseService.firestore
          .collection(_collectionRuchers)
          .where('idApiculteur', isEqualTo: currentUser.uid)
          .get();
      
      final List<Map<String, dynamic>> ruchers = querySnapshot.docs
          .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['actif'] == true; // Filtrer côté client
          })
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          })
          .toList();
      
      // Trier côté client par date de création
      ruchers.sort((a, b) {
        final dateA = a['dateCreation'] as Timestamp?;
        final dateB = b['dateCreation'] as Timestamp?;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA); // Ordre décroissant
      });
      
      LoggerService.info('${ruchers.length} rucher(s) trouvé(s)');
      
      return ruchers;
      
    } catch (e) {
      LoggerService.error('Erreur lors de la récupération des ruchers', e);
      rethrow;
    }
  }
  
  /// Récupère un rucher spécifique par son ID
  Future<Map<String, dynamic>?> obtenirRucherParId(String rucherId) async {
    try {
      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      LoggerService.info('Récupération du rucher: $rucherId');
      
      final DocumentSnapshot docSnapshot = await _firebaseService.firestore
          .collection(_collectionRuchers)
          .doc(rucherId)
          .get();
      
      if (!docSnapshot.exists) {
        LoggerService.warning('Rucher non trouvé: $rucherId');
        return null;
      }
      
      final data = docSnapshot.data() as Map<String, dynamic>;
      
      // Vérifier que le rucher appartient à l'utilisateur connecté
      if (data['idApiculteur'] != currentUser.uid) {
        LoggerService.warning('Tentative d\'accès à un rucher non autorisé: $rucherId');
        throw Exception('Accès non autorisé à ce rucher');
      }
      
      data['id'] = docSnapshot.id;
      
      LoggerService.info('Rucher récupéré avec succès: $rucherId');
      
      return data;
      
    } catch (e) {
      LoggerService.error('Erreur lors de la récupération du rucher', e);
      rethrow;
    }
  }
  
  /// Met à jour un rucher existant
  Future<void> mettreAJourRucher({
    required String rucherId,
    required String nom,
    required String adresse,
    required String description,
  }) async {
    try {
      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      LoggerService.info('Mise à jour du rucher: $rucherId');
      
      // Vérifier que le rucher existe et appartient à l'utilisateur
      final rucherExistant = await obtenirRucherParId(rucherId);
      if (rucherExistant == null) {
        throw Exception('Rucher non trouvé');
      }
      
      // Préparer les données de mise à jour
      final Map<String, dynamic> updateData = {
        'nom': nom.trim(),
        'adresse': adresse.trim(),
        'description': description.trim(),
        'dateModification': FieldValue.serverTimestamp(),
      };
      
      // Mettre à jour le document
      await _firebaseService.firestore
          .collection(_collectionRuchers)
          .doc(rucherId)
          .update(updateData);
      
      LoggerService.info('Rucher mis à jour avec succès: $rucherId');
      
    } catch (e) {
      LoggerService.error('Erreur lors de la mise à jour du rucher', e);
      rethrow;
    }
  }
  
  /// Supprime un rucher (suppression logique)
  Future<void> supprimerRucher(String rucherId) async {
    try {
      // Vérifier que l'utilisateur est connecté
      final User? currentUser = _firebaseService.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      LoggerService.info('Suppression du rucher: $rucherId');
      
      // Vérifier que le rucher existe et appartient à l'utilisateur
      final rucherExistant = await obtenirRucherParId(rucherId);
      if (rucherExistant == null) {
        throw Exception('Rucher non trouvé');
      }
      
      // Vérifier qu'il n'y a pas de ruches dans ce rucher
      final QuerySnapshot ruchesSnapshot = await _firebaseService.firestore
          .collection('ruches')
          .where('rucher_id', isEqualTo: rucherId)
          .where('actif', isEqualTo: true)
          .get();
      
      if (ruchesSnapshot.docs.isNotEmpty) {
        throw Exception('Impossible de supprimer un rucher contenant des ruches actives');
      }
      
      // Suppression logique (marquer comme inactif)
      await _firebaseService.firestore
          .collection(_collectionRuchers)
          .doc(rucherId)
          .update({
        'actif': false,
        'dateSuppression': FieldValue.serverTimestamp(),
      });
      
      LoggerService.info('Rucher supprimé avec succès: $rucherId');
      
    } catch (e) {
      LoggerService.error('Erreur lors de la suppression du rucher', e);
      rethrow;
    }
  }
  
  /// Stream pour écouter les changements des ruchers de l'utilisateur connecté
  Stream<List<Map<String, dynamic>>> ecouterRuchersUtilisateur() {
    final User? currentUser = _firebaseService.auth.currentUser;
    if (currentUser == null) {
      return Stream.error(Exception('Utilisateur non connecté'));
    }
    
    return _firebaseService.firestore
        .collection(_collectionRuchers)
        .where('idApiculteur', isEqualTo: currentUser.uid)
        .snapshots()
        .map((querySnapshot) {
      final ruchers = querySnapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['actif'] == true; // Filtrer côté client
          })
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .toList();
      
      // Trier côté client par date de création
      ruchers.sort((a, b) {
        final dateA = a['dateCreation'] as Timestamp?;
        final dateB = b['dateCreation'] as Timestamp?;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA); // Ordre décroissant
      });
      
      return ruchers;
    });
  }
} 