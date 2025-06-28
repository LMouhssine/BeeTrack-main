import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:ruche_connectee/services/rucher_service.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';

class RucherListScreen extends StatefulWidget {
  const RucherListScreen({Key? key}) : super(key: key);

  @override
  State<RucherListScreen> createState() => _RucherListScreenState();
}

class _RucherListScreenState extends State<RucherListScreen> {
  late final RucherService _rucherService;
  late Stream<List<Map<String, dynamic>>> _ruchersStream;

  @override
  void initState() {
    super.initState();
    _rucherService = RucherService(GetIt.I<FirebaseService>());
    _initializeStream();
  }

  void _initializeStream() {
    // Utiliser la version optimisée avec fallback automatique
    _ruchersStream = _rucherService.ecouterRuchersUtilisateurOptimise();
  }

  void _refreshStream() {
    setState(() {
      _initializeStream();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Rafraîchir le stream quand on revient sur cet écran
    _refreshStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ruchers'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push('/ruchers/ajouter');
              // Rafraîchir la liste quand on revient
              _refreshStream();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _ruchersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            LoggerService.error(
                'Erreur lors du chargement des ruchers', snapshot.error);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshStream,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final ruchers = snapshot.data!;

          if (ruchers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_work_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun rucher trouvé',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez votre premier rucher pour commencer',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await context.push('/ruchers/ajouter');
                      _refreshStream();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Créer un rucher'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshStream();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: ruchers.length,
              itemBuilder: (context, index) {
                final rucher = ruchers[index];
                final dateCreation = rucher['dateCreation'] != null
                    ? (rucher['dateCreation'] as dynamic).toDate()
                    : DateTime.now();

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.home_work,
                        color: Colors.amber.shade700,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      rucher['nom'] ?? 'Sans nom',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          rucher['adresse'] ?? 'Adresse non renseignée',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.hive,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${rucher['nombreRuches'] ?? 0} ruche(s)',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${dateCreation.day}/${dateCreation.month}/${dateCreation.year}',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/ruchers/${rucher['id']}'),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/ruchers/ajouter');
          _refreshStream();
        },
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
