import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RucherListScreen extends StatelessWidget {
  const RucherListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ruchers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité d\'ajout de rucher en cours de développement')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 3, // Exemple avec 3 ruchers statiques
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.location_on),
              title: Text('Rucher #${index + 1}'),
              subtitle: const Text('0 ruches'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/ruchers/$index'),
            ),
          );
        },
      ),
    );
  }
} 