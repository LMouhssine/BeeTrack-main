import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ruche_connectee/services/ruche_service.dart';
import 'package:ruche_connectee/services/api_ruche_service.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/api_client_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';
import 'package:ruche_connectee/models/api_models.dart';

/// Écran de test pour valider le tri des ruches par nom croissant
class TestRuchesTriScreen extends StatefulWidget {
  const TestRuchesTriScreen({Key? key}) : super(key: key);

  @override
  State<TestRuchesTriScreen> createState() => _TestRuchesTriScreenState();
}

class _TestRuchesTriScreenState extends State<TestRuchesTriScreen> {
  final TextEditingController _rucherIdController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Map<String, dynamic>> _ruchesFirebase = [];
  List<RucheResponse> _ruchesApi = [];
  
  late final RucheService _rucheService;
  late final ApiRucheService _apiRucheService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _rucherIdController.dispose();
    super.dispose();
  }

  void _initializeServices() {
    final firebaseService = GetIt.I<FirebaseService>();
    final apiClientService = GetIt.I<ApiClientService>();
    
    _rucheService = RucheService(firebaseService);
    _apiRucheService = ApiRucheService(apiClientService);
  }

  Future<void> _testerTriFirebase() async {
    final rucherId = _rucherIdController.text.trim();
    if (rucherId.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez saisir un ID de rucher';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _ruchesFirebase = [];
    });

    try {
      LoggerService.info('🧪 Test tri Firebase pour rucher: $rucherId');
      
      final ruches = await _rucheService.obtenirRuchesParRucher(rucherId);
      
      setState(() {
        _ruchesFirebase = ruches;
      });
      
      LoggerService.info('🧪 Test Firebase réussi: ${ruches.length} ruches récupérées');
      
    } catch (e) {
      LoggerService.error('Erreur test Firebase', e);
      setState(() {
        _errorMessage = 'Erreur Firebase: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testerTriApi() async {
    final rucherId = _rucherIdController.text.trim();
    if (rucherId.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez saisir un ID de rucher';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _ruchesApi = [];
    });

    try {
      LoggerService.info('🧪 Test tri API pour rucher: $rucherId');
      
      final ruches = await _apiRucheService.obtenirRuchesParRucher(rucherId);
      
      setState(() {
        _ruchesApi = ruches;
      });
      
      LoggerService.info('🧪 Test API réussi: ${ruches.length} ruches récupérées');
      
    } catch (e) {
      LoggerService.error('Erreur test API', e);
      setState(() {
        _errorMessage = 'Erreur API: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testerLesTousDeux() async {
    await _testerTriFirebase();
    await _testerTriApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Test Tri Ruches par Nom'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Zone de saisie
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎯 Configuration du test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _rucherIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID du rucher',
                        hintText: 'Saisissez l\'ID du rucher à tester',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _testerTriFirebase,
                            icon: const Icon(Icons.cloud),
                            label: const Text('Test Firebase'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _testerTriApi,
                            icon: const Icon(Icons.api),
                            label: const Text('Test API'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testerLesTousDeux,
                        icon: const Icon(Icons.compare_arrows),
                        label: const Text('Tester les deux'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Indicateur de chargement
            if (_isLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Test en cours...'),
                    ],
                  ),
                ),
              ),
            
            // Message d'erreur
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Résultats
            Expanded(
              child: Row(
                children: [
                  // Résultats Firebase
                  Expanded(
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              '🔥 Firebase (${_ruchesFirebase.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: _ruchesFirebase.length,
                              itemBuilder: (context, index) {
                                final ruche = _ruchesFirebase[index];
                                return ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.orange,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    ruche['nom'] ?? 'Sans nom',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    'Position: ${ruche['position'] ?? 'N/A'}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Résultats API
                  Expanded(
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              '🌐 API (${_ruchesApi.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: _ruchesApi.length,
                              itemBuilder: (context, index) {
                                final ruche = _ruchesApi[index];
                                return ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.blue,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    ruche.nom,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    'Position: ${ruche.position}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Instructions
            Card(
              color: Colors.grey.shade100,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Instructions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Saisissez l\'ID d\'un rucher contenant plusieurs ruches\n'
                      '2. Testez Firebase et/ou API\n'
                      '3. Vérifiez que les ruches sont triées par nom croissant\n'
                      '4. Comparez les résultats entre Firebase et API',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 