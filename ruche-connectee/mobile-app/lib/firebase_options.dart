import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCtPJSY4K3K7NgqPF3pGHgeICtzn4Wbu5M",
    authDomain: "ruche-connectee-93eab.firebaseapp.com",
    projectId: "ruche-connectee-93eab",
    storageBucket: "ruche-connectee-93eab.firebasestorage.app",
    messagingSenderId: "331852612281",
    appId: "1:331852612281:web:7b80072001f8a8ce3d5168",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCtPJSY4K3K7NgqPF3pGHgeICtzn4Wbu5M",
    appId: "1:331852612281:android:YOUR_ANDROID_APP_ID",
    messagingSenderId: "331852612281",
    projectId: "ruche-connectee-93eab",
    storageBucket: "ruche-connectee-93eab.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyCtPJSY4K3K7NgqPF3pGHgeICtzn4Wbu5M",
    appId: "1:331852612281:ios:YOUR_IOS_APP_ID",
    messagingSenderId: "331852612281",
    projectId: "ruche-connectee-93eab",
    storageBucket: "ruche-connectee-93eab.firebasestorage.app",
    iosClientId: "YOUR_IOS_CLIENT_ID",
    iosBundleId: "com.ruches.connectee",
  );
} 