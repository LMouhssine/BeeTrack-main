import 'package:flutter/material.dart';
import 'package:ruche_connectee/widgets/ruche_card.dart';

class RuchesListScreen extends StatelessWidget {
  const RuchesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cette liste serait normalement chargée depuis Firebase
    final List<Map<String, dynamic>> ruches = [
      {
        'id': '1',
        'name': 'Ruche Alpha',
        'rucherId': '1',
        'rucherName': 'Rucher des Collines',
        'temperature': 25.7,
        'humidity': 65.2,
        'lidOpen': false,
        'lastUpdate': DateTime.now().subtract(const Duration(minutes: 15)),
        'batteryLevel': 78,
      },
      {
        'id': '2',
        'name': 'Ruche Beta',
        'rucherId': '1',
        'rucherName': 'Rucher des Collines',
        'temperature': 26.3,
        'humidity': 62.8,
        'lidOpen': false,
        'lastUpdate': DateTime.now().subtract(const Duration(minutes: 30)),
        'batteryLevel': 65,
      },
      {
        'id': '3',
        'name': 'Ruche Gamma',
        'rucherId': '2',
        'rucherName': 'Rucher du Vallon',
        'temperature': 24.9,
        'humidity': 68.5,
        'lidOpen': true,
        'lastUpdate': DateTime.now().subtract(const Duration(minutes: 5)),
        'batteryLevel': 92,
      },
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une ruche...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                // Filtrer les ruches
              },
            ),
          ),
          
          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Toutes', true),
                _buildFilterChip('Alertes', false),
                _buildFilterChip('Rucher des Collines', false),
                _buildFilterChip('Rucher du Vallon', false),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Titre de la section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Mes ruches',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Liste des ruches
          Expanded(
            child: ruches.isEmpty
                ? const Center(
                    child: Text('Aucune ruche trouvée'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ruches.length,
                    itemBuilder: (context, index) {
                      final ruche = ruches[index];
                      return RucheCard(
                        id: ruche['id'],
                        name: ruche['name'],
                        rucherName: ruche['rucherName'],
                        temperature: ruche['temperature'],
                        humidity: ruche['humidity'],
                        lidOpen: ruche['lidOpen'],
                        lastUpdate: ruche['lastUpdate'],
                        batteryLevel: ruche['batteryLevel'],
                        onTap: () {
                          // Naviguer vers les détails de la ruche
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (value) {
          // Appliquer le filtre
        },
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFFFFD54F),
        checkmarkColor: const Color(0xFF795548),
      ),
    );
  }
}