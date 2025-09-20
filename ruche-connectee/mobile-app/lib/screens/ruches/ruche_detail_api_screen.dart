import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruche_connectee/models/api_models.dart';
import 'package:ruche_connectee/services/api_client_service.dart';
import 'package:ruche_connectee/services/api_ruche_service.dart';
import 'package:ruche_connectee/services/firebase_realtime_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';
import 'package:ruche_connectee/config/service_locator.dart';
import 'package:fl_chart/fl_chart.dart';

/// Helper function to create colors with opacity using Flutter's native method
Color colorWithOpacity(Color color, double opacity) {
  return color.withAlpha((opacity * 255).round());
}

class RucheDetailApiScreen extends StatefulWidget {
  final String rucheId;
  final String rucheNom;

  const RucheDetailApiScreen({
    super.key,
    required this.rucheId,
    required this.rucheNom,
  });

  @override
  State<RucheDetailApiScreen> createState() => _RucheDetailApiScreenState();
}

class _RucheDetailApiScreenState extends State<RucheDetailApiScreen> {
  late final ApiRucheService _apiRucheService;
  late final FirebaseRealtimeService _firebaseService;
  RucheResponse? _ruche;
  List<DonneesCapteur> _mesures = [];
  bool _isLoadingRuche = true;
  bool _isLoadingMesures = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadData();
  }

  void _initializeServices() {
    final firebaseAuth = FirebaseAuth.instance;
    final apiClient = ApiClientService(firebaseAuth);
    _apiRucheService = ApiRucheService(apiClient);
    _firebaseService = getIt<FirebaseRealtimeService>();
  }

  Future<void> _loadData() async {
    LoggerService.info(
        '🐝 Chargement des données pour la ruche ${widget.rucheNom}');
    await Future.wait([
      _loadRucheDetails(),
      _loadMesures7Jours(),
    ]);
  }

  Future<void> _loadRucheDetails() async {
    try {
      setState(() {
        _isLoadingRuche = true;
        _errorMessage = null;
      });

      // Essayer d'abord l'API Spring Boot
      try {
        final ruche = await _apiRucheService.obtenirRucheParId(widget.rucheId);

        setState(() {
          _ruche = ruche;
          _isLoadingRuche = false;
        });
        LoggerService.info('✅ Détails de ruche chargés via API');
        return;
      } catch (apiError) {
        LoggerService.warning(
            '⚠️ API indisponible, utilisation de Realtime Database...');

        // Fallback vers Realtime Database
        try {
          final rucheRealtime = await _loadRucheFromRealtimeDatabase();

          setState(() {
            _ruche = rucheRealtime;
            _isLoadingRuche = false;
          });

          LoggerService.info('🔥 Détails de ruche chargés depuis Realtime Database');

          // Afficher un message d'information sur le fallback
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('API indisponible, utilisation de Realtime Database'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (firebaseError) {
          LoggerService.error('❌ Erreur lors du chargement depuis Realtime Database', firebaseError);
          rethrow;
        }
      }
    } catch (e) {
      LoggerService.error('❌ Erreur lors du chargement des détails de ruche', e);
      setState(() {
        _errorMessage = 'Erreur lors du chargement des détails: ${e.toString()}';
        _isLoadingRuche = false;
      });
    }
  }

  Future<RucheResponse> _loadRucheFromRealtimeDatabase() async {
    try {
      final rucheData = await _firebaseService.getDocument('ruches', widget.rucheId);
      
      if (rucheData == null) {
        throw Exception('Ruche non trouvée dans Realtime Database');
      }

      // Convertir les données Realtime Database en RucheResponse
      return RucheResponse(
        id: widget.rucheId,
        nom: rucheData['nom'] ?? 'Sans nom',
        position: rucheData['position'] ?? 'Position non définie',
        typeRuche: rucheData['typeRuche'] ?? 'Type non défini',
        description: rucheData['description'] ?? '',
        enService: rucheData['enService'] ?? true,
        dateInstallation: rucheData['dateInstallation'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(rucheData['dateInstallation'])
            : DateTime.now(),
        dateCreation: rucheData['dateCreation'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(rucheData['dateCreation'])
            : DateTime.now(),
        idRucher: rucheData['idRucher'] ?? '',
        idApiculteur: rucheData['idApiculteur'] ?? '',
        actif: rucheData['actif'] ?? true,
      );
    } catch (e) {
      LoggerService.error('Erreur lors du chargement depuis Realtime Database', e);
      rethrow;
    }
  }

  Future<void> _loadMesures7Jours() async {
    try {
      setState(() {
        _isLoadingMesures = true;
      });

      // Essayer d'abord l'API Spring Boot
      try {
        final mesures = await _apiRucheService.obtenirMesures7DerniersJours(widget.rucheId);

        setState(() {
          _mesures = mesures;
          _isLoadingMesures = false;
        });
        LoggerService.info('✅ Mesures chargées via API');
        return;
      } catch (apiError) {
        LoggerService.warning(
            '⚠️ API indisponible, utilisation de Realtime Database...');

        // Fallback vers Realtime Database
        try {
          final mesuresRealtime = await _loadMesuresFromRealtimeDatabase();

          setState(() {
            _mesures = mesuresRealtime;
            _isLoadingMesures = false;
          });

          LoggerService.info('🔥 Mesures chargées depuis Realtime Database');
        } catch (firebaseError) {
          LoggerService.error('❌ Erreur lors du chargement des mesures depuis Realtime Database', firebaseError);
          rethrow;
        }
      }
    } catch (e) {
      LoggerService.error('❌ Erreur lors du chargement des mesures', e);
      setState(() {
        _isLoadingMesures = false;
      });
    }
  }

  Future<List<DonneesCapteur>> _loadMesuresFromRealtimeDatabase() async {
    try {
      final mesuresData = await _firebaseService.getDocuments('mesures', 'idRuche', widget.rucheId);
      
      // Filtrer les mesures des 7 derniers jours
      final maintenant = DateTime.now();
      final ilYA7Jours = maintenant.subtract(const Duration(days: 7));
      
      final mesuresFiltrees = mesuresData.where((mesure) {
        final timestamp = mesure['timestamp'] as int?;
        if (timestamp == null) return false;
        
        final dateMesure = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return dateMesure.isAfter(ilYA7Jours);
      }).toList();

      // Trier par timestamp décroissant
      mesuresFiltrees.sort((a, b) {
        final timestampA = a['timestamp'] as int? ?? 0;
        final timestampB = b['timestamp'] as int? ?? 0;
        return timestampB.compareTo(timestampA);
      });

      // Convertir en DonneesCapteur
      return mesuresFiltrees.map((mesure) => DonneesCapteur(
        id: mesure['id'] ?? '',
        rucheId: widget.rucheId,
        temperature: (mesure['temperature'] as num?)?.toDouble() ?? 0.0,
        humidity: (mesure['humidite'] as num?)?.toDouble() ?? 0.0,
        timestamp: mesure['timestamp'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(mesure['timestamp'])
            : DateTime.now(),
      )).toList();
    } catch (e) {
      LoggerService.error('Erreur lors du chargement des mesures depuis Realtime Database', e);
      rethrow;
    }
  }



  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildRucheInfoCard() {
    if (_ruche == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations générales',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Nom', _ruche!.nom),
            const Divider(),
            _buildInfoRow('Position', _ruche!.position),
            const Divider(),
            _buildInfoRow('Rucher', _ruche!.rucherNom ?? 'Non défini'),
            if (_ruche!.typeRuche != null) ...[
              const Divider(),
              _buildInfoRow('Type de ruche', _ruche!.typeRuche!),
            ],
            if (_ruche!.description != null &&
                _ruche!.description!.isNotEmpty) ...[
              const Divider(),
              _buildInfoRow('Description', _ruche!.description!),
            ],
            const Divider(),
            _buildStatusRow(),
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
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              'Statut',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _ruche!.enService
                  ? colorWithOpacity(Colors.green, 0.2)
                  : colorWithOpacity(Colors.orange, 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _ruche!.enService ? Icons.check_circle : Icons.warning,
                  size: 16,
                  color: _ruche!.enService ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  _ruche!.enService ? 'En service' : 'Hors service',
                  style: TextStyle(
                    color: _ruche!.enService ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMesuresTab() {
    if (_isLoadingMesures) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mesures.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.analytics_outlined,
                  size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Aucune mesure disponible',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Les données apparaîtront ici dès que les capteurs transmettront des mesures',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _generateTestData,
                icon: const Icon(Icons.science),
                label: const Text('Générer des données de test'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cela créera 100 mesures de test dans Firestore',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMesuresStatsCard(),
          const SizedBox(height: 16),
          _buildTemperatureChart(),
          const SizedBox(height: 16),
          _buildHumidityChart(),
          const SizedBox(height: 16),
          _buildRecentMeasuresList(),
        ],
      ),
    );
  }

  Widget _buildMesuresStatsCard() {
    if (_mesures.isEmpty) return const SizedBox.shrink();

    final tempMesures =
        _mesures.where((m) => m.temperature != null).map((m) => m.temperature!);
    final humidityMesures =
        _mesures.where((m) => m.humidity != null).map((m) => m.humidity!);

    final tempMin = tempMesures.isNotEmpty
        ? tempMesures.reduce((a, b) => a < b ? a : b)
        : 0.0;
    final tempMax = tempMesures.isNotEmpty
        ? tempMesures.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final tempMoy = tempMesures.isNotEmpty
        ? tempMesures.reduce((a, b) => a + b) / tempMesures.length
        : 0.0;

    final humMin = humidityMesures.isNotEmpty
        ? humidityMesures.reduce((a, b) => a < b ? a : b)
        : 0.0;
    final humMax = humidityMesures.isNotEmpty
        ? humidityMesures.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final humMoy = humidityMesures.isNotEmpty
        ? humidityMesures.reduce((a, b) => a + b) / humidityMesures.length
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques des 7 derniers jours',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatColumn('Température', tempMin, tempMax,
                      tempMoy, '°C', Colors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatColumn(
                      'Humidité', humMin, humMax, humMoy, '%', Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, double min, double max, double moy,
      String unit, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        _buildStatRow('Min', '${min.toStringAsFixed(1)}$unit'),
        _buildStatRow('Max', '${max.toStringAsFixed(1)}$unit'),
        _buildStatRow('Moy', '${moy.toStringAsFixed(1)}$unit'),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTemperatureChart() {
    final tempData = _mesures
        .where((m) => m.temperature != null)
        .map((m) => FlSpot(
              m.timestamp.millisecondsSinceEpoch.toDouble(),
              m.temperature!,
            ))
        .toList();

    if (tempData.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Évolution de la température',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250, // Augmenté pour plus d'espace
              child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 16),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval:
                          2, // Espacement des lignes horizontales
                      verticalInterval:
                          86400000 * 1000, // 1 jour en millisecondes
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: colorWithOpacity(Colors.grey, 0.2),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: colorWithOpacity(Colors.grey, 0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35, // Plus d'espace pour les labels
                          interval: 86400000 *
                              1000 *
                              1.5, // Afficher un label tous les 1.5 jours
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt());
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Transform.rotate(
                                angle:
                                    -0.5, // Légère rotation pour éviter le chevauchement
                                child: Text(
                                  '${date.day}/${date.month}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40, // Plus d'espace pour les labels
                          interval: 5, // Un label tous les 5°C
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                '${value.toInt()}°',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border:
                          Border.all(color: colorWithOpacity(Colors.grey, 0.3)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: tempData,
                        isCurved: true,
                        color: Colors.orange,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: colorWithOpacity(Colors.orange, 0.1),
                        ),
                      ),
                    ],
                    minY: tempData.isNotEmpty
                        ? tempData
                                .map((e) => e.y)
                                .reduce((a, b) => a < b ? a : b) -
                            2
                        : 0,
                    maxY: tempData.isNotEmpty
                        ? tempData
                                .map((e) => e.y)
                                .reduce((a, b) => a > b ? a : b) +
                            2
                        : 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHumidityChart() {
    final humidityData = _mesures
        .where((m) => m.humidity != null)
        .map((m) => FlSpot(
              m.timestamp.millisecondsSinceEpoch.toDouble(),
              m.humidity!,
            ))
        .toList();

    if (humidityData.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Évolution de l\'humidité',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250, // Augmenté pour plus d'espace
              child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 16),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval:
                          10, // Espacement des lignes horizontales (10% pour humidité)
                      verticalInterval:
                          86400000 * 1000, // 1 jour en millisecondes
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: colorWithOpacity(Colors.grey, 0.2),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: colorWithOpacity(Colors.grey, 0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35, // Plus d'espace pour les labels
                          interval: 86400000 *
                              1000 *
                              1.5, // Afficher un label tous les 1.5 jours
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                                value.toInt());
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Transform.rotate(
                                angle:
                                    -0.5, // Légère rotation pour éviter le chevauchement
                                child: Text(
                                  '${date.day}/${date.month}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40, // Plus d'espace pour les labels
                          interval: 10, // Un label tous les 10%
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                '${value.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border:
                          Border.all(color: colorWithOpacity(Colors.grey, 0.3)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: humidityData,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: colorWithOpacity(Colors.blue, 0.1),
                        ),
                      ),
                    ],
                    minY: humidityData.isNotEmpty
                        ? (humidityData
                                    .map((e) => e.y)
                                    .reduce((a, b) => a < b ? a : b) -
                                5)
                            .clamp(0, 100)
                        : 0,
                    maxY: humidityData.isNotEmpty
                        ? (humidityData
                                    .map((e) => e.y)
                                    .reduce((a, b) => a > b ? a : b) +
                                5)
                            .clamp(0, 100)
                        : 100,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMeasuresList() {
    final recentMeasures = _mesures.take(10).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mesures récentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...recentMeasures.map((mesure) => _buildMeasureItem(mesure)),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasureItem(DonneesCapteur mesure) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorWithOpacity(Colors.grey, 0.2)),
      ),
      child: Column(
        children: [
          // Ligne 1: Date et heure
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                _formatDateTime(mesure.timestamp),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Ligne 2: Mesures (température, humidité, batterie)
          Row(
            children: [
              // Température
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorWithOpacity(Colors.orange, 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.thermostat,
                          size: 18, color: Colors.orange[700]),
                      const SizedBox(width: 6),
                      Text(
                        mesure.temperature != null
                            ? '${mesure.temperature!.toStringAsFixed(1)}°C'
                            : '--',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Humidité
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorWithOpacity(Colors.blue, 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.water_drop, size: 18, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Text(
                        mesure.humidity != null
                            ? '${mesure.humidity!.toStringAsFixed(1)}%'
                            : '--',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (mesure.batterie != null) ...[
                const SizedBox(width: 8),
                // Batterie
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorWithOpacity(Colors.green, 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.battery_full,
                          size: 16, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        '${mesure.batterie}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Génère des données de test dans Firestore
  Future<void> _generateTestData() async {
    try {
      // Afficher un dialog de confirmation
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Générer des données de test'),
          content: const Text(
            'Cela va créer 100 mesures de test dans Firestore pour cette ruche. '
            'Cette action est irréversible. Continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Générer'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Afficher le loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Génération des données...'),
            ],
          ),
        ),
      );

      LoggerService.info('🧪 Génération de données de test en cours...');

             // Utiliser Realtime Database au lieu de Firestore
       final firebaseService = getIt<FirebaseRealtimeService>();

      // Générer 100 mesures sur les 7 derniers jours
      final now = DateTime.now();
      for (int i = 0; i < 100; i++) {
        // Répartir les mesures sur 7 jours
        final hoursAgo = (i / 100 * 7 * 24).round();
        final timestamp = now.subtract(Duration(hours: hoursAgo));

        // Générer des valeurs réalistes avec variation
        const baseTemp = 25.0;
        final tempVariation = (i % 20 - 10) * 0.5; // Variation de -5 à +5°C
        final temperature =
            baseTemp + tempVariation + (DateTime.now().millisecond % 100) / 100;

        const baseHumidity = 60.0;
        final humidityVariation =
            (i % 30 - 15) * 0.8; // Variation de -12 à +12%
        final humidity = baseHumidity +
            humidityVariation +
            (DateTime.now().microsecond % 100) / 100;

        final mesureId = '${DateTime.now().millisecondsSinceEpoch}_$i';
        
        await firebaseService.setDocument('mesures', mesureId, {
          'rucheId': widget.rucheId,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'temperature': double.parse(temperature.toStringAsFixed(1)),
          'humidite': double.parse(humidity.toStringAsFixed(1)),
          'couvercleOuvert': i % 20 == 0, // Couvercle ouvert 5% du temps
          'batterie': 100 - (i ~/ 10), // Batterie qui diminue progressivement
          'signalQualite': 80 + (i % 20), // Signal entre 80 et 99
          'erreur': null,
        });
      }

      LoggerService.info('✅ Données de test générées avec succès');

      // Fermer le dialog de loading
      if (mounted) Navigator.of(context).pop();

      // Recharger les mesures
      await _loadMesures7Jours();

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('100 mesures de test générées avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      LoggerService.error(
          'Erreur lors de la génération des données de test', e);

      // Fermer le dialog de loading si ouvert
      if (mounted) Navigator.of(context).pop();

      // Afficher l'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rucheNom),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoadingRuche
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
                          onPressed: _loadData,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    _buildRucheInfoCard(),
                    Expanded(child: _buildMesuresTab()),
                  ],
                ),
    );
  }
}
