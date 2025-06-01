import 'package:flutter/material.dart';
import 'package:ruche_connectee/config/service_locator.dart';
import 'package:ruche_connectee/services/api_ruche_service.dart';
import 'package:ruche_connectee/services/api_client_service.dart';
import 'package:ruche_connectee/widgets/api_health_widget.dart';
import 'package:ruche_connectee/widgets/auth_debug_widget.dart';
import 'package:ruche_connectee/models/api_models.dart';

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({Key? key}) : super(key: key);

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  late final ApiRucheService _apiRucheService;
  List<RucheResponse> _ruches = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiRucheService = getIt<ApiRucheService>();
    _loadRuches();
  }

  Future<void> _loadRuches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ruches = await _apiRucheService.obtenirRuchesUtilisateur();
      setState(() {
        _ruches = ruches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        String errorMessage = 'Erreur de connexion à l\'API';
        if (e is RucheApiException) {
          errorMessage = e.message;
        } else if (e is ApiException) {
          errorMessage = e.message;
        }
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API Spring Boot'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Widget de debug de l'authentification
            const AuthDebugWidget(),
            
            const SizedBox(height: 16),
            
            // Widget de santé de l'API
            const ApiHealthWidget(),
            
            const SizedBox(height: 24),
            
            // Section des ruches
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.hive, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Ruches via API',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _isLoading ? null : _loadRuches,
                          icon: _isLoading 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red[600], size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_ruches.isEmpty && !_isLoading) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue[600], size: 16),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Aucune ruche trouvée. Créez votre première ruche !',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Text(
                        '${_ruches.length} ruche(s) trouvée(s)',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Liste des ruches
                      ...(_ruches.map((ruche) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  ruche.enService ? Icons.check_circle : Icons.warning,
                                  color: ruche.enService ? Colors.green : Colors.orange,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ruche.nom,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  ruche.position,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            if (ruche.rucherNom != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Rucher: ${ruche.rucherNom}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (ruche.typeRuche != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Type: ${ruche.typeRuche}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (ruche.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                ruche.description!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ))),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/ajouter-ruche');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une ruche'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Informations techniques
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations techniques',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Architecture', 'Flutter → Spring Boot → Firebase'),
                    _buildInfoRow('Authentification', 'Firebase JWT + X-Apiculteur-ID'),
                    _buildInfoRow('Format de données', 'JSON REST API'),
                    _buildInfoRow('Nouveaux champs', 'typeRuche, description, enrichissement rucher'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 