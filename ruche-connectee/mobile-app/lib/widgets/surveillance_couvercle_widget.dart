import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ruche_connectee/blocs/alerte_couvercle_bloc.dart';

class SurveillanceCouvercleWidget extends StatelessWidget {
  final String rucheId;
  final String rucheNom;
  final String apiculteurId;

  const SurveillanceCouvercleWidget({
    Key? key,
    required this.rucheId,
    required this.rucheNom,
    required this.apiculteurId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlerteCouvercleBloc, AlerteCouvercleState>(
      builder: (context, state) {
        final enSurveillance = state.ruchesEnSurveillance.contains(rucheId);
        final statutIgnore = state.statutsIgnore[rucheId];

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(enSurveillance),
                const SizedBox(height: 16),
                if (statutIgnore?.ignore == true) ...[
                  _buildIgnoreStatus(context, statutIgnore!),
                  const SizedBox(height: 16),
                ],
                _buildDescription(),
                const SizedBox(height: 20),
                _buildControls(context, enSurveillance, statutIgnore),
                if (enSurveillance) ...[
                  const SizedBox(height: 16),
                  _buildInfo(state.ruchesEnSurveillance.length),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool enSurveillance) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                enSurveillance ? Colors.green.shade100 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.visibility,
            color:
                enSurveillance ? Colors.green.shade600 : Colors.grey.shade500,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Surveillance du Couvercle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Détection automatique d\'ouverture non autorisée',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                enSurveillance ? Colors.green.shade100 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: enSurveillance ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                enSurveillance ? 'Actif' : 'Inactif',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: enSurveillance
                      ? Colors.green.shade800
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIgnoreStatus(BuildContext context, StatutIgnore statut) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility_off,
                size: 18,
                color: Colors.amber.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Alertes temporairement désactivées',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getIgnoreMessage(statut),
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber.shade700,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              context.read<AlerteCouvercleBloc>().add(
                    ReactiverAlertesEvent(rucheId),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Réactiver maintenant',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getIgnoreMessage(StatutIgnore statut) {
    if (statut.type == 'session') {
      return '🔇 Ignoré pour cette session';
    } else if (statut.finIgnore != null) {
      final formatter = DateFormat('dd/MM HH:mm');
      return '🕐 Ignoré jusqu\'au ${formatter.format(statut.finIgnore!)}';
    }
    return '🔇 Alertes désactivées';
  }

  Widget _buildDescription() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Comment ça fonctionne :',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...const [
            '• Vérification automatique toutes les 30 secondes',
            '• Alerte immédiate si couvercle ouvert détecté',
            '• Options d\'ignore temporaire disponibles',
            '• Surveillance continue en arrière-plan',
          ].map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildControls(
      BuildContext context, bool enSurveillance, StatutIgnore? statutIgnore) {
    return Column(
      children: [
        if (!enSurveillance)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<AlerteCouvercleBloc>().add(
                      DemarrerSurveillanceEvent(
                        rucheId: rucheId,
                        apiculteurId: apiculteurId,
                        rucheNom: rucheNom,
                      ),
                    );
              },
              icon: const Icon(Icons.play_circle_filled, size: 20),
              label: const Text('Démarrer la Surveillance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        else ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<AlerteCouvercleBloc>().add(
                      ArreterSurveillanceEvent(rucheId),
                    );
              },
              icon: const Icon(Icons.stop_circle, size: 20),
              label: const Text('Arrêter la Surveillance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<AlerteCouvercleBloc>().add(
                          IgnorerAlerteEvent(rucheId: rucheId, dureeHeures: 1),
                        );
                  },
                  icon: const Icon(Icons.schedule, size: 16),
                  label: const Text('Ignorer 1h'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<AlerteCouvercleBloc>().add(
                          IgnorerPourSessionEvent(rucheId),
                        );
                  },
                  icon: const Icon(Icons.shield, size: 16),
                  label: const Text('Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfo(int totalSurveillance) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildInfoRow('📊 Ruches surveillées', '$totalSurveillance'),
          _buildInfoRow('🔄 Fréquence', 'Toutes les 30 secondes'),
          _buildInfoRow('💾 Stockage', 'Préférences locales'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
