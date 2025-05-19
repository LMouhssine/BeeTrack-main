import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ruche_connectee/blocs/auth/auth_bloc.dart';
import 'package:ruche_connectee/screens/auth/login_screen.dart';
import 'package:ruche_connectee/screens/home/home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (state is UnauthenticatedState) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de l'application
              Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 24),
              
              // Titre de l'application
              const Text(
                'Ruche Connectée',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFA000),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Sous-titre
              const Text(
                'Surveillance intelligente pour apiculteurs',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF795548),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Indicateur de chargement
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFA000)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}