import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ruche_connectee/config/router.dart';
import 'package:ruche_connectee/config/service_locator.dart';
import 'package:ruche_connectee/services/auth_service.dart';
import 'package:ruche_connectee/blocs/auth/auth_bloc.dart';
import 'package:ruche_connectee/firebase_options.dart';

void main() async {
  // Assure que les widgets Flutter sont initialisés
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialise Firebase avec la configuration appropriée
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configure l'injection de dépendances avec les nouveaux services API
  await setupServiceLocator();
  
  // Lance l'application
  runApp(const RucheConnecteeApp());
}

class RucheConnecteeApp extends StatelessWidget {
  const RucheConnecteeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(getIt<AuthService>())..add(CheckAuthStatusEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Ruche Connectée',
        routerConfig: router,
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
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}