import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:ruche_connectee/services/firebase_service.dart';
import 'package:ruche_connectee/services/logger_service.dart';

class RucherDetailScreen extends StatefulWidget {
  final String rucherId;

  const RucherDetailScreen({
    Key? key,
    required this.rucherId,
  }) : super(key: key);

  @override
  State<RucherDetailScreen> createState() => _RucherDetailScreenState();
}

class _RucherDetailScreenState extends State<RucherDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _rucherData;

  @override
  void initState() {
    super.initState();
    _loadRucherData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadRucherData() async {
    try {
      setState(() => _isLoading = true);
      
      final docSnapshot = await GetIt.I<FirebaseService>()
          .firestore
          .collection('ruchers')
          .doc(widget.rucherId)
          .get();

            if (!context.mounted) return;      if (docSnapshot.exists) {
        setState(() {
          _rucherData = docSnapshot.data();
          _nameController.text = _rucherData?['nom'] ?? '';
          _locationController.text = _rucherData?['localisation'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rucher non trouvé')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
            LoggerService.error('Erreur lors du chargement du rucher', e);      if (!context.mounted) return;      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
        } finally {      if (context.mounted) {        setState(() => _isLoading = false);      }    }  }  Future<void> _updateRucher() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      await GetIt.I<FirebaseService>()
          .firestore
          .collection('ruchers')
          .doc(widget.rucherId)
          .update({
        'nom': _nameController.text,
        'localisation': _locationController.text,
        'modifie_le': FieldValue.serverTimestamp(),
            });      if (!context.mounted) return;      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rucher mis à jour avec succès')),
      );
      Navigator.pop(context);
    } catch (e) {
            LoggerService.error('Erreur lors de la mise à jour du rucher', e);      if (!context.mounted) return;      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
        } finally {      if (context.mounted) {        setState(() => _isLoading = false);      }    }  }  Future<void> _deleteRucher() async {
    try {
      setState(() => _isLoading = true);

      // Vérifier s'il y a des ruches dans ce rucher
      final ruchesSnapshot = await GetIt.I<FirebaseService>()
          .firestore
          .collection('ruches')
          .where('rucher_id', isEqualTo: widget.rucherId)
                    .get();      if (!context.mounted) return;      if (ruchesSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de supprimer un rucher contenant des ruches'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await GetIt.I<FirebaseService>()
          .firestore
          .collection('ruchers')
          .doc(widget.rucherId)
                    .delete();      if (!context.mounted) return;      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rucher supprimé avec succès')),
      );
      Navigator.pop(context);
    } catch (e) {
            LoggerService.error('Erreur lors de la suppression du rucher', e);      if (!context.mounted) return;      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
        } finally {      if (context.mounted) {        setState(() => _isLoading = false);      }    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du rucher'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmer la suppression'),
                  content: const Text(
                    'Êtes-vous sûr de vouloir supprimer ce rucher ? '
                    'Cette action est irréversible.',
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
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        labelText: 'Localisation',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une localisation';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateRucher,
                      child: const Text('Mettre à jour le rucher'),
                    ),
                    if (_rucherData != null) ...[
                      const SizedBox(height: 32),
                      const Text(
                        'Informations complémentaires',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Créé le: ${_rucherData!['cree_le']?.toDate().toString() ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dernière modification: ${_rucherData!['modifie_le']?.toDate().toString() ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
} 