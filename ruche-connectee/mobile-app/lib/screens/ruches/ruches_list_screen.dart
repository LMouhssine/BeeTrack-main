import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/ruche_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';
import 'package:ruche_connectee/screens/ruches/ajouter_ruche_screen.dart';
import 'package:ruche_connectee/screens/ruches/ruche_detail_screen.dart';
import 'dart:async';

class RuchesListScreen extends StatefulWidget {
  const RuchesListScreen({Key? key}) : super(key: key);

  @override
  State<RuchesListScreen> createState() => _RuchesListScreenState();
}

class _RuchesListScreenState extends State<RuchesListScreen> {
  late final RucheService _rucheService;
  StreamSubscription<List<Map<String, dynamic>>>? _ruchesSubscription;
  List<Map<String, dynamic>> _ruches = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _startListeningToRuches();
  }

  @override
  void dispose() {
    _ruchesSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeServices() {
    final firebaseService = GetIt.I<FirebaseService>();
    _rucheService = RucheService(firebaseService);
  }

  void _startListeningToRuches() {
    _ruchesSubscription = _rucheService.ecouterRuchesUtilisateur().listen(
      (ruches) {
        if (mounted) {
          setState(() {
            _ruches = ruches;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        LoggerService.error('Erreur d\'écoute des ruches', error);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar('Erreur lors du chargement des ruches: $error');
        }
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _supprimerRuche(String rucheId, String nomRuche) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer la ruche'),
          content: Text('Êtes-vous sûr de vouloir supprimer la ruche "$nomRuche" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _rucheService.supprimerRuche(rucheId);
        _showSuccessSnackBar('Ruche supprimée avec succès');
      } catch (e) {
        _showErrorSnackBar('Erreur lors de la suppression: $e');
      }
    }
  }

  List<Map<String, dynamic>> get _filteredRuches {
    if (_searchQuery.isEmpty) {
      return _ruches;
    }
    return _ruches.where((ruche) {
      final nom = (ruche['nom'] ?? '').toString().toLowerCase();
      final position = (ruche['position'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return nom.contains(query) || position.contains(query);
    }).toList();
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Non définie';
    
    try {
      DateTime date;
      if (timestamp.runtimeType.toString().contains('Timestamp')) {
        date = timestamp.toDate();
      } else if (timestamp is DateTime) {
        date = timestamp;
      } else {
        return 'Format invalide';
      }
      
      return '${date.day.toString().padLeft(2, '0')}/'
             '${date.month.toString().padLeft(2, '0')}/'
             '${date.year}';
    } catch (e) {
      return 'Erreur format';
    }
  }

  Widget _buildStatsCard() {
    final totalRuches = _ruches.length;
    final ruchesEnService = _ruches.where((r) => r['enService'] == true).length;
    final ruchesHorsService = totalRuches - ruchesEnService;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé de vos ruches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.hive,
                    label: 'Total',
                    value: totalRuches.toString(),
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.check_circle,
                    label: 'En service',
                    value: ruchesEnService.toString(),
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.warning,
                    label: 'Hors service',
                    value: ruchesHorsService.toString(),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher une ruche...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Statistiques
                _buildStatsCard(),
                
                // Barre de recherche
                _buildSearchBar(),
                
                const SizedBox(height: 16),
                
                // Liste des ruches
                Expanded(
                  child: _filteredRuches.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isNotEmpty ? Icons.search_off : Icons.hive_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Aucune ruche trouvée pour "$_searchQuery"'
                                    : 'Aucune ruche trouvée',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Essayez une autre recherche'
                                    : 'Ajoutez votre première ruche pour commencer',
                                style: const TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              if (_searchQuery.isEmpty) ...[
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const AjouterRucheScreen(),
                                      ),
                                    );
                                    if (result == true) {
                                      _showSuccessSnackBar('Ruche ajoutée avec succès !');
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Ajouter une ruche'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            // L'écoute temps réel se rafraîchit automatiquement
                            await Future.delayed(const Duration(seconds: 1));
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredRuches.length,
                            itemBuilder: (context, index) {
                              final ruche = _filteredRuches[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 2,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: ruche['enService'] == true
                                        ? Colors.green
                                        : Colors.orange,
                                    child: Text(
                                      ruche['position']?.toString().substring(0, 1).toUpperCase() ?? '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    ruche['nom'] ?? 'Sans nom',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Position: ${ruche['position'] ?? 'Non définie'}'),
                                      Row(
                                        children: [
                                          Icon(
                                            ruche['enService'] == true ? Icons.check_circle : Icons.warning,
                                            size: 16,
                                            color: ruche['enService'] == true ? Colors.green : Colors.orange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            ruche['enService'] == true ? 'En service' : 'Hors service',
                                            style: TextStyle(
                                              color: ruche['enService'] == true ? Colors.green : Colors.orange,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (ruche['dateInstallation'] != null)
                                        Text(
                                          'Installée le: ${_formatDate(ruche['dateInstallation'])}',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'details',
                                        child: Row(
                                          children: [
                                            Icon(Icons.info),
                                            SizedBox(width: 8),
                                            Text('Détails'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit),
                                            SizedBox(width: 8),
                                            Text('Modifier'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'details':
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => RucheDetailScreen(rucheId: ruche['id']),
                                            ),
                                          );
                                          break;
                                        case 'edit':
                                          // TODO: Modifier la ruche
                                          _showErrorSnackBar('Modification à implémenter');
                                          break;
                                        case 'delete':
                                          _supprimerRuche(ruche['id'], ruche['nom'] ?? 'Sans nom');
                                          break;
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => RucheDetailScreen(rucheId: ruche['id']),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}