import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wordarc/data/levels/level_provider.dart';
import 'package:wordarc/domain/models/level.dart';
import 'package:wordarc/features/game/widgets/candidate_word_banner.dart';
import 'package:wordarc/features/game/widgets/crossword_grid.dart';
import 'package:wordarc/features/game/widgets/letter_wheel.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({required this.levelId, super.key});

  final String levelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelAsync = ref.watch(levelLoaderProvider(levelId));
    return levelAsync.when(
      data: (level) => _buildGame(context, level),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildGame(BuildContext context, Level level) {
    return Scaffold(
      appBar: AppBar(title: Text(level.title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: CrosswordGrid(
                    cells: level.cells,
                    rows: level.rows,
                    cols: level.cols,
                  ),
                ),
              ),
            ),
            const CandidateWordBanner(),
            Expanded(
              flex: 2,
              child: Center(
                child: LetterWheel(letters: level.letters),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
