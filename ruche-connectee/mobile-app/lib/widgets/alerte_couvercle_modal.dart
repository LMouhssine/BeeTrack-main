import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ruche_connectee/models/api_models.dart';

/// Helper function to create colors with opacity without deprecation warnings
Color colorWithOpacity(Color color, double opacity) {
  return Color.fromARGB(
    (opacity * 255).round(),
    (color.r * 255.0).round() & 0xff,
    (color.g * 255.0).round() & 0xff,
    (color.b * 255.0).round() & 0xff,
  );
}

class AlerteCouvercleModal extends StatefulWidget {
  final String rucheId;
  final String? rucheNom;
  final DonneesCapteur mesure;
  final Function(double dureeHeures) onIgnorerTemporairement;
  final VoidCallback onIgnorerSession;
  final VoidCallback onFermer;

  const AlerteCouvercleModal({
    Key? key,
    required this.rucheId,
    this.rucheNom,
    required this.mesure,
    required this.onIgnorerTemporairement,
    required this.onIgnorerSession,
    required this.onFermer,
  }) : super(key: key);

  @override
  State<AlerteCouvercleModal> createState() => _AlerteCouvercleModalState();
}

class _AlerteCouvercleModalState extends State<AlerteCouvercleModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  double _dureeSelectionnee = 1.0;

  final List<Map<String, dynamic>> _dureeOptions = [
    {'value': 0.5, 'label': '30 minutes'},
    {'value': 1.0, 'label': '1 heure'},
    {'value': 2.0, 'label': '2 heures'},
    {'value': 4.0, 'label': '4 heures'},
    {'value': 8.0, 'label': '8 heures'},
    {'value': 24.0, 'label': '24 heures'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                                              color: colorWithOpacity(Colors.black, 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      _buildContent(),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red, Colors.orange],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                              color: colorWithOpacity(Colors.white, 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ Alerte Ruche',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Couvercle ouvert détecté',
                  style: TextStyle(
                    color: Colors.red.shade100,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRucheInfo(),
          const SizedBox(height: 16),
          if (_hasAdditionalMeasures()) _buildAdditionalMeasures(),
          if (_hasAdditionalMeasures()) const SizedBox(height: 16),
          _buildActionRecommendation(),
          const SizedBox(height: 20),
          _buildIgnoreOptions(),
        ],
      ),
    );
  }

  Widget _buildRucheInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.rucheNom ?? 'Ruche ${widget.rucheId}',
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '🚨 Le couvercle de la ruche est actuellement ouvert !',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dernière mesure : ${_formatDate(widget.mesure.timestamp)}',
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAdditionalMeasures() {
    return widget.mesure.temperature != null ||
        widget.mesure.humidity != null ||
        widget.mesure.batterie != null;
  }

  Widget _buildAdditionalMeasures() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Autres mesures :',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (widget.mesure.temperature != null)
                _buildMeasureChip(
                  'Température',
                  '${widget.mesure.temperature!.toStringAsFixed(1)}°C',
                  Icons.thermostat,
                  Colors.blue,
                ),
              if (widget.mesure.humidity != null)
                _buildMeasureChip(
                  'Humidité',
                  '${widget.mesure.humidity!.toStringAsFixed(1)}%',
                  Icons.water_drop,
                  Colors.green,
                ),
              if (widget.mesure.batterie != null)
                _buildMeasureChip(
                  'Batterie',
                  '${widget.mesure.batterie}%',
                  Icons.battery_std,
                  _getBatteryColor(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor() {
    final batterie = widget.mesure.batterie!;
    if (batterie > 50) return Colors.green;
    if (batterie > 20) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMeasureChip(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
                  color: colorWithOpacity(color, 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorWithOpacity(color, 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
                              color: colorWithOpacity(color, 0.8),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRecommendation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.amber.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Action recommandée :',
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vérifiez immédiatement l\'état de votre ruche. Un couvercle ouvert peut exposer la colonie aux intempéries et aux prédateurs.',
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIgnoreOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options de gestion de l\'alerte :',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        _buildTemporaryIgnoreOption(),
        const SizedBox(height: 16),
        _buildSessionIgnoreOption(),
      ],
    );
  }

  Widget _buildTemporaryIgnoreOption() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, size: 18, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                'Ignorer temporairement',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<double>(
            value: _dureeSelectionnee,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue.shade500, width: 2),
              ),
            ),
            items: _dureeOptions.map((option) {
              return DropdownMenuItem<double>(
                value: option['value'] as double,
                child: Text(option['label'] as String),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _dureeSelectionnee = value!;
              });
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  widget.onIgnorerTemporairement(_dureeSelectionnee),
              icon: const Icon(Icons.schedule, size: 16),
              label: Text(
                'Ignorer pour ${_dureeOptions.firstWhere((o) => o['value'] == _dureeSelectionnee)['label']}',
              ),
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
        ],
      ),
    );
  }

  Widget _buildSessionIgnoreOption() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_off,
                  size: 18, color: Colors.purple.shade600),
              const SizedBox(width: 8),
              Text(
                'Ignorer pour cette session',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'L\'alerte sera ignorée jusqu\'à ce que vous fermiez l\'application.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onIgnorerSession,
              icon: const Icon(Icons.visibility_off, size: 16),
              label: const Text('Ignorer pour cette session'),
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
    );
  }

  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onFermer,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Fermer (continuer à surveiller)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'En fermant cette alerte, la surveillance continue en arrière-plan',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
