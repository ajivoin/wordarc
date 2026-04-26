import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wordarc/data/levels/level_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packsAsync = ref.watch(packsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF1A3A2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3A2A),
        title: const Text(
          'Wordarc',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: packsAsync.when(
        data: (packs) => ListView.builder(
          itemCount: packs.length,
          itemBuilder: (context, index) {
            final pack = packs[index];
            return ListTile(
              title: Text(
                pack.title,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () => context.go('/play/${pack.levelIds.first}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
