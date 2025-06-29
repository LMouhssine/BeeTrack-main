import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruche_connectee/models/api_models.dart';
import 'package:ruche_connectee/services/api_client_service.dart';
import 'package:ruche_connectee/services/api_ruche_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';
import 'package:ruche_connectee/screens/ruches/ruches_by_rucher_screen.dart';
import 'package:ruche_connectee/screens/ruches/ruche_detail_api_screen.dart';

class TestRuchesApiScreen extends StatefulWidget {
  const TestRuchesApiScreen({Key? key}) : super(key: key);

  @override
  State<TestRuchesApiScreen> createState() => _TestRuchesApiScreenState();
}

class _TestRuchesApiScreenState extends State<TestRuchesApiScreen> {
  late final ApiRucheService _apiRucheService;
  List<RucheResponse> _ruches = [];
  List<DonneesCapteur> _mesures = [];
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _rucherIdController = TextEditingController();
  final TextEditingController _rucheIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeServices();
    // Pré-remplir avec des IDs de test
    _rucherIdController.text = 'test-rucher-001';
    _rucheIdController.text = 'test-ruche-001';
  }

  @override
  void dispose() {
    _rucherIdController.dispose();
    _rucheIdController.dispose();
    super.dispose();
  }

  void _initializeServices() {
    final firebaseAuth = FirebaseAuth.instance;
    final apiClient = ApiClientService(firebaseAuth);
    _apiRucheService = ApiRucheService(apiClient);
  }

  Future<void> _testRuchesParRucher() async {
    if (_rucherIdController.text.trim().isEmpty) {
      _showErrorSnackBar('Veuillez saisir un ID de rucher');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _ruches.clear();
    });

    try {
      final ruches = await _apiRucheService
          .obtenirRuchesParRucher(_rucherIdController.text.trim());

      setState(() {
        _ruches = ruches;
        _isLoading = false;
      });

      _showSuccessSnackBar(
          '${ruches.length} ruche(s) récupérée(s) avec succès');
    } catch (e) {
      LoggerService.error('Erreur test ruches par rucher', e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur : ${e.toString()}';
      });
    }
  }

  Future<void> _testMesures7Jours() async {
    if (_rucheIdController.text.trim().isEmpty) {
      _showErrorSnackBar('Veuillez saisir un ID de ruche');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _mesures.clear();
    });

    try {
      final mesures = await _apiRucheService
          .obtenirMesures7DerniersJours(_rucheIdController.text.trim());

      setState(() {
        _mesures = mesures;
        _isLoading = false;
      });

      _showSuccessSnackBar(
          '${mesures.length} mesure(s) récupérée(s) avec succès');
    } catch (e) {
      LoggerService.error('Erreur test mesures 7 jours', e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur : ${e.toString()}';
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildTestSection({
    required String title,
    required String description,
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onTest,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : onTest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Tester $title'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_ruches.isEmpty && _mesures.isEmpty && _errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résultats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1 * 255),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3 * 255)),
                ),
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
            ],
            if (_ruches.isNotEmpty) ...[
              Text(
                '🐝 Ruches récupérées (${_ruches.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              ...(_ruches.take(3).map((ruche) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.hive, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${ruche.nom} (Position: ${ruche.position})',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ))),
              if (_ruches.length > 3)
                Text(
                  '... et ${_ruches.length - 3} autre(s) ruche(s)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RuchesByRucherScreen(
                        rucherId: _rucherIdController.text.trim(),
                        rucherNom: 'Rucher Test',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Voir détails complets'),
              ),
            ],
            if (_mesures.isNotEmpty) ...[
              if (_ruches.isNotEmpty) const Divider(height: 24),
              Text(
                '📊 Mesures récupérées (${_mesures.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              ...(_mesures.take(3).map((mesure) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.analytics,
                            size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_formatDateTime(mesure.timestamp)}: '
                            '${mesure.temperature?.toStringAsFixed(1) ?? '--'}°C, '
                            '${mesure.humidity?.toStringAsFixed(1) ?? '--'}%',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ))),
              if (_mesures.length > 3)
                Text(
                  '... et ${_mesures.length - 3} autre(s) mesure(s)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RucheDetailApiScreen(
                        rucheId: _rucheIdController.text.trim(),
                        rucheNom: 'Ruche Test',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Voir graphiques complets'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API Ruches'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1 * 255),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3 * 255)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Test des fonctionnalités API',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cet écran permet de tester les deux nouvelles fonctionnalités : '
                          'récupération des ruches par rucher et mesures des 7 derniers jours.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildTestSection(
              title: 'Ruches par Rucher',
              description:
                  'Récupère toutes les ruches d\'un rucher spécifique, triées par nom croissant',
              controller: _rucherIdController,
              hintText: 'ID du rucher (ex: test-rucher-001)',
              onTest: _testRuchesParRucher,
            ),
            _buildTestSection(
              title: 'Mesures 7 Jours',
              description:
                  'Récupère les mesures des capteurs des 7 derniers jours d\'une ruche',
              controller: _rucheIdController,
              hintText: 'ID de la ruche (ex: test-ruche-001)',
              onTest: _testMesures7Jours,
            ),
            _buildResultsSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
