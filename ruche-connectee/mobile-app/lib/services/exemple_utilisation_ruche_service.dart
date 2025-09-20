import 'package:flutter/material.dart';
import 'package:ruche_connectee/services/ruche_service.dart';
import 'package:ruche_connectee/services/firebase_realtime_service.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';

/// Exemple d'utilisation du RucheService dans un widget Flutter
///
/// Ce widget démontre comment :
/// - Ajouter une nouvelle ruche
/// - Afficher la liste des ruches d'un rucher
/// - Modifier une ruche existante
/// - Supprimer une ruche
/// - Écouter les changements en temps réel

class ExempleGestionRuches extends StatefulWidget {
  final String idRucher;
  final String nomRucher;

  const ExempleGestionRuches({
    super.key,
    required this.idRucher,
    required this.nomRucher,
  });

  @override
  State<ExempleGestionRuches> createState() => _ExempleGestionRuchesState();
}

class _ExempleGestionRuchesState extends State<ExempleGestionRuches> {
  // Services
  late final RucheService _rucheService;

  // État local
  List<Map<String, dynamic>> _ruches = [];
  bool _isLoading = false;
  bool _isAddingRuche = false;

  // Controllers pour les formulaires
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  bool _enService = true;
  DateTime _dateInstallation = DateTime.now();

  // Subscription pour l'écoute temps réel
  StreamSubscription<List<Map<String, dynamic>>>? _ruchesSubscription;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _startListeningToRuches();
  }

  @override
  void dispose() {
    _ruchesSubscription?.cancel();
    _nomController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _initializeService() {
    final firebaseService = GetIt.I<FirebaseRealtimeService>();
    _rucheService = RucheService(firebaseService);
  }

  /// Démarre l'écoute des ruches en temps réel
  void _startListeningToRuches() {
    _ruchesSubscription =
        _rucheService.ecouterRuchesParRucher(widget.idRucher).listen(
      (ruches) {
        if (mounted) {
          setState(() {
            _ruches = ruches;
          });
        }
      },
      onError: (error) {
        _showErrorSnackBar('Erreur d\'écoute temps réel: $error');
      },
    );
  }

  /// Ajoute une nouvelle ruche
  Future<void> _ajouterRuche() async {
    if (!_validateForm()) return;

    setState(() => _isAddingRuche = true);

    try {
      final rucheId = await _rucheService.ajouterRuche(
        idRucher: widget.idRucher,
        nom: _nomController.text.trim(),
        position: _positionController.text.trim(),
        enService: _enService,
        dateInstallation: _dateInstallation,
      );

      _showSuccessSnackBar('Ruche créée avec succès (ID: $rucheId)');
      _clearForm();
      if (!mounted) return;
      Navigator.of(context).pop(); // Fermer le dialog
    } catch (e) {
      _showErrorSnackBar('Erreur lors de l\'ajout: $e');
    } finally {
      setState(() => _isAddingRuche = false);
    }
  }

  /// Supprime une ruche
  Future<void> _supprimerRuche(String rucheId, String nomRuche) async {
    final bool? confirmed = await _showConfirmationDialog(
      'Supprimer la ruche',
      'Êtes-vous sûr de vouloir supprimer la ruche "$nomRuche" ?',
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await _rucheService.supprimerRuche(rucheId);
      _showSuccessSnackBar('Ruche supprimée avec succès');
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la suppression: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Valide le formulaire d'ajout
  bool _validateForm() {
    if (_nomController.text.trim().isEmpty) {
      _showErrorSnackBar('Le nom de la ruche est requis');
      return false;
    }

    if (_positionController.text.trim().isEmpty) {
      _showErrorSnackBar('La position de la ruche est requise');
      return false;
    }

    return true;
  }

  /// Vide le formulaire
  void _clearForm() {
    _nomController.clear();
    _positionController.clear();
    _enService = true;
    _dateInstallation = DateTime.now();
  }

  /// Affiche un SnackBar de succès
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Affiche un SnackBar d'erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Affiche un dialog de confirmation
  Future<bool?> _showConfirmationDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  /// Affiche le dialog d'ajout de ruche
  void _showAjouterRucheDialog() {
    _clearForm();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ajouter une ruche'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la ruche',
                        hintText: 'Ex: Ruche A1',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _positionController,
                      decoration: const InputDecoration(
                        labelText: 'Position',
                        hintText: 'Ex: A1, B2, C3...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _enService,
                          onChanged: (value) {
                            setDialogState(() {
                              _enService = value ?? true;
                            });
                          },
                        ),
                        const Text('En service'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Date d\'installation: '),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _dateInstallation,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setDialogState(() {
                                _dateInstallation = date;
                              });
                            }
                          },
                          child: Text(
                            '$_dateInstallation.day/$_dateInstallation.month/$_dateInstallation.year',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: _isAddingRuche ? null : _ajouterRuche,
                  child: _isAddingRuche
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ruches - ${widget.nomRucher}'),
        actions: [
          IconButton(
            onPressed: _showAjouterRucheDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter une ruche',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ruches.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hive_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucune ruche dans ce rucher',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Appuyez sur + pour ajouter votre première ruche',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ruches.length,
                  itemBuilder: (context, index) {
                    final ruche = _ruches[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: ruche['enService'] == true
                              ? Colors.green
                              : Colors.orange,
                          child: Text(
                            ruche['position'] ?? '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          ruche['nom'] ?? 'Sans nom',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Position: ${ruche['position'] ?? 'Non définie'}'),
                            Text(
                              'Statut: ${ruche['enService'] == true ? 'En service' : 'Hors service'}',
                              style: TextStyle(
                                color: ruche['enService'] == true
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (ruche['dateInstallation'] != null)
                              Text(
                                'Installée le: ${_formatDate(ruche['dateInstallation'])}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Supprimer',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            switch (value) {
                              case 'delete':
                                _supprimerRuche(ruche['id'], ruche['nom']);
                                break;
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAjouterRucheDialog,
        tooltip: 'Ajouter une ruche',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Formate une date Firestore pour l'affichage
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Non définie';

    try {
      DateTime date;
      if (timestamp.runtimeType.toString().contains('Timestamp')) {
        date = timestamp.toDate();
      } else if (timestamp is DateTime) {
        date = timestamp;
      } else {
        return 'Format invalide';
      }

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (e) {
      return 'Erreur format';
    }
  }
}
