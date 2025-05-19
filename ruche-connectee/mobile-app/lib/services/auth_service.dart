import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruche_connectee/services/firebase_service.dart';

class AuthService {
  final FirebaseService _firebaseService;
  
  AuthService(this._firebaseService);
  
  // Obtenir l'utilisateur actuellement connecté
  Future<User?> getCurrentUser() async {
    return _firebaseService.auth.currentUser;
  }
  
  // Connexion avec email et mot de passe
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('Échec de connexion');
      }
      
      return userCredential.user!;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Inscription avec email et mot de passe
  Future<User> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await _firebaseService.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('Échec de création du compte');
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
      throw _handleAuthException(e);
    }
  }
  
  // Déconnexion
  Future<void> signOut() async {
    await _firebaseService.auth.signOut();
  }
  
  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseService.auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Gestion des exceptions Firebase Auth
  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
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