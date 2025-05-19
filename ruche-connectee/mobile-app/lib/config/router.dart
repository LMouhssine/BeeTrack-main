import 'package:go_router/go_router.dart';
import 'package:ruche_connectee/screens/auth/login_screen.dart';
import 'package:ruche_connectee/screens/auth/register_screen.dart';
import 'package:ruche_connectee/screens/home/home_screen.dart';
import 'package:ruche_connectee/screens/splash_screen.dart';
import 'package:ruche_connectee/screens/ruchers/rucher_list_screen.dart';
import 'package:ruche_connectee/screens/ruchers/rucher_detail_screen.dart';
import 'package:ruche_connectee/screens/ruches/ruche_list_screen.dart';
import 'package:ruche_connectee/screens/ruches/ruche_detail_screen.dart';
import 'package:ruche_connectee/screens/stats/stats_screen.dart';
import 'package:ruche_connectee/screens/profile/profile_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/ruchers',
      builder: (context, state) => const RucherListScreen(),
    ),
    GoRoute(
      path: '/ruchers/:id',
      builder: (context, state) => RucherDetailScreen(
        rucherId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/ruches',
      builder: (context, state) => const RucheListScreen(),
    ),
    GoRoute(
      path: '/ruches/:id',
      builder: (context, state) => RucheDetailScreen(
        rucheId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => const StatsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
); 