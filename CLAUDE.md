# Mudra — MasterMudra Flutter App

## Project Overview

**Mudra** is a personal finance awareness mobile app built with Flutter. It helps users understand their financial health through intuitive tracking, insights, and nudges. Primary targets are iOS and Android; Web is secondary.

## Tech Stack

- **Flutter** 3+ / Dart SDK ^3.12.0
- **State management**: Riverpod 2.0 (default for all new features)
- **Navigation**: go_router
- **Code generation**: freezed, json_serializable, riverpod_generator
- **Testing**: flutter_test, integration_test, golden_toolkit
- **Linting**: flutter_lints + project `analysis_options.yaml`

## Architecture

Clean Architecture with feature-based folder structure:

```
lib/
├── main.dart
├── core/                        # shared utilities, constants, theme, router
│   ├── theme/
│   ├── router/
│   └── utils/
└── features/
    └── <feature_name>/
        ├── data/                # repositories (impl), data sources, models
        ├── domain/              # entities, repository interfaces, use cases
        └── presentation/        # pages, widgets, controllers/notifiers
```

Rules:
- `domain/` has zero Flutter imports — pure Dart only
- `data/` depends on `domain/`, never on `presentation/`
- `presentation/` depends on `domain/` use cases only, never directly on `data/`
- Dependency injection via Riverpod providers; no service locator

## State Management (Riverpod 2.0)

- Use `@riverpod` annotation with code generation (`riverpod_generator`)
- Prefer `AsyncNotifier` for async state, `Notifier` for sync state
- Keep providers in `presentation/controllers/` or `presentation/providers/`
- Never put business logic in widgets — delegate to notifiers/use cases

## Style & Conventions

- Follow [Effective Dart](https://dart.dev/effective-dart) strictly
- `analysis_options.yaml` is enforced — zero lint warnings allowed
- No comments unless the WHY is non-obvious (no what/how comments)
- No magic strings — use constants or enums
- No `var` when the type is non-obvious
- Use `const` constructors everywhere possible
- No `setState` in widgets that own business logic — use Riverpod

## Testing Requirements

- Widget tests required for all custom widgets
- Target >80% overall test coverage
- `flutter test` must pass before any feature is considered done
- Golden tests for design-critical widgets
- Integration tests for critical user journeys

## Commands

```bash
flutter run                          # run on connected device/emulator
flutter test                         # run all tests
flutter analyze                      # static analysis (must be clean)
flutter build apk --release          # Android release build
flutter build ipa                    # iOS release build
flutter pub get                      # install dependencies
dart run build_runner build          # run code generation
dart run build_runner watch          # watch mode for code gen
dart format .                        # format all Dart files
```

## Build Tracking

**At the start of every session:**
1. Read `docs/STATUS.md` — find the current phase and the first unchecked item
2. Read `docs/PLAN.md` — understand design rules and constraints before touching code
3. Read the relevant phase section in `vibes/5-26-mudra_flutter_prompt.md` for exact implementation detail

**After every phase completes (all items checked, both simulators green):**
1. Mark all completed items `[x]` in `docs/STATUS.md`
2. Update the Progress Summary table counts
3. Add a session log entry (date · what was done · stopped at)
4. Advance "Current Phase" in the STATUS.md header
5. Commit: `git commit -m "Phase X complete: <name>"`

**Rules:**
- Never mark a phase complete unless `flutter analyze` is clean and the app runs on both simulators
- One phase at a time — do not start Phase N+1 until Phase N is fully checked off
- If a task is blocked, mark it `[!]` and note the blocker in the session log

Detailed phase-by-phase code prompts: `vibes/5-26-mudra_flutter_prompt.md`

## Agents

Claude Code agents live in `.claude/agents/`. Invoke them for specialized work:

| Agent | When to use |
|---|---|
| `flutter-expert` | Architecture decisions, platform-specific code, complex widget trees |
| `dart-specialist` | Package selection, code generation setup, Dart language questions |
| `ui-designer` | Theme, design tokens, custom widgets, animations |
| `test-writer` | Writing widget tests, golden tests, integration tests |
| `feature-builder` | Scaffolding a complete new feature end-to-end |

## Conventions to Avoid

- No `GetX` — use Riverpod
- No `setState` in widgets that hold business logic
- No direct `http` calls in `presentation/` — go through repository
- No platform-specific code outside of designated platform files
- No hardcoded colors/sizes — use the theme
- No unused imports or dead code committed
