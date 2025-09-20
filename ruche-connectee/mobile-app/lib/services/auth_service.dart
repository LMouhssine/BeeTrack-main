import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruche_connectee/services/firebase_realtime_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';

/// Service d'authentification utilisant Firebase Realtime Database
/// Remplace l'ancien service qui utilisait Firestore
class AuthService {
  final FirebaseRealtimeService _firebaseService = FirebaseRealtimeService();

  /// Récupère l'utilisateur actuellement connecté
  User? get currentUser => _firebaseService.currentUser;

  /// Stream des changements d'état d'authentification
  Stream<User?> get authStateChanges => _firebaseService.authStateChanges;

  /// Connexion avec email et mot de passe
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      LoggerService.info('Connexion: $email');

      // D'abord essayer de s'authentifier avec Firebase Auth
              final userCredential = await _firebaseService.signInWithEmailAndPassword(
          email,
          password,
        );

      if (userCredential.user != null) {
        LoggerService.info(
            'Connexion réussie pour: ${userCredential.user!.email}');

        // Maintenant que l'utilisateur est authentifié, vérifier s'il existe dans Realtime Database
        try {
          final userData = await _firebaseService.getDocument(
            'apiculteurs',
            userCredential.user!.uid,
          );

          if (userData == null) {
            LoggerService.warning(
                'Utilisateur authentifié mais pas trouvé dans Realtime Database');
            // L'utilisateur est authentifié mais pas dans la base, on peut le créer
            await _firebaseService.setDocument(
              'apiculteurs',
              userCredential.user!.uid,
              {
                'email': email,
                'name': userCredential.user!.displayName ?? 'Utilisateur',
                'createdAt': DateTime.now().millisecondsSinceEpoch,
                'role': 'apiculteur',
              },
            );
            LoggerService.info('Document utilisateur créé dans Realtime Database');
          }
        } catch (databaseError) {
          LoggerService.warning(
              'Erreur lors de la vérification Realtime Database: $databaseError');
          // Continuer même si la vérification échoue
        }

        return userCredential.user;
      } else {
        LoggerService.error('Connexion échouée: user est null');
        return null;
      }
    } catch (e) {
      LoggerService.error('Erreur lors de la connexion', e);
      rethrow;
    }
  }

  // Inscription avec email et mot de passe
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential =
          await _firebaseService.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (userCredential.user == null) {
        LoggerService.error('Échec de création du compte');
        return null;
      }

      // Mettre à jour le profil utilisateur
      await userCredential.user!.updateDisplayName(name);

      // Créer un document utilisateur dans Realtime Database
      await _firebaseService.setDocument(
        'apiculteurs',
        userCredential.user!.uid,
        {
          'email': email,
          'name': name,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'role': 'apiculteur',
        },
      );

      return userCredential.user!;
    } catch (e) {
      LoggerService.error('Erreur lors de l\'inscription', e);
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _firebaseService.signOut();
    LoggerService.info('Utilisateur déconnecté');
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      LoggerService.info(
          'Tentative de réinitialisation du mot de passe pour: $email');
      await _firebaseService.sendPasswordResetEmail(email);
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
      final users = await _firebaseService.getDocuments(
        'apiculteurs',
        'identifiant',
        username,
      );

      if (users.isNotEmpty) {
        final userData = users.first;
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

  // Créer un utilisateur Firebase Auth à partir des données Realtime Database
  Future<User?> createUserFromFirestore(String email, String password) async {
    try {
      LoggerService.info(
          'Tentative de création d\'un utilisateur avec email: $email');

      try {
        // Essayer de créer l'utilisateur directement
        final userCredential =
            await _firebaseService.createUserWithEmailAndPassword(
          email,
          password,
        );

        if (userCredential.user != null) {
          // Maintenant que l'utilisateur est authentifié, créer le document Realtime Database
          await _firebaseService.setDocument(
            'apiculteurs',
            userCredential.user!.uid,
            {
              'email': email,
              'name': userCredential.user!.displayName ?? 'Utilisateur',
              'createdAt': DateTime.now().millisecondsSinceEpoch,
              'role': 'apiculteur',
            },
          );

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
              await _firebaseService.signInWithEmailAndPassword(
            email,
            password,
          );

          // Vérifier si le document Realtime Database existe
          try {
            final userData = await _firebaseService.getDocument(
              'apiculteurs',
              signInCredential.user!.uid,
            );

            if (userData == null) {
              // Créer le document s'il n'existe pas
              await _firebaseService.setDocument(
                'apiculteurs',
                signInCredential.user!.uid,
                {
                  'email': email,
                  'name': signInCredential.user!.displayName ?? 'Utilisateur',
                  'createdAt': DateTime.now().millisecondsSinceEpoch,
                  'role': 'apiculteur',
                },
              );
              LoggerService.info('Document utilisateur créé dans Realtime Database');
            }
          } catch (databaseError) {
            LoggerService.warning(
                'Erreur lors de la vérification Realtime Database: $databaseError');
          }

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
