import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';

class AuthService {
  final FirebaseService _firebaseService;

  AuthService(this._firebaseService);

  // Obtenir l'utilisateur actuellement connecté
  Future<User?> getCurrentUser() async {
    return _firebaseService.auth.currentUser;
  }

  // Connexion avec email et mot de passe
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      LoggerService.info('Connexion: $email');

      final querySnapshot = await _firebaseService.firestore
          .collection('apiculteurs')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userCredential =
            await _firebaseService.auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          LoggerService.info(
              'Connexion réussie pour: ${userCredential.user!.email}');
          return userCredential.user;
        } else {
          LoggerService.error('Connexion échouée: user est null');
          return null;
        }
      }
    } catch (e) {
      LoggerService.error('Erreur lors de la connexion', e);
      rethrow;
    }
    return null;
  }

  // Inscription avec email et mot de passe
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential =
          await _firebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        LoggerService.error('Échec de création du compte');
        return null;
      }

      // Mettre à jour le profil utilisateur
      await userCredential.user!.updateDisplayName(name);

      // Créer un document utilisateur dans Firestore
      await _firebaseService.firestore
          .collection('apiculteurs')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'apiculteur',
      });

      return userCredential.user!;
    } catch (e) {
      LoggerService.error('Erreur lors de l\'inscription', e);
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _firebaseService.auth.signOut();
    LoggerService.info('Utilisateur déconnecté');
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      LoggerService.info(
          'Tentative de réinitialisation du mot de passe pour: $email');
      await _firebaseService.auth.sendPasswordResetEmail(email: email);
      LoggerService.info('Email de réinitialisation envoyé avec succès');
    } catch (e) {
      LoggerService.error(
          'Erreur lors de la réinitialisation du mot de passe', e);
      throw _handleAuthException(e);
    }
  }

  // Connexion avec identifiant et mot de passe
  Future<User?> signInWithUsername(String username, String password) async {
    try {
      // Rechercher l'email correspondant au nom d'utilisateur
      final querySnapshot = await _firebaseService.firestore
          .collection('apiculteurs')
          .where('identifiant', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final email = userData['email'] as String;

        // Utiliser l'email pour la connexion
        return await signInWithEmailAndPassword(email, password);
      } else {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Aucun utilisateur trouvé avec cet identifiant',
        );
      }
    } catch (e) {
      LoggerService.error('Erreur lors de la connexion avec identifiant', e);
      rethrow;
    }
  }

  // Créer un utilisateur Firebase Auth à partir des données Firestore
  Future<User?> createUserFromFirestore(String email, String password) async {
    try {
      LoggerService.info(
          'Tentative de création d\'un utilisateur avec email: $email');

      // Vérifier d'abord si l'utilisateur existe dans Firestore
      final querySnapshot = await _firebaseService.firestore
          .collection('apiculteurs')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        LoggerService.error(
            'Aucun utilisateur trouvé dans Firestore avec cet email');
        return null;
      }

      final userData = querySnapshot.docs.first.data();

      try {
        // Essayer de créer l'utilisateur
        final userCredential =
            await _firebaseService.auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          // Mettre à jour le profil utilisateur
          await userCredential.user!.updateDisplayName(userData['nom'] ?? '');
          LoggerService.info(
              'Compte créé avec succès pour l\'utilisateur: ${userCredential.user!.uid}');
          return userCredential.user!;
        }
      } catch (authError) {
        LoggerService.error('Erreur lors de la création', authError);
        // Si l'utilisateur existe déjà, essayer de se connecter directement
        if (authError is FirebaseAuthException &&
            authError.code == 'email-already-in-use') {
          LoggerService.info(
              'L\'utilisateur existe déjà, tentative de connexion directe');
          final signInCredential =
              await _firebaseService.auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          return signInCredential.user;
        }
        rethrow;
      }

      LoggerService.error('Échec de création du compte');
      return null;
    } catch (e) {
      LoggerService.error('Erreur lors de la création du compte', e);
      rethrow;
    }
  }

  // Gestion des exceptions Firebase Auth
  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      LoggerService.warning('FirebaseAuthException: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          return Exception('Aucun utilisateur trouvé avec cet email');
        case 'wrong-password':
          return Exception('Mot de passe incorrect');
        case 'email-already-in-use':
          return Exception('Cet email est déjà utilisé par un autre compte');
        case 'weak-password':
          return Exception('Le mot de passe est trop faible');
        case 'invalid-email':
          return Exception('Format d\'email invalide');
        default:
          return Exception('Erreur d\'authentification: ${e.message}');
      }
    }
    return Exception('Une erreur s\'est produite: $e');
  }
}
