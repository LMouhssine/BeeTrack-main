import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ruche_connectee/config/service_locator.dart';
import 'package:ruche_connectee/services/api_client_service.dart';
import 'package:ruche_connectee/models/api_models.dart';
import 'package:ruche_connectee/config/api_config.dart';

class ApiHealthWidget extends StatefulWidget {
  const ApiHealthWidget({Key? key}) : super(key: key);

  @override
  State<ApiHealthWidget> createState() => _ApiHealthWidgetState();
}

class _ApiHealthWidgetState extends State<ApiHealthWidget> {
  HealthResponse? _healthStatus;
  HealthResponse? _authHealthStatus;
  bool _isLoading = false;
  String? _errorMessage;
  String? _authErrorMessage;

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _authErrorMessage = null;
    });

    // Test 1: Health check public (sans authentification)
    await _checkPublicHealth();

    // Test 2: Health check avec authentification
    await _checkAuthHealth();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkPublicHealth() async {
    try {
      // Appel direct sans authentification
      final dio = Dio();
      final response = await dio.get(ApiConfig.fullHealthUrl);

      final health = HealthResponse.fromJson(response.data);
      setState(() {
        _healthStatus = health;
      });
    } catch (e) {
      setState(() {
        if (e is DioException) {
          _errorMessage = 'Erreur ${e.response?.statusCode}: ${e.message}';
        } else {
          _errorMessage = 'Erreur de connexion: $e';
        }
      });
    }
  }

  Future<void> _checkAuthHealth() async {
    try {
      final apiClient = getIt<ApiClientService>();

      // Appel avec authentification
      final response = await apiClient.get(ApiConfig.healthAuthEndpoint);
      final health = HealthResponse.fromJson(response.data);

      setState(() {
        _authHealthStatus = health;
      });
    } catch (e) {
      setState(() {
        if (e is ApiException) {
          _authErrorMessage = e.message;
        } else {
          _authErrorMessage = 'Erreur auth: $e';
        }
      });
    }
  }

  Color _getStatusColor(bool isAuth) {
    if (isAuth) {
      if (_authErrorMessage != null) return Colors.red;
      if (_authHealthStatus?.isHealthy == true) return Colors.green;
    } else {
      if (_errorMessage != null) return Colors.red;
      if (_healthStatus?.isHealthy == true) return Colors.green;
    }
    return Colors.orange;
  }

  String _getStatusText(bool isAuth) {
    if (isAuth) {
      if (_authErrorMessage != null) return 'Échec Auth';
      if (_authHealthStatus?.isHealthy == true) return 'OK Auth';
    } else {
      if (_errorMessage != null) return 'Hors ligne';
      if (_healthStatus?.isHealthy == true) return 'En ligne';
    }
    return 'Test...';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.api, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'API Spring Boot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    onPressed: _checkHealth,
                    icon: const Icon(Icons.refresh, size: 16),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Test de connectivité public
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor(false),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Connectivité: ',
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                Text(
                  _getStatusText(false),
                  style: TextStyle(
                    color: _getStatusColor(false),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Test d'authentification
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor(true),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Authentification: ',
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                Text(
                  _getStatusText(true),
                  style: TextStyle(
                    color: _getStatusColor(true),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'URL: ${ApiConfig.baseUrl}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                'Erreur connectivité: $_errorMessage',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ],

            if (_authErrorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                'Erreur auth: $_authErrorMessage',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ],

            if (_healthStatus != null || _authHealthStatus != null) ...[
              const SizedBox(height: 8),
              Text(
                'Dernière vérification: ${DateTime.now().toString().substring(0, 19)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _checkHealth,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Tester la connexion'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
