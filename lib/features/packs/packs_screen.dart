import 'package:flutter/material.dart';

class PacksScreen extends StatelessWidget {
  const PacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Packs')),
      body: const Center(child: Text('Packs — coming in M7')),
    );
  }
}
