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
      print('Tentative de connexion avec email: $email');
      
      // Vérifier d'abord les données dans Firestore
      final querySnapshot = await _firebaseService.firestore
          .collection('apiculteurs')
          .where('email', isEqualTo: email)
          .get();
      
      print('Données Firestore trouvées: ${querySnapshot.docs.length} document(s)');
      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        print('Données utilisateur trouvées: $userData');
      }
      
      final userCredential = await _firebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        print('Échec de connexion: userCredential.user est null');
        throw Exception('Échec de connexion');
      }
      
      print('Connexion réussie pour l\'utilisateur: ${userCredential.user!.uid}');
      return userCredential.user!;
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      
      // Si l'utilisateur n'existe pas, essayer de le créer
      if (e is FirebaseAuthException && 
          (e.code == 'invalid-credential' || e.code == 'user-not-found')) {
        print('Tentative de création de l\'utilisateur...');
        return await createUserFromFirestore(email, password);
      }
      
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
  
  // Connexion avec identifiant et mot de passe
  Future<User> signInWithUsername(String username, String password) async {
    try {
      // Rechercher l'utilisateur dans Firestore par identifiant
      final querySnapshot = await _firebaseService.firestore
          .collection('apiculteurs')
          .where('identifiant', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Aucun utilisateur trouvé avec cet identifiant');
      }

      // Récupérer l'email de l'utilisateur
      final email = querySnapshot.docs.first.get('email') as String;

      // Se connecter avec l'email et le mot de passe
      return await signInWithEmailAndPassword(email, password);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Créer un utilisateur Firebase Auth à partir des données Firestore
  Future<User> createUserFromFirestore(String email, String password) async {
    try {
      print('Tentative de création d\'un utilisateur avec email: $email');
      
      // Vérifier d'abord si l'utilisateur existe dans Firestore
      final querySnapshot = await _firebaseService.firestore
          .collection('apiculteurs')
          .where('email', isEqualTo: email)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        throw Exception('Aucun utilisateur trouvé dans Firestore avec cet email');
      }
      
      final userData = querySnapshot.docs.first.data();
      print('Données Firestore pour création: $userData');
      
      try {
        // Essayer de créer l'utilisateur
        final userCredential = await _firebaseService.auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        if (userCredential.user != null) {
          // Mettre à jour le profil utilisateur
          await userCredential.user!.updateDisplayName(userData['nom'] ?? '');
          print('Compte créé avec succès pour l\'utilisateur: ${userCredential.user!.uid}');
          return userCredential.user!;
        }
      } catch (authError) {
        print('Erreur lors de la création: $authError');
        // Si l'utilisateur existe déjà, essayer de se connecter directement
        if (authError is FirebaseAuthException && authError.code == 'email-already-in-use') {
          print('L\'utilisateur existe déjà, tentative de connexion directe');
          final signInCredential = await _firebaseService.auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          return signInCredential.user!;
        }
        rethrow;
      }
      
      throw Exception('Échec de création du compte');
    } catch (e) {
      print('Erreur lors de la création du compte: $e');
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