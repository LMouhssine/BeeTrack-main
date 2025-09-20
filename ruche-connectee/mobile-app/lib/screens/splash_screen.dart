import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ruche_connectee/services/auth_service.dart';
import 'package:ruche_connectee/widgets/bee_logo.dart';
import 'package:get_it/get_it.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // Vérifier l'état de l'authentification après l'animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthAndRedirect();
      }
    });
  }

  Future<void> _checkAuthAndRedirect() async {
    try {
      final authService = GetIt.instance<AuthService>();
      final user = authService.currentUser;

      if (!mounted) return;
      if (user != null) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    } catch (e) {
      if (!mounted) return;
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animé avec le nouveau design
            ScaleTransition(
              scale: _animation,
              child: const BeeLogo(
                size: 120,
                color: Colors.white,
                beeColor: Colors.amber,
              ),
            ),
            const SizedBox(height: 24),
            // Titre avec animation de fade
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'BEETRCK',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'monospace',
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Indicateur de chargement
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
