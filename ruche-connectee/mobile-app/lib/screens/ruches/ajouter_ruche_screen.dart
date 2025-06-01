import 'package:flutter/material.dart';
import 'package:ruche_connectee/config/service_locator.dart';
import 'package:ruche_connectee/services/api_ruche_service.dart';
import 'package:ruche_connectee/services/api_client_service.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';
import 'package:ruche_connectee/screens/ruches/ruche_detail_screen.dart';
import 'package:go_router/go_router.dart';

class AjouterRucheScreen extends StatefulWidget {
  final String? rucherId; // Si fourni, pré-sélectionne ce rucher

  const AjouterRucheScreen({
    Key? key,
    this.rucherId,
  }) : super(key: key);

  @override
  State<AjouterRucheScreen> createState() => _AjouterRucheScreenState();
}

class _AjouterRucheScreenState extends State<AjouterRucheScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _positionController = TextEditingController();
  final _typeRucheController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _enService = true;
  DateTime _dateInstallation = DateTime.now();
  String? _selectedRucherId;
  
  bool _isLoading = false;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _ruchers = [];
  
  late final ApiRucheService _apiRucheService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _selectedRucherId = widget.rucherId;
    _loadRuchers();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _positionController.dispose();
    _typeRucheController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  void _initializeServices() {
    _apiRucheService = getIt<ApiRucheService>();
  }

  Future<void> _loadRuchers() async {
    try {
      setState(() => _isLoading = true);
      
      final currentUser = getIt<FirebaseService>().auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final querySnapshot = await getIt<FirebaseService>()
          .firestore
          .collection('ruchers')
          .where('idApiculteur', isEqualTo: currentUser.uid)
          .where('actif', isEqualTo: true)
          .orderBy('nom')
          .get();

      final ruchers = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _ruchers = ruchers;
      });

      // Si aucun rucher n'est trouvé
      if (_ruchers.isEmpty) {
        _showErrorDialog(
          'Aucun rucher disponible',
          'Vous devez d\'abord créer un rucher avant d\'ajouter des ruches.',
        );
      }
    } catch (e) {
      LoggerService.error('Erreur lors du chargement des ruchers', e);
      _showErrorSnackBar('Erreur lors du chargement des ruchers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _ajouterRuche() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRucherId == null) {
      _showErrorSnackBar('Veuillez sélectionner un rucher');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final rucheResponse = await _apiRucheService.ajouterRuche(
        idRucher: _selectedRucherId!,
        nom: _nomController.text.trim(),
        position: _positionController.text.trim(),
        typeRuche: _typeRucheController.text.trim().isNotEmpty 
            ? _typeRucheController.text.trim() 
            : null,
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        enService: _enService,
        dateInstallation: _dateInstallation,
      );

      if (!mounted) return;

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ruche "${rucheResponse.nom}" créée avec succès'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Voir',
            textColor: Colors.white,
            onPressed: () {
              // Naviguer vers les détails de la ruche
              GoRouter.of(context).go('/ruches/${rucheResponse.id}');
            },
          ),
        ),
      );

      // Revenir à l'écran précédent avec un délai pour voir le message
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.of(context).pop(true); // true indique que la ruche a été créée

    } catch (e) {
      LoggerService.error('Erreur lors de l\'ajout de la ruche', e);
      
      String errorMessage = 'Erreur lors de l\'ajout';
      if (e is RucheApiException) {
        errorMessage = e.message;
      } else if (e is ApiException) {
        errorMessage = e.message;
      }
      
      _showErrorSnackBar(errorMessage);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
  
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Retourner à l'écran précédent
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une ruche'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // En-tête avec icône
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.hive,
                              size: 48,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Nouvelle ruche',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Remplissez les informations de votre nouvelle ruche',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // Sélection du rucher
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rucher de destination',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedRucherId,
                              decoration: const InputDecoration(
                                labelText: 'Sélectionner un rucher',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_city),
                              ),
                              items: [
                                if (_ruchers.isEmpty)
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Aucun rucher disponible'),
                                  )
                                else ...[
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('Choisir un rucher...'),
                                  ),
                                  ..._ruchers.map((rucher) {
                                    return DropdownMenuItem(
                                      value: rucher['id'],
                                      child: Text(
                                        rucher['nom'] ?? 'Sans nom',
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ],
                              ],
                              onChanged: _ruchers.isEmpty ? null : (value) {
                                setState(() => _selectedRucherId = value);
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez sélectionner un rucher';
                                }
                                return null;
                              },
                            ),
                            if (_selectedRucherId != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Rucher sélectionné',
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Afficher les détails du rucher sélectionné
                                    () {
                                      final rucherSelectionne = _ruchers.firstWhere(
                                        (r) => r['id'] == _selectedRucherId,
                                        orElse: () => <String, dynamic>{},
                                      );
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            rucherSelectionne['nom'] ?? 'Sans nom',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (rucherSelectionne['adresse'] != null)
                                            Text(
                                              rucherSelectionne['adresse'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      );
                                    }(),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Informations de la ruche
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informations de la ruche',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Nom de la ruche
                            TextFormField(
                              controller: _nomController,
                              decoration: const InputDecoration(
                                labelText: 'Nom de la ruche',
                                hintText: 'Ex: Ruche A1, Ruche du Printemps...',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.label),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Le nom de la ruche est requis';
                                }
                                if (value.trim().length < 2) {
                                  return 'Le nom doit contenir au moins 2 caractères';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Position
                            TextFormField(
                              controller: _positionController,
                              decoration: const InputDecoration(
                                labelText: 'Position dans le rucher',
                                hintText: 'Ex: A1, B2, Rangée 1-Position 3...',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.place),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'La position est requise';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Type de ruche
                            TextFormField(
                              controller: _typeRucheController,
                              decoration: const InputDecoration(
                                labelText: 'Type de ruche (optionnel)',
                                hintText: 'Ex: Dadant, Langstroth, Warré...',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Description
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Description (optionnel)',
                                hintText: 'Informations complémentaires sur la ruche...',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                                alignLabelWithHint: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Configuration
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Configuration',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Statut en service
                            SwitchListTile(
                              title: const Text('Ruche en service'),
                              subtitle: Text(
                                _enService 
                                    ? 'La ruche est opérationnelle'
                                    : 'La ruche est hors service',
                              ),
                              value: _enService,
                              onChanged: (value) {
                                setState(() => _enService = value);
                              },
                              secondary: Icon(
                                _enService ? Icons.check_circle : Icons.warning,
                                color: _enService ? Colors.green : Colors.orange,
                              ),
                            ),
                            
                            const Divider(),
                            
                            // Date d'installation
                            ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: const Text('Date d\'installation'),
                              subtitle: Text(_formatDate(_dateInstallation)),
                              trailing: const Icon(Icons.edit),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _dateInstallation,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                  locale: const Locale('fr', 'FR'),
                                );
                                if (date != null) {
                                  setState(() => _dateInstallation = date);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Boutons d'action
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting ? null : () {
                              Navigator.of(context).pop();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('Annuler'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _ajouterRuche,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add),
                                        SizedBox(width: 8),
                                        Text('Créer la ruche'),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
} 