import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ruche_connectee/services/logger_service.dart';

class FirebaseService {
  // Instances Firebase
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Initialisation des notifications
  Future<void> initNotifications() async {
    // Demander la permission pour les notifications
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Obtenir le token FCM
      String? token = await messaging.getToken();

      // Sauvegarder le token dans Firestore si l'utilisateur est connecté
      User? user = auth.currentUser;
      if (user != null) {
        await firestore
            .collection('apiculteurs')
            .doc(user.uid)
            .update({'fcmToken': token});
      }

      // Configurer les gestionnaires de messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        LoggerService.info(
            'Message reçu en premier plan: ${message.notification?.title}');
        // Ici, vous pouvez afficher une notification locale ou mettre à jour l'UI
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        LoggerService.info(
            'Application ouverte depuis une notification: ${message.notification?.title}');
        // Ici, vous pouvez naviguer vers un écran spécifique en fonction du message
      });

      FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
        LoggerService.info(
            'Message reçu en arrière-plan: ${message.notification?.title}');
        // Traiter le message reçu en arrière-plan
      });
    }
  }
}
