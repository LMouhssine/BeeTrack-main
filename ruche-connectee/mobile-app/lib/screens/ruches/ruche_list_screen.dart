import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ruche_connectee/services/logger_service.dart';
import 'package:ruche_connectee/services/api_ruche_service.dart';
import 'package:ruche_connectee/models/api_models.dart';
import 'package:ruche_connectee/widgets/ruche_card.dart';
import 'package:go_router/go_router.dart';

class RucheListScreen extends StatefulWidget {
  const RucheListScreen({Key? key}) : super(key: key);

  @override
  State<RucheListScreen> createState() => _RucheListScreenState();
}

class _RucheListScreenState extends State<RucheListScreen> {
  late final ApiRucheService _apiRucheService;
  List<RucheResponse> _ruches = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiRucheService = GetIt.I<ApiRucheService>();
    _loadRuches();
  }

  Future<void> _loadRuches() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final ruches = await _apiRucheService.obtenirRuchesUtilisateur();
      
      setState(() {
        _ruches = ruches;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Erreur lors du chargement des ruches', e);
      setState(() {
        _errorMessage = 'Erreur lors du chargement des ruches';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ruches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRuches,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Naviguer vers l'écran d'ajout de ruche via API
              context.go('/ruches/ajouter');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
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
                )
              : _ruches.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Aucune ruche trouvée',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.go('/ruches/ajouter');
                            },
                            child: const Text('Ajouter une ruche'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRuches,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _ruches.length,
                        itemBuilder: (context, index) {
                          final ruche = _ruches[index];

                          return RucheCard(
                            id: ruche.id,
                            name: ruche.nom,
                            rucherName: ruche.rucherNom ?? 'Rucher inconnu',
                            temperature: 0.0, // Les données de capteurs ne sont pas dans l'API de base
                            humidity: 0.0,
                            lidOpen: false,
                            lastUpdate: ruche.dateCreation,
                            batteryLevel: 100,
                            onTap: () => context.go('/ruches/${ruche.id}?nom=${Uri.encodeComponent(ruche.nom)}'),
                          );
                        },
                      ),
                    ),
    );
  }
} 