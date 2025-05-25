import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:ruche_connectee/services/rucher_service.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';

/// Écran de liste des ruchers optimisé utilisant l'index Firestore composite
/// 
/// Cette version utilise la méthode obtenirRuchersUtilisateurOptimise() qui tire parti
/// de l'index composite Firestore pour une performance optimale :
/// - idApiculteur (Ascending)
/// - actif (Ascending) 
/// - dateCreation (Descending)
class RucherListScreenOptimise extends StatefulWidget {
  const RucherListScreenOptimise({Key? key}) : super(key: key);

  @override
  State<RucherListScreenOptimise> createState() => _RucherListScreenOptimiseState();
}

class _RucherListScreenOptimiseState extends State<RucherListScreenOptimise> {
  late final RucherService _rucherService;
  List<Map<String, dynamic>> _ruchers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _rucherService = RucherService(GetIt.I<FirebaseService>());
    _loadRuchers();
  }

  /// Charge les ruchers en utilisant la méthode optimisée
  Future<void> _loadRuchers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      LoggerService.info('🐝 Chargement des ruchers avec méthode optimisée');
      
      final ruchers = await _rucherService.obtenirRuchersUtilisateurOptimise();
      
      setState(() {
        _ruchers = ruchers;
        _isLoading = false;
      });

      LoggerService.info('🐝 ${ruchers.length} rucher(s) chargé(s) avec succès');

    } catch (e) {
      LoggerService.error('Erreur lors du chargement des ruchers', e);
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Rafraîchit la liste des ruchers
  Future<void> _refreshRuchers() async {
    await _loadRuchers();
  }

  /// Navigue vers l'écran d'ajout de rucher
  Future<void> _navigateToAddRucher() async {
    await context.push('/ruchers/ajouter');
    // Recharger la liste après ajout
    await _refreshRuchers();
  }

  /// Supprime un rucher avec confirmation
  Future<void> _deleteRucher(String rucherId, String nom) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer le rucher "$nom" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _rucherService.supprimerRucher(rucherId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rucher "$nom" supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        await _refreshRuchers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Mes Ruchers'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Optimisé',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRuchers,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddRucher,
            tooltip: 'Ajouter un rucher',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des ruchers...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
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
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshRuchers,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    if (_ruchers.isEmpty) {
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
                fontWeight: FontWeight.bold,
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
              onPressed: _navigateToAddRucher,
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
      onRefresh: _refreshRuchers,
      color: Colors.amber,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _ruchers.length,
        itemBuilder: (context, index) => _buildRucherCard(_ruchers[index]),
      ),
    );
  }

  Widget _buildRucherCard(Map<String, dynamic> rucher) {
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
            if (rucher['description'] != null && rucher['description'].isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                rucher['description'],
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                _deleteRucher(rucher['id'], rucher['nom'] ?? 'Sans nom');
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Naviguer vers les détails du rucher
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Détails du rucher "${rucher['nom']}" (à implémenter)'),
            ),
          );
        },
      ),
    );
  }
} 