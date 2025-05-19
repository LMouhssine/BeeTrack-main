import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RucheListScreen extends StatelessWidget {
  const RucheListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ruches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implémenter l'ajout de ruche
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 0, // TODO: Remplacer par la vraie liste des ruches
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.hive),
              title: Text('Ruche #${index + 1}'),
              subtitle: const Text('Dernière mise à jour: il y a 2 heures'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '24°C',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        '65%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => context.go('/ruches/$index'),
            ),
          );
        },
      ),
    );
  }
} 