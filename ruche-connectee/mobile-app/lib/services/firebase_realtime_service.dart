import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ruche_connectee/services/logger_service.dart';

/// Service Firebase utilisant Realtime Database (comme l'application web)
/// Remplace le service Firestore par Realtime Database
class FirebaseRealtimeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Récupère l'utilisateur actuellement connecté
  User? get currentUser => _auth.currentUser;

  /// Stream des changements d'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Connexion avec email et mot de passe
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      LoggerService.info('Tentative de connexion avec: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      LoggerService.info('Connexion réussie pour: ${credential.user?.email}');
      return credential;
    } catch (e) {
      LoggerService.error('Erreur lors de la connexion', e);
      rethrow;
    }
  }

  /// Création d'un compte avec email et mot de passe
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      LoggerService.info('Tentative de création de compte pour: $email');
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      LoggerService.info('Compte créé avec succès pour: ${credential.user?.email}');
      return credential;
    } catch (e) {
      LoggerService.error('Erreur lors de la création du compte', e);
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      LoggerService.info('Utilisateur déconnecté');
    } catch (e) {
      LoggerService.error('Erreur lors de la déconnexion', e);
      rethrow;
    }
  }

  /// Réinitialisation du mot de passe
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      LoggerService.info('Envoi email de réinitialisation pour: $email');
      await _auth.sendPasswordResetEmail(email: email);
      LoggerService.info('Email de réinitialisation envoyé');
    } catch (e) {
      LoggerService.error('Erreur lors de l\'envoi de l\'email', e);
      rethrow;
    }
  }

  /// Récupère un document par ID dans une collection (Realtime Database)
  Future<Map<String, dynamic>?> getDocument(String collection, String documentId) async {
    try {
      final ref = _database.ref('$collection/$documentId');
      final snapshot = await ref.get();
      
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data['id'] = documentId;
        LoggerService.info('Document récupéré: $collection/$documentId');
        return data;
      } else {
        LoggerService.warning('Document non trouvé: $collection/$documentId');
        return null;
      }
    } catch (e) {
      LoggerService.error('Erreur lors de la récupération du document', e);
      rethrow;
    }
  }

  /// Récupère tous les documents d'une collection avec un filtre
  Future<List<Map<String, dynamic>>> getDocuments(
    String collection,
    String field,
    dynamic value,
  ) async {
    try {
      final ref = _database.ref(collection);
      final snapshot = await ref.orderByChild(field).equalTo(value).get();
      
      final documents = <Map<String, dynamic>>[];
      for (final child in snapshot.children) {
        if (child.value != null) {
          final data = Map<String, dynamic>.from(child.value as Map);
          data['id'] = child.key;
          documents.add(data);
        }
      }
      
      LoggerService.info('${documents.length} documents récupérés de $collection');
      return documents;
    } catch (e) {
      LoggerService.error('Erreur lors de la récupération des documents', e);
      rethrow;
    }
  }

  /// Récupère tous les documents d'une collection
  Future<List<Map<String, dynamic>>> getAllDocuments(String collection) async {
    try {
      final ref = _database.ref(collection);
      final snapshot = await ref.get();
      
      final documents = <Map<String, dynamic>>[];
      for (final child in snapshot.children) {
        if (child.value != null) {
          final data = Map<String, dynamic>.from(child.value as Map);
          data['id'] = child.key;
          documents.add(data);
        }
      }
      
      LoggerService.info('${documents.length} documents récupérés de $collection');
      return documents;
    } catch (e) {
      LoggerService.error('Erreur lors de la récupération des documents', e);
      rethrow;
    }
  }

  /// Crée ou met à jour un document
  Future<void> setDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final ref = _database.ref('$collection/$documentId');
      await ref.set(data);
      LoggerService.info('Document créé/mis à jour: $collection/$documentId');
    } catch (e) {
      LoggerService.error('Erreur lors de la création/mise à jour du document', e);
      rethrow;
    }
  }

  /// Met à jour un document existant
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final ref = _database.ref('$collection/$documentId');
      await ref.update(data);
      LoggerService.info('Document mis à jour: $collection/$documentId');
    } catch (e) {
      LoggerService.error('Erreur lors de la mise à jour du document', e);
      rethrow;
    }
  }

  /// Supprime un document
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      final ref = _database.ref('$collection/$documentId');
      await ref.remove();
      LoggerService.info('Document supprimé: $collection/$documentId');
    } catch (e) {
      LoggerService.error('Erreur lors de la suppression du document', e);
      rethrow;
    }
  }

  /// Écoute les changements en temps réel d'un document
  Stream<Map<String, dynamic>?> watchDocument(String collection, String documentId) {
    final ref = _database.ref('$collection/$documentId');
    return ref.onValue.map((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data['id'] = documentId;
        return data;
      }
      return null;
    });
  }

  /// Écoute les changements en temps réel d'une collection
  Stream<List<Map<String, dynamic>>> watchCollection(String collection) {
    final ref = _database.ref(collection);
    return ref.onValue.map((event) {
      final documents = <Map<String, dynamic>>[];
      for (final child in event.snapshot.children) {
        if (child.value != null) {
          final data = Map<String, dynamic>.from(child.value as Map);
          data['id'] = child.key;
          documents.add(data);
        }
      }
      return documents;
    });
  }
}

