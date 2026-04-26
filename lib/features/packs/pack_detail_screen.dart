import 'package:flutter/material.dart';

class PackDetailScreen extends StatelessWidget {
  const PackDetailScreen({required this.packId, super.key});

  final String packId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pack: $packId')),
      body: const Center(child: Text('Pack detail — coming in M7')),
    );
  }
}
