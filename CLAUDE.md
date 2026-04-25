# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

**Wordarc** is a Wordscapes-style Flutter game for iOS and Android. Players drag across a circular letter wheel to spell hidden words that fill a crossword-style grid. Features: themed level packs, endless/daily modes, coins, hints, bonus words, SFX + music.

The full architecture is specified in `IMPLEMENTATION-PLAN.md`. That document is the authoritative design reference — read it before making structural decisions.

## Commands

Once `pubspec.yaml` exists:

```bash
# Install dependencies
flutter pub get

# Run code generation (freezed, json_serializable, hive_generator, riverpod_generator)
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs

# Analyze
flutter analyze

# Test
flutter test
flutter test test/some_test.dart          # single test file
flutter test --name "test name pattern"   # single test by name

# Integration tests
flutter test integration_test/play_first_level_test.dart

# Offline level generation CLI
dart run tool/build_levels.dart --pack forest --seeds tool/seeds/forest.txt --out assets/levels/forest --seed 42
```

## Architecture

### State management: Riverpod

All state flows through Riverpod providers. Key distinction: use `AsyncNotifier` for anything involving I/O (dictionary load, level load, daily puzzle, endless generation); use plain `Notifier` for in-memory state (game state, wheel state, coins, hints).

The provider dependency chain at boot: `hiveProvider` (opens Hive boxes) + `dictionaryProvider` (loads ENABLE dictionary in a background isolate) → Splash screen blocks on both before routing to `/home`.

See the full provider table in `IMPLEMENTATION-PLAN.md` § "Riverpod state graph".

### Domain layer (`lib/domain/`)

- **Models** (`freezed` + `json_serializable`): `Level`, `Pack`, `WordPlacement`, `GridCell`, `GameState`, `Progress`
- **Generator** (`LevelGenerator`, `WordPicker`, `GridScorer`): shared between the offline CLI (`tool/build_levels.dart`) and runtime endless/daily mode via `Isolate.run`. Do not split this logic.
- **Rules** (`WordValidator`, `CoinRules`, `HintRules`): pure functions, no I/O

### Data layer (`lib/data/`)

- **Dictionary**: ENABLE wordlist bundled as `assets/dictionary/enable.txt.gz`, loaded once in a background isolate into a `Set<String>` for O(1) lookup and a `Map<String,List<String>>` keyed by sorted letters for sub-anagram enumeration.
- **Levels**: `assets/levels/manifest.json` lists packs; each pack has `pack.json` + numbered level JSON files. Cells are derived from `placements` at load time (grid is sparse — absent cells are empty).
- **Persistence**: Hive with five boxes: `meta` (coins, firstLaunchAt), `progress` (per-pack `PackProgress`), `daily`, `settings`, `endless`. All Hive adapters live in `lib/data/persistence/adapters/`.
- **Audio**: `just_audio` for looping music with crossfade/ducking; `soundpool` for low-latency SFX. Seven pitch-shifted wheel tones (`tone_0..tone_6.ogg`) pre-loaded at boot. iOS audio session = `ambient` so user music is not interrupted.

### Feature layer (`lib/features/`)

Each feature folder is self-contained with its own screen widget(s). The `game/` feature is the most complex:

- `widgets/letter_wheel.dart` + `wheel_painter.dart` — the gesture centerpiece. Uses `Listener` (not GestureDetector) to claim the pointer immediately with no deadzone. Backtrack-deselect fires when the pointer re-enters the second-to-last letter's hit area.
- `widgets/crossword_grid.dart` + `grid_tile.dart` — `CustomMultiChildLayout` with `LayoutId('row-col')` per cell; 200 ms flip animation on reveal.
- `controllers/game_controller.dart` — receives `submitWord`, validates, updates `gameStateProvider`, triggers audio/haptics.

### Routing (`lib/routing/app_router.dart`)

`go_router` routes: `/` → `/home` → `/packs` → `/packs/:packId` → `/play/:levelId` → `/result/:levelId`; plus `/daily`, `/endless`, `/settings`.

### Adding a new pack

Add level JSONs + a manifest entry + a `PackTheme` row + optional music asset. No code changes required elsewhere.

### Codegen

Four generators run together via `build_runner`: `freezed`, `json_serializable`, `hive_generator`, `riverpod_generator`. Always run `--delete-conflicting-outputs` to avoid stale `.g.dart` / `.freezed.dart` files.

### Lints

`very_good_analysis` (fall back to `flutter_lints` if too strict). `flutter analyze` must be clean before committing.

## Key files

| File | Why it matters |
|---|---|
| `IMPLEMENTATION-PLAN.md` | Full architectural spec — read first |
| `lib/features/game/widgets/letter_wheel.dart` | Core gesture input |
| `lib/domain/generator/level_generator.dart` | Shared offline+runtime level gen |
| `lib/data/dictionary/dictionary.dart` | In-memory word lookup + sub-anagram API |
| `lib/features/game/controllers/game_controller.dart` | Central game logic |
| `lib/data/persistence/hive_boxes.dart` | All Hive box definitions |
| `lib/routing/app_router.dart` | Full route tree |
| `tool/build_levels.dart` | Offline CLI for baking level assets |

## Level JSON format

```json
{
  "id": "forest-001", "packId": "forest", "index": 0,
  "title": "Sunrise 1", "letters": "AEPPL",
  "rows": 5, "cols": 5,
  "placements": [
    { "word": "APPLE", "row": 1, "col": 0, "dir": "across" },
    { "word": "PEAL",  "row": 0, "col": 2, "dir": "down" }
  ],
  "rewardCoins": 25
}
```

## Dictionary licensing

Use **ENABLE** (public domain). Do not use SOWPODS or TWL. Profanity filtering is applied offline at dictionary build time, not at runtime.

## Daily puzzle determinism

Daily levels use `Random(seed)` where the seed is derived from the UTC `YYYY-MM-DD` date (SHA-1 → int). Always use UTC everywhere to avoid timezone drift bugs.
