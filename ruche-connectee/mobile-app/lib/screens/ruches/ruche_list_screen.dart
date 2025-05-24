import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';
import 'package:ruche_connectee/widgets/ruche_card.dart';

class RucheListScreen extends StatefulWidget {
  const RucheListScreen({Key? key}) : super(key: key);

  @override
  State<RucheListScreen> createState() => _RucheListScreenState();
}

class _RucheListScreenState extends State<RucheListScreen> {
  String? _selectedRucherId;
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ruches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddRucheDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: GetIt.I<FirebaseService>()
            .firestore
            .collection('ruches')
            .where('apiculteur_id', isEqualTo: GetIt.I<FirebaseService>().auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            LoggerService.error('Erreur lors du chargement des ruches', snapshot.error);
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ruches = snapshot.data!.docs;

          if (ruches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Aucune ruche trouvée',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddRucheDialog,
                    child: const Text('Ajouter une ruche'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Le StreamBuilder se rafraîchira automatiquement
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ruches.length,
              itemBuilder: (context, index) {
                final ruche = ruches[index].data() as Map<String, dynamic>;
                final rucheId = ruches[index].id;

                return RucheCard(
                  id: rucheId,
                  name: ruche['nom'] ?? 'Sans nom',
                  rucherName: ruche['rucher_nom'] ?? 'Rucher inconnu',
                  temperature: (ruche['temperature'] as num?)?.toDouble() ?? 0.0,
                  humidity: (ruche['humidite'] as num?)?.toDouble() ?? 0.0,
                  lidOpen: ruche['couvercle_ouvert'] ?? false,
                  lastUpdate: (ruche['derniere_mise_a_jour'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  batteryLevel: (ruche['niveau_batterie'] as num?)?.toInt() ?? 0,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/ruche/detail',
                    arguments: rucheId,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddRucheDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    String? selectedRucherId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajouter une ruche'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la ruche',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: GetIt.I<FirebaseService>()
                      .firestore
                      .collection('ruchers')
                      .where('apiculteur_id', isEqualTo: GetIt.I<FirebaseService>().auth.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final ruchers = snapshot.data!.docs;

                    return DropdownButtonFormField<String>(
                      value: selectedRucherId,
                      decoration: const InputDecoration(
                        labelText: 'Rucher',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Sélectionner un rucher'),
                        ),
                        ...ruchers.map((rucher) {
                          final data = rucher.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: rucher.id,
                            child: Text(data['nom'] ?? 'Sans nom'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => selectedRucherId = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un rucher';
                        }
                        return null;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final rucherDoc = await GetIt.I<FirebaseService>()
                        .firestore
                        .collection('ruchers')
                        .doc(selectedRucherId)
                        .get();
                    
                    if (!rucherDoc.exists) {
                      throw Exception('Rucher non trouvé');
                    }

                    final rucherData = rucherDoc.data()!;
                    
                    await GetIt.I<FirebaseService>()
                        .firestore
                        .collection('ruches')
                        .add({
                      'nom': nameController.text,
                      'rucher_id': selectedRucherId,
                      'rucher_nom': rucherData['nom'],
                      'apiculteur_id': GetIt.I<FirebaseService>().auth.currentUser?.uid,
                      'cree_le': FieldValue.serverTimestamp(),
                      'modifie_le': FieldValue.serverTimestamp(),
                      'temperature': 0.0,
                      'humidite': 0.0,
                      'couvercle_ouvert': false,
                      'niveau_batterie': 100,
                      'derniere_mise_a_jour': FieldValue.serverTimestamp(),
                    });

                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ruche ajoutée avec succès')),
                    );
                  } catch (e) {
                    LoggerService.error('Erreur lors de l\'ajout de la ruche', e);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e')),
                    );
                  }
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
} 