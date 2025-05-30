import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RucheDetailScreen extends StatefulWidget {
  final String rucheId;

  const RucheDetailScreen({
    Key? key,
    required this.rucheId,
  }) : super(key: key);

  @override
  State<RucheDetailScreen> createState() => _RucheDetailScreenState();
}

class _RucheDetailScreenState extends State<RucheDetailScreen> {
  Map<String, dynamic>? _rucheData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRucheData();
  }

  Future<void> _loadRucheData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final docSnapshot = await GetIt.I<FirebaseService>()
          .firestore
          .collection('ruches')
          .doc(widget.rucheId)
          .get();

      if (!mounted) return;

      if (docSnapshot.exists) {
        setState(() {
          _rucheData = docSnapshot.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Ruche non trouvée';
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggerService.error('Erreur lors du chargement de la ruche', e);
      if (!mounted) return;
      setState(() {
        _error = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_rucheData?['nom'] ?? 'Détails de la ruche'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité de modification en cours de développement')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRucheData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
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
                        _error!,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRucheData,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informations générales
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informations générales',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow('Nom', _rucheData?['nom'] ?? 'Non défini'),
                              const Divider(),
                              _buildInfoRow('Position', _rucheData?['position'] ?? 'Non définie'),
                              const Divider(),
                              _buildInfoRow('Rucher', _rucheData?['rucher_nom'] ?? 'Non défini'),
                              const Divider(),
                              _buildInfoRow('Type de ruche', _rucheData?['type_ruche'] ?? 'Non défini'),
                              if (_rucheData?['description'] != null && _rucheData!['description'].isNotEmpty) ...[
                                const Divider(),
                                _buildInfoRow('Description', _rucheData!['description']),
                              ],
                              const Divider(),
                              _buildStatusRow(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Données des capteurs
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Données des capteurs',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSensorRow(
                                'Température',
                                _rucheData?['temperature']?.toString() ?? '--',
                                '°C',
                                Icons.thermostat,
                                Colors.orange,
                              ),
                              const Divider(),
                              _buildSensorRow(
                                'Humidité',
                                _rucheData?['humidite']?.toString() ?? '--',
                                '%',
                                Icons.water_drop,
                                Colors.blue,
                              ),
                              const Divider(),
                              _buildSensorRow(
                                'Couvercle',
                                _rucheData?['couvercle_ouvert'] == true ? 'Ouvert' : 'Fermé',
                                '',
                                _rucheData?['couvercle_ouvert'] == true ? Icons.lock_open : Icons.lock,
                                _rucheData?['couvercle_ouvert'] == true ? Colors.red : Colors.green,
                              ),
                              const Divider(),
                              _buildSensorRow(
                                'Batterie',
                                _rucheData?['niveau_batterie']?.toString() ?? '--',
                                '%',
                                Icons.battery_full,
                                _getBatteryColor(_rucheData?['niveau_batterie']),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Informations techniques
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informations techniques',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow('Date d\'installation', _formatDate(_rucheData?['dateInstallation'])),
                              const Divider(),
                              _buildInfoRow('Dernière mise à jour', _formatDate(_rucheData?['derniere_mise_a_jour'])),
                              const Divider(),
                              _buildInfoRow('Statut', _rucheData?['enService'] == true ? 'En service' : 'Hors service'),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorRow(String label, String value, String unit, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$value $unit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    final bool enService = _rucheData?['enService'] == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            enService ? Icons.check_circle : Icons.warning,
            color: enService ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Statut',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            enService ? 'En service' : 'Hors service',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: enService ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(int? batteryLevel) {
    if (batteryLevel == null) return Colors.grey;
    if (batteryLevel > 50) return Colors.green;
    if (batteryLevel > 20) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Non définie';
    
    try {
      DateTime dateTime;
      if (date is Timestamp) {
        dateTime = date.toDate();
      } else if (date is DateTime) {
        dateTime = date;
      } else if (date is String) {
        dateTime = DateTime.parse(date);
      } else {
        return 'Format invalide';
      }
      
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Date invalide';
    }
  }
} 