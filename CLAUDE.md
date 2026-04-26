# Agent Contribution Guide

This document describes conventions for AI agents contributing to this repository.

## Git identity

**Commit as the user, not as the agent.** Commits should reflect the identity of the person on whose behalf the work is being done — check the existing git config or ask them for their name and email if not already set.

```bash
git config user.name   # verify current identity
git config user.email
```

If these are set to an AI agent's identity (e.g. "Claude", "GitHub Copilot", a `noreply@anthropic.com` address), update them to match the actual user before committing. Do not leave AI-generated identities in commits.

## Commit messages

- Write clear, descriptive commit messages that explain *what* and *why*
- Follow the style used in this repo: `type: short description` (e.g. `feat:`, `fix:`, `docs:`, `chore:`, `test:`)
- **Do not include links of any kind to claude.ai, cursor.sh, copilot, or any other AI coding tool in commit messages or PR descriptions**
- Do not include links to chat sessions, conversation logs, or session URLs of any kind
- Do not mention the AI agent or tool that produced the change in the commit message or PR description

## Development workflow

### Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

The gzipped ENABLE dictionary is already checked in at `assets/dictionary/enable.txt.gz` and does not need to be regenerated.

### Running locally

```bash
flutter run                  # launch on connected device / simulator
flutter run --release        # release mode
```

### Code generation

Riverpod, freezed, and Hive use `build_runner` for code generation. Re-run whenever you add or modify annotated classes or providers:

```bash
dart run build_runner build --delete-conflicting-outputs
# or watch mode during development:
dart run build_runner watch --delete-conflicting-outputs
```

Generated files (`*.g.dart`, `*.freezed.dart`) are excluded by `.gitignore` and must not be committed. Always regenerate them locally before running the app or tests.

## Code conventions

- **Language**: Dart — do not introduce non-Dart build steps or scripts without a strong reason.
- **State management**: Riverpod (`riverpod_annotation` + codegen). Do not add a second state management library.
- **Navigation**: `go_router`. Do not use `Navigator.push` directly.
- **Persistence**: Hive typed boxes. Do not add a second persistence layer.
- **Models**: `freezed` + `json_serializable`. All domain models must be immutable and serialisable.
- **Lints**: `very_good_analysis`. All new code must pass `flutter analyze` with no warnings.
- **No comments explaining *what* code does** — only add comments when the *why* is non-obvious.

## What to avoid

- Do not commit without first running `flutter analyze` and `flutter test`.
- Do not break any of the four game entry points: bundled levels, `/endless`, `/daily`, or the result screen.
- Do not add external pub packages without a strong reason; keep the dependency footprint small.
- Do not add or modify `assets/dictionary/enable.txt.gz` — the word list is intentionally fixed and profanity-filtered.
- Do not commit build artifacts (`build/`, `.dart_tool/` beyond `package_config.json`).
- Do not add TypeScript, JavaScript, or other non-Dart tooling.

## Testing changes

Before committing, run the full test suite:

```bash
flutter analyze              # static analysis — must be clean
flutter test                 # unit + widget tests
dart run build_runner build --delete-conflicting-outputs  # confirm codegen succeeds
```

### New features and bug fixes must include tests

- **Domain / data layer changes** (dictionary, generator, validator, coin rules): add or update unit tests in `test/`.
- **Widget changes** (letter wheel, crossword grid, hint buttons): add or update widget tests alongside the affected feature directory.
- **Provider changes**: test state transitions with `ProviderContainer` in isolation.
- Tests should cover the new behaviour directly and any edge cases that are easy to get wrong.

### Additional manual checks

1. Run `flutter run` and manually verify the affected screens still work correctly.
2. If you touched `LevelGenerator`, confirm generated levels pass the quality gate (≥4 words, bbox ≤10×10, no isolated word).
3. If you touched persistence (Hive boxes), confirm coins and progress survive a hot restart.
