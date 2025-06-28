import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';
import 'package:ruche_connectee/services/ruche_service.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class RucherDetailScreen extends StatefulWidget {
  final String rucherId;

  const RucherDetailScreen({
    Key? key,
    required this.rucherId,
  }) : super(key: key);

  @override
  State<RucherDetailScreen> createState() => _RucherDetailScreenState();
}

class _RucherDetailScreenState extends State<RucherDetailScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  // Controllers pour l'ajout de ruches
  final _rucheNomController = TextEditingController();
  final _ruchePositionController = TextEditingController();
  bool _rucheEnService = true;
  DateTime _dateInstallation = DateTime.now();

  bool _isLoading = false;
  bool _isAddingRuche = false;
  Map<String, dynamic>? _rucherData;
  List<Map<String, dynamic>> _ruches = [];

  // Services
  late final RucheService _rucheService;
  StreamSubscription<List<Map<String, dynamic>>>? _ruchesSubscription;

  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeServices();
    _loadRucherData();
    _startListeningToRuches();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _rucheNomController.dispose();
    _ruchePositionController.dispose();
    _ruchesSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _initializeServices() {
    final firebaseService = GetIt.I<FirebaseService>();
    _rucheService = RucheService(firebaseService);
  }

  void _startListeningToRuches() {
    _ruchesSubscription =
        _rucheService.ecouterRuchesParRucher(widget.rucherId).listen(
      (ruches) {
        if (mounted) {
          setState(() {
            _ruches = ruches;
          });
        }
      },
      onError: (error) {
        LoggerService.error('Erreur d\'écoute temps réel des ruches', error);
      },
    );
  }

  Future<void> _loadRucherData() async {
    try {
      setState(() => _isLoading = true);

      final docSnapshot = await GetIt.I<FirebaseService>()
          .firestore
          .collection('ruchers')
          .doc(widget.rucherId)
          .get();

      if (!mounted) return;

      if (docSnapshot.exists) {
        setState(() {
          _rucherData = docSnapshot.data();
          _nameController.text = _rucherData?['nom'] ?? '';
          _locationController.text =
              _rucherData?['adresse'] ?? _rucherData?['localisation'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rucher non trouvé')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      LoggerService.error('Erreur lors du chargement du rucher', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateRucher() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      await GetIt.I<FirebaseService>()
          .firestore
          .collection('ruchers')
          .doc(widget.rucherId)
          .update({
        'nom': _nameController.text,
        'adresse': _locationController.text,
        'dateModification': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rucher mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      LoggerService.error('Erreur lors de la mise à jour du rucher', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteRucher() async {
    try {
      setState(() => _isLoading = true);

      // Vérifier s'il y a des ruches dans ce rucher
      if (_ruches.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Impossible de supprimer un rucher contenant des ruches'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await GetIt.I<FirebaseService>()
          .firestore
          .collection('ruchers')
          .doc(widget.rucherId)
          .update({
        'actif': false,
        'dateSuppression': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rucher supprimé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      LoggerService.error('Erreur lors de la suppression du rucher', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Méthodes pour la gestion des ruches
  Future<void> _ajouterRuche() async {
    if (!_validateRucheForm()) return;

    setState(() => _isAddingRuche = true);

    try {
      await _rucheService.ajouterRuche(
        idRucher: widget.rucherId,
        nom: _rucheNomController.text.trim(),
        position: _ruchePositionController.text.trim(),
        enService: _rucheEnService,
        dateInstallation: _dateInstallation,
      );

      _showSuccessSnackBar('Ruche créée avec succès');
      _clearRucheForm();
      if (!mounted) return;
      Navigator.of(context).pop(); // Fermer le dialog
    } catch (e) {
      _showErrorSnackBar('Erreur lors de l\'ajout: $e');
    } finally {
      setState(() => _isAddingRuche = false);
    }
  }

  Future<void> _supprimerRuche(String rucheId, String nomRuche) async {
    final bool? confirmed = await _showConfirmationDialog(
      'Supprimer la ruche',
      'Êtes-vous sûr de vouloir supprimer la ruche "$nomRuche" ?',
    );

    if (confirmed != true) return;

    try {
      await _rucheService.supprimerRuche(rucheId);
      _showSuccessSnackBar('Ruche supprimée avec succès');
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la suppression: $e');
    }
  }

  bool _validateRucheForm() {
    if (_rucheNomController.text.trim().isEmpty) {
      _showErrorSnackBar('Le nom de la ruche est requis');
      return false;
    }

    if (_ruchePositionController.text.trim().isEmpty) {
      _showErrorSnackBar('La position de la ruche est requise');
      return false;
    }

    return true;
  }

  void _clearRucheForm() {
    _rucheNomController.clear();
    _ruchePositionController.clear();
    _rucheEnService = true;
    _dateInstallation = DateTime.now();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
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

  void _showAjouterRucheDialog() {
    _clearRucheForm();

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
                      controller: _rucheNomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la ruche',
                        hintText: 'Ex: Ruche A1',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ruchePositionController,
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
                          value: _rucheEnService,
                          onChanged: (value) {
                            setDialogState(() {
                              _rucheEnService = value ?? true;
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
                            '${_dateInstallation.day.toString().padLeft(2, '0')}/${_dateInstallation.month.toString().padLeft(2, '0')}/${_dateInstallation.year}',
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

  Widget _buildRucherInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du rucher',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Adresse/Localisation',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une localisation';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _updateRucher,
              icon: const Icon(Icons.save),
              label: const Text('Mettre à jour le rucher'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            if (_rucherData != null) ...[
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations du rucher',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.hive, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            'Nombre de ruches: ${_ruches.length}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Créé le: ${_formatDate(_rucherData!['dateCreation'])}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      if (_rucherData!['dateModification'] != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.edit, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Modifié le: ${_formatDate(_rucherData!['dateModification'])}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRuchesTab() {
    return Column(
      children: [
        // Header avec bouton d'ajout
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${_ruches.length} ruche(s) dans ce rucher',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAjouterRucheDialog,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        // Liste des ruches
        Expanded(
          child: _ruches.isEmpty
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
                        'Appuyez sur "Ajouter" pour créer votre première ruche',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _ruches.length,
                  itemBuilder: (context, index) {
                    final ruche = _ruches[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 2,
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
                            Row(
                              children: [
                                Icon(
                                  ruche['enService'] == true
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  size: 16,
                                  color: ruche['enService'] == true
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ruche['enService'] == true
                                      ? 'En service'
                                      : 'Hors service',
                                  style: TextStyle(
                                    color: ruche['enService'] == true
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (ruche['dateInstallation'] != null)
                              Text(
                                'Installée le: ${_formatDate(ruche['dateInstallation'])}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'details',
                              child: Row(
                                children: [
                                  Icon(Icons.info),
                                  SizedBox(width: 8),
                                  Text('Détails'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Modifier'),
                                ],
                              ),
                            ),
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
                              case 'details':
                                // Naviguer vers les détails de la ruche
                                context.go(
                                    '/ruches/${ruche['id']}?nom=${Uri.encodeComponent(ruche['nom'] ?? 'Ruche')}');
                                break;
                              case 'edit':
                                // Fonctionnalité de modification à implémenter
                                _showErrorSnackBar(
                                    'Modification à implémenter');
                                break;
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_rucherData?['nom'] ?? 'Détails du rucher'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer le rucher',
                        style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmer la suppression'),
                    content: const Text(
                      'Êtes-vous sûr de vouloir supprimer ce rucher ?\n\n'
                      'Vous devez d\'abord supprimer toutes les ruches qu\'il contient.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteRucher();
                        },
                        child: const Text(
                          'Supprimer',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Informations'),
            Tab(icon: Icon(Icons.hive), text: 'Ruches'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRucherInfoTab(),
                _buildRuchesTab(),
              ],
            ),
    );
  }
}
