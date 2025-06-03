import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ruche_connectee/blocs/alerte_couvercle_bloc.dart';
import 'package:ruche_connectee/models/api_models.dart';
import 'package:ruche_connectee/widgets/alerte_couvercle_modal.dart';
import 'package:ruche_connectee/services/alerte_couvercle_service.dart';
import 'package:ruche_connectee/config/service_locator.dart';

class TestAlerteCouvercleScreen extends StatelessWidget {
  const TestAlerteCouvercleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AlerteCouvercleBloc(getIt<AlerteCouvercleService>()),
      child: const _TestAlerteCouvercleScreenContent(),
    );
  }
}

class _TestAlerteCouvercleScreenContent extends StatefulWidget {
  const _TestAlerteCouvercleScreenContent({Key? key}) : super(key: key);

  @override
  State<_TestAlerteCouvercleScreenContent> createState() => _TestAlerteCouvercleScreenContentState();
}

class _TestAlerteCouvercleScreenContentState extends State<_TestAlerteCouvercleScreenContent> {
  static const String testRucheId = 'test-ruche-001';
  static const String testApiculteurId = 'test-user';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Alerte Couvercle'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<AlerteCouvercleBloc, AlerteCouvercleState>(
        listener: (context, state) {
          // Afficher les messages de succès ou d'erreur
          if (state.messageSucces != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.messageSucces!),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          
          if (state.messageErreur != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.messageErreur!),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildStatusCards(state),
                    const SizedBox(height: 20),
                    _buildControls(context, state),
                    const SizedBox(height: 20),
                    _buildInstructions(),
                    const SizedBox(height: 20),
                    _buildDebugInfo(state),
                  ],
                ),
              ),
              // Modal d'alerte
              if (state.alerteActive != null)
                AlerteCouvercleModal(
                  rucheId: state.alerteActive!.rucheId,
                  rucheNom: state.alerteActive!.rucheNom,
                  mesure: state.alerteActive!.mesure,
                  onIgnorerTemporairement: (dureeHeures) {
                    context.read<AlerteCouvercleBloc>().add(
                          IgnorerAlerteEvent(
                            rucheId: state.alerteActive!.rucheId,
                            dureeHeures: dureeHeures,
                          ),
                        );
                  },
                  onIgnorerSession: () {
                    context.read<AlerteCouvercleBloc>().add(
                          IgnorerPourSessionEvent(state.alerteActive!.rucheId),
                        );
                  },
                  onFermer: () {
                    context.read<AlerteCouvercleBloc>().add(FermerAlerteEvent());
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.science,
                color: Colors.blue.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Alerte Couvercle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Démonstration du système d\'alerte en temps réel',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCards(AlerteCouvercleState state) {
    final enSurveillance = state.ruchesEnSurveillance.contains(testRucheId);
    final aAlerteActive = state.alerteActive != null;
    final statutIgnore = state.statutsIgnore[testRucheId];

    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'Surveillance',
            enSurveillance ? 'Active' : 'Inactive',
            enSurveillance ? Colors.green : Colors.grey,
            enSurveillance ? Icons.visibility : Icons.visibility_off,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusCard(
            'Alerte Active',
            aAlerteActive ? 'Oui' : 'Non',
            aAlerteActive ? Colors.red : Colors.grey,
            aAlerteActive ? Icons.warning : Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusCard(
            'Statut Ignore',
            statutIgnore?.ignore == true 
                ? 'Ignoré (${statutIgnore!.type})' 
                : 'Normal',
            statutIgnore?.ignore == true ? Colors.amber : Colors.grey,
            statutIgnore?.ignore == true ? Icons.volume_off : Icons.volume_up,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String status, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, AlerteCouvercleState state) {
    final enSurveillance = state.ruchesEnSurveillance.contains(testRucheId);
    final aAlerteActive = state.alerteActive != null;
    final statutIgnore = state.statutsIgnore[testRucheId];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contrôles de Test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!enSurveillance)
                  ElevatedButton.icon(
                    onPressed: () => _demarrerTest(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Démarrer Surveillance Test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => _arreterTest(context),
                    icon: const Icon(Icons.stop),
                    label: const Text('Arrêter Surveillance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: enSurveillance && !aAlerteActive ? () => _simulerAlerte(context) : null,
                  icon: const Icon(Icons.warning),
                  label: const Text('Simuler Alerte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (statutIgnore?.ignore == true)
                  ElevatedButton.icon(
                    onPressed: () => _reactiverAlertes(context),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Réactiver Alertes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Instructions de Test',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...const [
              '1. Cliquez sur "Démarrer Surveillance Test" pour activer la surveillance',
              '2. Cliquez sur "Simuler Alerte" pour déclencher une alerte de couvercle ouvert',
              '3. Testez les options d\'ignore dans la modal d\'alerte',
              '4. Observez les notifications qui apparaissent en bas de l\'écran',
              '5. Utilisez "Réactiver Alertes" si vous avez ignoré les alertes',
            ].map((instruction) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    instruction,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugInfo(AlerteCouvercleState state) {
    final statutIgnore = state.statutsIgnore[testRucheId];
    
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de Debug',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            _buildDebugRow('Ruches surveillées', '${state.ruchesEnSurveillance.length}'),
            _buildDebugRow('Alerte active', state.alerteActive != null ? 'Oui' : 'Non'),
            if (statutIgnore?.ignore == true && statutIgnore?.finIgnore != null)
              _buildDebugRow('Fin ignore', statutIgnore!.finIgnore.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _demarrerTest(BuildContext context) {
    context.read<AlerteCouvercleBloc>().add(
          const DemarrerSurveillanceEvent(
            rucheId: testRucheId,
            apiculteurId: testApiculteurId,
            rucheNom: 'Ruche de Test',
          ),
        );
  }

  void _arreterTest(BuildContext context) {
    context.read<AlerteCouvercleBloc>().add(
          const ArreterSurveillanceEvent(testRucheId),
        );
  }

  void _simulerAlerte(BuildContext context) {
    // Créer une mesure de test avec couvercle ouvert
    final mesureTest = DonneesCapteur(
      id: 'test-mesure-${DateTime.now().millisecondsSinceEpoch}',
      rucheId: testRucheId,
      timestamp: DateTime.now(),
      temperature: 25.5,
      humidity: 65.2,
      couvercleOuvert: true,
      batterie: 85,
      signalQualite: 92,
    );

    // Déclencher l'alerte
    context.read<AlerteCouvercleBloc>().add(
          AlerteDeclenCheeEvent(
            rucheId: testRucheId,
            mesure: mesureTest,
          ),
        );
  }

  void _reactiverAlertes(BuildContext context) {
    context.read<AlerteCouvercleBloc>().add(
          const ReactiverAlertesEvent(testRucheId),
        );
  }
} 