import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ruche_connectee/services/rucher_service.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';

class AjouterRucherScreen extends StatefulWidget {
  const AjouterRucherScreen({Key? key}) : super(key: key);

  @override
  State<AjouterRucherScreen> createState() => _AjouterRucherScreenState();
}

class _AjouterRucherScreenState extends State<AjouterRucherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _adresseController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  late final RucherService _rucherService;

  @override
  void initState() {
    super.initState();
    // Initialiser le service avec l'instance Firebase
    _rucherService = RucherService(GetIt.I<FirebaseService>());
  }

  @override
  void dispose() {
    _nomController.dispose();
    _adresseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _ajouterRucher() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Utiliser le service pour ajouter le rucher
      final String rucherId = await _rucherService.ajouterRucher(
        nom: _nomController.text,
        adresse: _adresseController.text,
        description: _descriptionController.text,
      );

      if (!mounted) return;

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rucher "${_nomController.text}" créé avec succès !'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      LoggerService.info('Rucher créé avec l\'ID: $rucherId');

      // Retourner à l'écran précédent
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      // Afficher l'erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );

      LoggerService.error('Erreur lors de l\'ajout du rucher', e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un rucher'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // En-tête avec icône
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.home_work,
                      size: 48,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nouveau rucher',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.amber.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Créez un nouvel emplacement pour vos ruches',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Champ nom du rucher
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom du rucher *',
                  hintText: 'Ex: Rucher du verger',
                  prefixIcon: const Icon(Icons.label),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom du rucher est obligatoire';
                  }
                  if (value.trim().length < 2) {
                    return 'Le nom doit contenir au moins 2 caractères';
                  }
                  if (value.trim().length > 50) {
                    return 'Le nom ne peut pas dépasser 50 caractères';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
                enabled: !_isLoading,
              ),

              const SizedBox(height: 16),

              // Champ adresse
              TextFormField(
                controller: _adresseController,
                decoration: InputDecoration(
                  labelText: 'Adresse *',
                  hintText: 'Ex: 123 Rue des Abeilles, 75001 Paris',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'L\'adresse est obligatoire';
                  }
                  if (value.trim().length < 5) {
                    return 'L\'adresse doit contenir au moins 5 caractères';
                  }
                  if (value.trim().length > 200) {
                    return 'L\'adresse ne peut pas dépasser 200 caractères';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
                maxLines: 2,
                enabled: !_isLoading,
              ),

              const SizedBox(height: 16),

              // Champ description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  hintText:
                      'Décrivez votre rucher (environnement, particularités...)',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La description est obligatoire';
                  }
                  if (value.trim().length < 10) {
                    return 'La description doit contenir au moins 10 caractères';
                  }
                  if (value.trim().length > 500) {
                    return 'La description ne peut pas dépasser 500 caractères';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                enabled: !_isLoading,
              ),

              const SizedBox(height: 24),

              // Note d'information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Le rucher sera automatiquement associé à votre compte.',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _ajouterRucher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            )
                          : const Text(
                              'Créer le rucher',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
}
