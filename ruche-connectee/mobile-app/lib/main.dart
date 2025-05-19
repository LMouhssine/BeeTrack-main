import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/auth_service.dart';
import 'package:ruche_connectee/blocs/auth/auth_bloc.dart';
import 'package:ruche_connectee/screens/splash_screen.dart';

// Instance singleton pour l'injection de dépendances
final GetIt getIt = GetIt.instance;

void main() async {
  // Assure que les widgets Flutter sont initialisés
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialise Firebase
  await Firebase.initializeApp();
  
  // Configure l'injection de dépendances
  setupDependencies();
  
  // Lance l'application
  runApp(const RucheConnecteeApp());
}

void setupDependencies() {
  // Services
  getIt.registerSingleton<FirebaseService>(FirebaseService());
  getIt.registerSingleton<AuthService>(AuthService(getIt<FirebaseService>()));
  
  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthService>()));
}

class RucheConnecteeApp extends StatelessWidget {
  const RucheConnecteeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Ruche Connectée',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          primaryColor: const Color(0xFFFFA000),
          secondaryHeaderColor: const Color(0xFF795548),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          fontFamily: 'Poppins',
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
            displayMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Color(0xFF424242),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Color(0xFF616161),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA000),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFFFB300),
          scaffoldBackgroundColor: const Color(0xFF121212),
          fontFamily: 'Poppins',
        ),
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}