import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/dictionary/dictionary_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dictionaryAsync = ref.watch(dictionaryProvider);

    dictionaryAsync.whenData((_) {
      // Navigate to home once the dictionary is ready.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/home');
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1A3A2A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Wordarc',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            dictionaryAsync.when(
              loading: () => const Column(
                children: [
                  CircularProgressIndicator(color: Colors.white70),
                  SizedBox(height: 16),
                  Text(
                    'Loading…',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
              data: (dictionary) => Text(
                '${dictionary.wordCount} words loaded',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              error: (e, _) => Text(
                'Error loading dictionary: $e',
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
