import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruche_connectee/models/api_models.dart';
import 'package:ruche_connectee/services/api_client_service.dart';
import 'package:ruche_connectee/services/api_ruche_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';
import 'package:ruche_connectee/screens/ruches/ruche_detail_api_screen.dart';

/// Helper function to create colors with opacity using Flutter's native method
Color colorWithOpacity(Color color, double opacity) {
  // Use Flutter's built-in withValues method - updated to avoid deprecation
  return color.withValues(alpha: opacity * 255);
}

class RuchesByRucherScreen extends StatefulWidget {
  final String rucherId;
  final String rucherNom;

  const RuchesByRucherScreen({
    Key? key,
    required this.rucherId,
    required this.rucherNom,
  }) : super(key: key);

  @override
  State<RuchesByRucherScreen> createState() => _RuchesByRucherScreenState();
}

class _RuchesByRucherScreenState extends State<RuchesByRucherScreen> {
  late final ApiRucheService _apiRucheService;
  List<RucheResponse> _ruches = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadRuches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeServices() {
    final firebaseAuth = FirebaseAuth.instance;
    final apiClient = ApiClientService(firebaseAuth);
    _apiRucheService = ApiRucheService(apiClient);
  }

  Future<void> _loadRuches() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final ruches =
          await _apiRucheService.obtenirRuchesParRucher(widget.rucherId);

      setState(() {
        _ruches = ruches;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Erreur lors du chargement des ruches du rucher', e);
      setState(() {
        _isLoading = false;
        _errorMessage = _getErrorMessage(e);
      });
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is RucheApiException) {
      switch (error.statusCode) {
        case 403:
          return 'Accès refusé à ce rucher.';
        case 404:
          return 'Rucher non trouvé.';
        case 500:
          return 'Erreur du serveur. Veuillez réessayer.';
        default:
          return error.message;
      }
    }
    return 'Erreur de connexion. Vérifiez votre connexion internet.';
  }

  List<RucheResponse> get _filteredRuches {
    if (_searchQuery.isEmpty) {
      return _ruches;
    }
    return _ruches.where((ruche) {
      final nom = ruche.nom.toLowerCase();
      final position = ruche.position.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return nom.contains(query) || position.contains(query);
    }).toList();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Non définie';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Widget _buildStatsCard() {
    final totalRuches = _ruches.length;
    final ruchesEnService = _ruches.where((r) => r.enService).length;
    final ruchesHorsService = totalRuches - ruchesEnService;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ruches du rucher "${widget.rucherNom}"',
              style: const TextStyle(
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
        Icon(icon, color: color, size: 28),
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
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher par nom ou position...',
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
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildRuchesList() {
    final ruches = _filteredRuches;

    if (ruches.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Aucune ruche trouvée',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Essayez de modifier votre recherche',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      } else {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.hive, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Aucune ruche dans ce rucher',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Ajoutez des ruches à ce rucher pour commencer',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
    }

    return ListView.builder(
      itemCount: ruches.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final ruche = ruches[index];
        return _buildRucheCard(ruche);
      },
    );
  }

  Widget _buildRucheCard(RucheResponse ruche) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToRucheDetail(ruche),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom et statut
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ruche.nom,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(ruche.enService),
                ],
              ),
              const SizedBox(height: 8),

              // Position et type
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Position: ${ruche.position}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (ruche.typeRuche != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.category, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      ruche.typeRuche!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),

              if (ruche.description != null &&
                  ruche.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  ruche.description!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Informations additionnelles
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Installée: ${_formatDate(ruche.dateInstallation)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool enService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: enService
            ? colorWithOpacity(Colors.green, 0.2)
            : colorWithOpacity(Colors.orange, 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enService ? Icons.check_circle : Icons.warning,
            size: 14,
            color: enService ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            enService ? 'En service' : 'Hors service',
            style: TextStyle(
              fontSize: 12,
              color: enService ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRucheDetail(RucheResponse ruche) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RucheDetailApiScreen(
          rucheId: ruche.id,
          rucheNom: ruche.nom,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ruches - ${widget.rucherNom}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRuches,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadRuches,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    _buildStatsCard(),
                    _buildSearchBar(),
                    Expanded(child: _buildRuchesList()),
                  ],
                ),
    );
  }
}
