import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RucheCard extends StatelessWidget {
  final String id;
  final String name;
  final String rucherName;
  final double temperature;
  final double humidity;
  final bool lidOpen;
  final DateTime lastUpdate;
  final int batteryLevel;
  final VoidCallback onTap;

  const RucheCard({
    Key? key,
    required this.id,
    required this.name,
    required this.rucherName,
    required this.temperature,
    required this.humidity,
    required this.lidOpen,
    required this.lastUpdate,
    required this.batteryLevel,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    // Déterminer la couleur de statut
    Color statusColor = Colors.green;
    String statusText = 'Normal';
    
    if (lidOpen) {
      statusColor = Colors.red;
      statusText = 'Couvercle ouvert';
    } else if (temperature > 35 || temperature < 10) {
      statusColor = Colors.orange;
      statusText = 'Température anormale';
    } else if (humidity > 80 || humidity < 40) {
      statusColor = Colors.orange;
      statusText = 'Humidité anormale';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          rucherName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          lidOpen ? Icons.warning : Icons.check_circle,
                          color: statusColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Données des capteurs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSensorData(
                    context,
                    Icons.thermostat,
                    '$temperature°C',
                    'Température',
                    temperature > 35 || temperature < 10
                        ? Colors.orange
                        : Colors.black,
                  ),
                  _buildSensorData(
                    context,
                    Icons.water_drop,
                    '$humidity%',
                    'Humidité',
                    humidity > 80 || humidity < 40
                        ? Colors.orange
                        : Colors.black,
                  ),
                  _buildSensorData(
                    context,
                    lidOpen ? Icons.lock_open : Icons.lock,
                    lidOpen ? 'Ouvert' : 'Fermé',
                    'Couvercle',
                    lidOpen ? Colors.red : Colors.black,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Pied de carte avec batterie et dernière mise à jour
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        batteryLevel > 80
                            ? Icons.battery_full
                            : batteryLevel > 50
                                ? Icons.battery_5_bar
                                : batteryLevel > 20
                                    ? Icons.battery_3_bar
                                    : Icons.battery_1_bar,
                        color: batteryLevel > 20
                            ? Colors.green
                            : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$batteryLevel%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Mise à jour: ${dateFormat.format(lastUpdate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSensorData(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color valueColor,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}