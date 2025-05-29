import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ruche_connectee/services/rucher_service.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';

class TestRucherScreen extends StatefulWidget {
  const TestRucherScreen({Key? key}) : super(key: key);

  @override
  State<TestRucherScreen> createState() => _TestRucherScreenState();
}

class _TestRucherScreenState extends State<TestRucherScreen> {
  late final RucherService _rucherService;
  bool _isLoading = false;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _rucherService = RucherService(GetIt.I<FirebaseService>());
  }

  Future<void> _testAjouterRucher() async {
    setState(() {
      _isLoading = true;
      _result = 'Test en cours...';
    });

    try {
      final String rucherId = await _rucherService.ajouterRucher(
        nom: 'Test Rucher ${DateTime.now().millisecondsSinceEpoch}',
        adresse: 'Adresse de test, 75001 Paris',
        description: 'Rucher créé pour tester le service',
      );

      setState(() {
        _result = 'Succès ! Rucher créé avec l\'ID: $rucherId';
      });

      LoggerService.info('Test réussi - Rucher créé: $rucherId');

    } catch (e) {
      setState(() {
        _result = 'Erreur: ${e.toString()}';
      });

      LoggerService.error('Test échoué', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testRecupererRuchers() async {
    setState(() {
      _isLoading = true;
      _result = 'Récupération des ruchers...';
    });

    try {
      final ruchers = await _rucherService.obtenirRuchersUtilisateur();

      setState(() {
        _result = 'Trouvé $ruchers.length rucher(s):\n${ruchers.map((r) => '- ${r['nom']} (${r['adresse']})').join('\n')}';
      });

      LoggerService.info('Test réussi - $ruchers.length ruchers trouvés');

    } catch (e) {
      setState(() {
        _result = 'Erreur: ${e.toString()}';
      });

      LoggerService.error('Test échoué', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test RucherService'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Test du Service RucherService',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _testAjouterRucher,
                      child: const Text('Tester Ajouter Rucher'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _testRecupererRuchers,
                      child: const Text('Tester Récupérer Ruchers'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Résultat:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _result.isEmpty ? 'Aucun test effectué' : _result,
                              style: TextStyle(
                                color: _result.startsWith('Erreur') 
                                    ? Colors.red 
                                    : Colors.green,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 