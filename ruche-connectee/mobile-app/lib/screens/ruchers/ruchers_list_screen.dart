import 'package:flutter/material.dart';

class RuchersListScreen extends StatelessWidget {
  const RuchersListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ruchers'),
      ),
      body: const Center(
        child: Text('Liste des ruchers à implémenter'),
      ),
    );
  }
} 