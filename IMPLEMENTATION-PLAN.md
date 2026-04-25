# Wordarc — Wordscapes-style Flutter Game

## Context
The repo at `/home/user/wordarc` is a greenfield project (only README/LICENSE/.gitignore). The goal is to build a Flutter game that plays identically to **Wordscapes**: a circular letter wheel below a sparse crossword-style grid; the player drags across letters to spell hidden words and earns coins for valid bonus words. This plan defines the full v1 architecture so implementation can proceed top-to-bottom.

**User-confirmed scope**
- Platforms: **iOS + Android only**
- Levels: **Hybrid** — bundled curated themed packs + runtime endless/procedural mode
- Features: **coins + hints + bonus words**, **SFX + light music**, **themed level packs**, **daily puzzle**
- State management: **Riverpod**

## Technical decisions (recommended)
- **Routing:** `go_router` — declarative, deep-link friendly, pairs cleanly with Riverpod.
- **Persistence:** **Hive** (typed boxes via `hive_generator`). Better fit than `shared_preferences` for nested progress; lighter than `drift` for our non-relational shape.
- **Audio:** `just_audio` for music (looping + ducking) + `soundpool` for SFX (low-latency wheel tones). Pre-render 7 pitch-shifted tone variants offline (sox/ffmpeg) on a pentatonic scale so any selection order is consonant.
- **Models:** `freezed` + `json_serializable` for `Level`, `Pack`, `WordPlacement`, `GameState`.
- **Codegen:** `riverpod_generator`, `freezed`, `json_serializable`, `hive_generator` via one `build_runner`.
- **Dictionary:** **ENABLE** (public domain, ~165k words after filtering for `[a-z]{3,15}` + small profanity blacklist). Bundled as gzip (~450 KB). In-memory: `Set<String>` for O(1) `contains`, plus `Map<String,List<String>>` keyed by sorted-letters for sub-anagram enumeration. Loaded once in a background isolate at boot.
- **Generator:** One `LevelGenerator` class used in two contexts — offline CLI (`tool/build_levels.dart`) writes JSON into `assets/levels/<pack>/`; runtime (endless/daily) runs the same code inside `Isolate.run`. Daily uses `Random(seed)` keyed on UTC `YYYY-MM-DD` (SHA-1 → int) over a curated 365-word base-word pool.
- **Lints:** `very_good_analysis` (or `flutter_lints` if too strict).

## Directory layout
```
assets/
  dictionary/enable.txt.gz
  levels/manifest.json + <pack>/{pack.json, 001.json, ...}
  audio/{sfx, music}/...
  images/, fonts/
lib/
  main.dart, app.dart, bootstrap.dart
  core/        # Result, logger, extensions
  routing/     # app_router.dart
  theme/       # app_theme, pack_theme, tokens
  data/
    dictionary/ (dictionary, dictionary_loader, dictionary_provider)
    levels/     (level_repository, pack_manifest, level_asset_loader)
    persistence/(hive_boxes, progress_dao, settings_dao, adapters/)
    audio/      (audio_service, audio_provider)
  domain/
    models/    (level, pack, word_placement, grid_cell, game_state, progress)
    generator/ (level_generator, word_picker, grid_scorer)
    rules/     (word_validator, coin_rules, hint_rules)
  features/
    splash/, home/, packs/, game/, daily/, endless/, result/, settings/
    game/widgets/(crossword_grid, grid_tile, letter_wheel, wheel_painter,
                  candidate_word_banner, hint_buttons, bonus_words_drawer)
    game/controllers/(game_controller, wheel_controller, hint_controller)
test/, integration_test/, tool/
```

## Data model

**Level JSON** (`assets/levels/forest/001.json`):
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
Cells are derived from `placements` at load (sparse grid — empty cells simply absent). Pack manifest declares packs, themeKey, music key, background, unlock chain. Sub-pack file `pack.json` lists ordered level IDs and their asset paths.

**Hive progress** (typeId 1):
```dart
class PackProgress {
  String packId;
  Set<String> completedLevelIds;
  Map<String, List<String>> bonusWordsByLevel;
  int starsTotal;
}
```
Boxes: `meta` (coins, firstLaunchAt), `progress` (per pack), `daily` (`YYYY-MM-DD` → DailyEntry), `settings`, `endless` (last 20).

## Generator algorithm (offline + runtime)
1. Sub-anagrams of base word from `Dictionary.subAnagramsOf` (length 3..|base|), cap ~12, weight by frequency.
2. Place longest word horizontally as anchor.
3. For each remaining word (longest first, RNG tie-break): enumerate legal perpendicular intersections, reject overlaps/parallel-adjacency/oversized bbox; score by intersections, symmetry, density, bbox shrink; place at best score.
4. Quality gate: ≥4 words for 6-letter base (≥5 for 7-letter), bbox ≤10×10, no isolated word.
5. Retry up to 50 times with shuffled tie-breaks; keep best acceptable; if none, drop lowest-frequency word and retry.
6. Normalize to (0,0); emit JSON.

CLI: `dart run tool/build_levels.dart --pack forest --seeds tool/seeds/forest.txt --out assets/levels/forest --seed 42`.

## Letter wheel input (the centerpiece)
Widget: `LetterWheel` (Stateful) → `Listener` (claims pointer immediately; no pan deadzone) → `CustomPaint(painter: WheelPainter)`.

Geometry: `radius = shortestSide * 0.36`, `letterRadius = shortestSide * 0.10`, letters evenly spaced starting at `-π/2`.

State (`wheelStateProvider`): `selectedIndices: List<int>`, `pointerLocal: Offset?`, `status`.

Pointer handling:
- **Down inside a letter:** push index, set status, play `tone[0]`, light haptic.
- **Move:** update pointer; if nearest letter is within `letterRadius * 0.85` and not selected → append (play next pitched tone). **Backtrack-deselect:** if pointer is within threshold of the second-to-last selected letter → pop the last (play descending tone).
- **Up:** call `gameController.submitWord(candidate)`; success → reveal animation; bonus → coin tick; invalid → shake; clear selection.

`WheelPainter` draws disk → connection segments between selected letters → trailing line to `pointerLocal` → letter glyphs (highlighted when selected) with rounded `StrokeCap` and a subtle `MaskFilter.blur` glow.

## Crossword grid
`CustomMultiChildLayout` with `LayoutId('r-c')` per cell; `cellSize = min(maxW/cols, maxH/rows)`. `GridTile` is Stateful with a 200ms `AnimationController`: hidden→revealed plays a Y-axis flip via `Matrix4.rotationY`; bonus reveal uses a brief gold-tint fade overlay (no flip). Empty cells are simply absent widgets.

## Riverpod state graph
| Provider | Type | Notes |
|---|---|---|
| `dictionaryProvider` | `AsyncNotifier` | Loads ENABLE in isolate |
| `hiveProvider` | `FutureProvider<void>` | Opens boxes at boot |
| `progressRepositoryProvider` | `Provider` | Hive ops |
| `coinsProvider` | `Notifier<int>` | Persisted balance |
| `packsProvider` | `FutureProvider<List<Pack>>` | Reads manifest.json |
| `levelLoaderProvider.family` | `FutureProvider.family<Level,String>` | Per-level JSON |
| `currentLevelProvider` | `Notifier<Level?>` | Active level |
| `gameStateProvider` | `Notifier<GameState>` | Discovered, bonus, revealed cells |
| `wheelStateProvider` | `Notifier<WheelState>` | Pure UI selection state |
| `hintControllerProvider` | `Notifier<HintState>` | Spends coins → reveals |
| `endlessControllerProvider` | `AsyncNotifier<Level>` | Generates in isolate |
| `dailyPuzzleProvider` | `AsyncNotifier<DailyState>` | Seeded today's puzzle |
| `audioProvider`, `settingsProvider`, `themeProvider` | various | |

`AsyncNotifier` for I/O; plain `Notifier` for in-memory.

## Routing (go_router)
`/` Splash → `/home` → `/packs` → `/packs/:packId` → `/play/:levelId` → `/result/:levelId`; plus `/daily`, `/endless`, `/settings`. Splash blocks on `dictionaryProvider` + `hiveProvider`.

## Audio service
`AudioService` exposes `playWheelTone(idx)`, `playSuccess/Bonus/Reject/Coin/Hint`, `setMusic(key)` (crossfade), `setSfxEnabled/setMusicEnabled`. Pre-load `tone_0..tone_6.ogg` into Soundpool at boot. Ducking: drop music to 0.35 over 50 ms, hold 100 ms, ramp back over 200 ms. Configure iOS audio session as `ambient` so user music isn't interrupted.

## Theming / packs
`PackTheme { primary, accent, tileBack, tileFront, backgroundAsset?, musicKey }`. `themeProvider` derives the active theme from `currentLevelProvider`. Adding a pack = add level JSONs + manifest entry + `PackTheme` row + optional music asset; **no code changes elsewhere**. Placeholder backgrounds = runtime gradients to keep APK small.

## Critical files (where the architectural weight lives)
- `lib/features/game/widgets/letter_wheel.dart` + `wheel_painter.dart`
- `lib/domain/generator/level_generator.dart`
- `lib/data/dictionary/dictionary.dart` + `dictionary_loader.dart`
- `lib/features/game/controllers/game_controller.dart`
- `lib/data/persistence/hive_boxes.dart`
- `lib/routing/app_router.dart`
- `tool/build_levels.dart`

## Milestones (each independently demoable)
1. **M1 (1d):** Bootstrap + dictionary loaded in isolate; splash shows word count.
2. **M2 (2d):** Static level renders from a hand-written JSON.
3. **M3 (2d):** Letter wheel input — drag produces candidate word, console-logs on release.
4. **M4 (2d):** Word validation + reveal animation + bonus drawer + reject shake.
5. **M5 (3d):** `LevelGenerator` + CLI bakes 20 forest levels; `/endless` generates in isolate.
6. **M6 (2d):** Hive persistence; coins survive restart; reveal-letter and reveal-word hints work.
7. **M7 (2d):** Pack manifest drives PackSelect/LevelSelect; sequential unlock; per-pack themes.
8. **M8 (1.5d):** Audio — pitched wheel tones, SFX, looping music with ducking, settings toggle.
9. **M9 (1d):** Daily puzzle deterministic by UTC date; daily history persists.
10. **M10 (2.5d):** Tests pass; haptics; first-run tutorial; loading skeletons; app icon.

Total ~19 dev-days to shippable v1.

## Risks
- **Generator quality** → quality gate + curated seed lists + offline pre-bake review.
- **Dictionary licensing** → ENABLE (public domain); avoid SOWPODS/TWL.
- **Gesture precision on small phones** → 0.85× hit threshold, cap 7 unique letters, min wheel diameter.
- **Audio latency on Android** → Soundpool not audioplayers; pre-load at boot.
- **Isolate cold-start jank** → keep an isolate alive for endless via `Isolate.spawn` + ports; mask cold start with shuffle animation.
- **Profanity in bonus words** → blacklist applied at dictionary build, not runtime.
- **Daily timezone drift** → UTC date everywhere; documented at the seeding site.
- **iOS audio session** → `AVAudioSessionCategory.ambient` so user music continues.
- **Future monetization** → all coin grants/spends go through `coinsProvider` so ads/IAP plug in cleanly later.

## Verification
1. `flutter pub get && dart run build_runner build --delete-conflicting-outputs` succeeds.
2. `flutter analyze` clean; `flutter test` green (dictionary, generator golden, validator, hint reducers, wheel-gesture widget test, grid-reveal widget test).
3. `dart run tool/build_levels.dart --pack forest ...` writes valid JSON; loaded levels round-trip through `Level.fromJson`/`toJson`.
4. `flutter test integration_test/play_first_level_test.dart` completes a full bundled level end-to-end via simulated gestures and lands on the Result screen.
5. Manual on iOS Simulator + a real Android device: dictionary loads <1 s; wheel drag is smooth (60 fps); reveal animation plays; coins persist across cold start; `/daily` returns the same level on a second open the same UTC day; `/endless` produces a new level each time without UI jank; pack 2 is locked until pack 1 is complete; SFX latency feels instant; background music ducks on word success.
