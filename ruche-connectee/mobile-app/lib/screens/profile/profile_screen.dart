import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ruche_connectee/services/auth_service.dart';
import 'package:get_it/get_it.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    try {
      final authService = GetIt.instance<AuthService>();
      await authService.signOut();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 24),
          const Text(
            'John Doe', // TODO: Remplacer par le nom de l'utilisateur
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Text(
            'john.doe@example.com', // TODO: Remplacer par l'email de l'utilisateur
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Modifier le profil'),
            onTap: () {
              // TODO: Implémenter la modification du profil
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              // TODO: Implémenter les paramètres de notification
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Sécurité'),
            onTap: () {
              // TODO: Implémenter les paramètres de sécurité
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Aide'),
            onTap: () {
              // TODO: Implémenter l'aide
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
} 