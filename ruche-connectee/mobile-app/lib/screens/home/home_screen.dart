import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ruche_connectee/blocs/auth/auth_bloc.dart';
import 'package:ruche_connectee/screens/ruchers/rucher_list_screen_alternative.dart';
import 'package:ruche_connectee/screens/ruches/ruches_list_screen.dart';
import 'package:ruche_connectee/screens/ruches/ajouter_ruche_screen.dart';
import 'package:ruche_connectee/screens/profile/profile_screen.dart';
import 'package:ruche_connectee/screens/stats/stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    RucherListScreenAlternative(),
    RuchesListScreen(),
    StatsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _navigateToAddRuche() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AjouterRucheScreen(),
      ),
    );
    
    if (result == true) {
      _showSuccessMessage('Ruche ajoutée avec succès !');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruche Connectée'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          // Bouton d'ajout rapide selon l'onglet actuel
          if (_selectedIndex == 0) // Onglet Ruchers
            IconButton(
              icon: const Icon(Icons.add_business),
              tooltip: 'Ajouter un rucher',
              onPressed: () {
                // TODO: Naviguer vers l'ajout de rucher
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigation vers ajout rucher à implémenter')),
                );
              },
            )
          else if (_selectedIndex == 1) // Onglet Ruches
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Ajouter une ruche',
              onPressed: () async {
                await _navigateToAddRuche();
              },
            ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Naviguer vers l'écran des notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications à implémenter')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work),
            label: 'Ruchers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hive),
            label: 'Ruches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Statistiques',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
      ),
      floatingActionButton: _selectedIndex == 1 // Seulement sur l'onglet Ruches
          ? FloatingActionButton(
              onPressed: () async {
                await _navigateToAddRuche();
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
  
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}