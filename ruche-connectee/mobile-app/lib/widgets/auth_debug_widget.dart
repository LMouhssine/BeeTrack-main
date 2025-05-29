import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruche_connectee/services/logger_service.dart';

class AuthDebugWidget extends StatefulWidget {
  const AuthDebugWidget({Key? key}) : super(key: key);

  @override
  State<AuthDebugWidget> createState() => _AuthDebugWidgetState();
}

class _AuthDebugWidgetState extends State<AuthDebugWidget> {
  User? _currentUser;
  String? _idToken;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      setState(() {
        _currentUser = user;
      });

      if (user != null) {
        LoggerService.debug('Utilisateur trouvé: ${user.uid}');
        
        // Essayer d'obtenir le token
        try {
          final token = await user.getIdToken(false);
          setState(() {
            _idToken = token;
          });
          LoggerService.info('Token obtenu avec succès (${token?.length} caractères)');
        } catch (tokenError) {
          LoggerService.error('Erreur lors de l\'obtention du token', tokenError);
          setState(() {
            _error = 'Erreur token: $tokenError';
          });
        }
      } else {
        LoggerService.warning('Aucun utilisateur connecté');
      }
    } catch (e) {
      LoggerService.error('Erreur lors de la vérification de l\'authentification', e);
      setState(() {
        _error = 'Erreur auth: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshToken() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _currentUser!.getIdToken(true); // Force refresh
      setState(() {
        _idToken = token;
      });
      LoggerService.info('Token rafraîchi avec succès');
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token rafraîchi avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      LoggerService.error('Erreur lors du rafraîchissement du token', e);
      setState(() {
        _error = 'Erreur refresh: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'État Authentification',
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
                    onPressed: _checkAuthStatus,
                    icon: const Icon(Icons.refresh, size: 16),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // État de l'utilisateur
            _buildInfoRow(
              'Utilisateur connecté',
              _currentUser != null ? 'Oui' : 'Non',
              _currentUser != null ? Colors.green : Colors.red,
            ),
            
            if (_currentUser != null) ...[
              _buildInfoRow('UID', _currentUser!.uid),
              _buildInfoRow('Email', _currentUser!.email ?? 'Non défini'),
              _buildInfoRow('Nom', _currentUser!.displayName ?? 'Non défini'),
              _buildInfoRow('Email vérifié', _currentUser!.emailVerified ? 'Oui' : 'Non'),
              
              const SizedBox(height: 8),
              
              // État du token
              _buildInfoRow(
                'Token JWT',
                _idToken != null ? 'Présent (${_idToken!.length} car.)' : 'Non disponible',
                _idToken != null ? Colors.green : Colors.red,
              ),
              
              if (_idToken != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Début du token: ${_idToken!.substring(0, 50)}...',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
            
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Boutons d'action
            Wrap(
              spacing: 8,
              children: [
                if (_currentUser != null)
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _refreshToken,
                    icon: const Icon(Icons.refresh, size: 14),
                    label: const Text('Rafraîchir token'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _checkAuthStatus,
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text('Vérifier état'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 