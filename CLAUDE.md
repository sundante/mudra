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

## Design Rules (non-negotiable)

- **Background**: `#FFFFFF` pure white — `#FAF8F4` cream is banned
- **Colour grammar**:
  - Red `#A83226` (`AppColors.red`) = primary brand signal + all outflows — active nav, CTAs, brand italic text (user name, screen titles like "briefing"), debit row accent bars, negative amounts, expense chips
  - Green `#1E6B44` (`AppColors.green`) = surplus / income / positive balance
  - Amber `#9A5510` (`AppColors.amber`) = promises — future investment or savings commitments not yet executed (SIP, recurring invest)
  - Gold `#8A6520` (`AppColors.gold`) = hero gradient only — retired from UI text, CTAs, labels, and nav; never use on financial data
  - Negative amounts always red regardless of row type
- **Red is the primary brand signal** — use for active nav state, CTAs, and brand italic text; do not overuse on non-brand, non-outflow elements
- **Typography**: Cormorant Garamond = hero/display numbers · IBM Plex Sans = all UI text · IBM Plex Mono = **every** currency amount (no exceptions)
- **Section labels**: IBM Plex Mono, 9.5px, ALL CAPS, `inkDim` (#8C8480) — not gold. Count label on the right (e.g. `3 DEBITS`) uses same style in red
- **Hero gradient card**: dark red (`#1A0404 → #7A1F16`) — max 1 per screen, never stack two
- **No gauges or dials** — hero tile on Home shows numbers only (spendable + days left + projected month-end); no arcs, rings, or progress bars inside tiles
- **Full design reference**: `docs/vibes/mudra_design_system.html`
- **Aspirational direction + component catalogue**: `docs/vibes/DESIGN_DIRECTION.md`

### Component Grammar

Rules agents must follow for every list row, tile, and header:

**Row anatomy** (outgoing, debit, account, holding rows):
- Left accent bar: 3–4px wide, semantic color (red = outflow/debt, amber = investment/SIP, green = income)
- Title: IBM Plex Sans 14px w500, `ink`
- Sublabel: IBM Plex Mono 10px, `inkDim` — format `DAY · DATE`
- Countdown (upcoming rows only): IBM Plex Sans 11px `inkDim` — `IN X DAYS` after the date
- Category chip: small pill 4px radius, tinted bg + matching text (EMI/CC/Bill → redLight/red; SIP/Invest → amberLight/amber; Income → greenLight/green); IBM Plex Mono 9px ALL CAPS
- Amount: IBM Plex Mono 14px w500, right-aligned; color follows row type

**Stat tiles** (all screens, consistent spec):
- Label: IBM Plex Mono 9.5px ALL CAPS `inkDim`
- Amount: IBM Plex Mono ~20px w600, `ink`
- Delta: IBM Plex Sans 11px, semantic color
- Background tint: `greenLight` for liquid/account tiles, `amberLight` for investment tiles, `surfaceAlt` for neutral
- Corner radius 10px, padding 14px; equal height when tiled side-by-side
- No gauges, bars, or progress indicators inside — numbers only

**Hero tile** (Home screen, max 1 per screen):
- Label: `SPENDABLE THIS MONTH` — section label style, `inkDim`
- Hero amount: IBM Plex Mono ~36px w600, green if positive / red if negative
- Sub-row: `N days left · Projected ±₹ X` — IBM Plex Sans 12px `inkDim`; projected amount inline green/red
- White bg, 1px `border` border, 12px radius, 20px horizontal / 18px vertical padding

**Greeting header**:
- Line 1: IBM Plex Sans 16px w400, `inkMid` — `Good morning,`
- Line 2: Cormorant Garamond italic 22px w400, `red` — user name
- Line 3: section label (mono 9.5px ALL CAPS `inkDim`) — date

**Section label + count row**:
- Left: IBM Plex Mono 9.5px ALL CAPS `inkDim` — e.g. `NEXT 7 DAYS`
- Right: same style, `red` — e.g. `3 DEBITS`

## Architecture

Flat feature structure (actual layout — agents must use these paths):

```
lib/
├── main.dart                          # app entry, Isar init, ProviderScope
├── app.dart                           # MudraApp, GoRouter, ScaffoldWithNavBar
├── core/
│   ├── theme/                         # app_colors, app_typography, app_theme
│   ├── constants/                     # spacing
│   └── utils/                        # currency_formatter, date_helpers
├── data/
│   ├── models/                        # Isar @collection models + Safe extensions
│   ├── repositories/                  # CRUD + watchAll() streams
│   └── database.dart                  # openDatabase(), isarProvider
├── providers/                         # all Riverpod providers
├── screens/
│   ├── dashboard/
│   ├── accounts/                      # tab label: Funds
│   ├── debts/                         # tab label: Debts
│   ├── map/                           # compact app/user-flow map
│   ├── net/
│   ├── onboarding/
│   ├── portfolio/                     # tab label: Investments
│   ├── profile/                       # identity, app map, account actions
│   └── spend/
└── widgets/
    ├── common/                        # mudra_button, mudra_input, mudra_card, amount_display, section_label, empty_state
    ├── fuel_gauge_ring.dart
    ├── account_tile.dart
    ├── outgoing_row.dart
    ├── debit_radar_item.dart
    └── platform_card.dart
```

Layer rules (enforce even in flat structure):
- Models in `data/models/` — pure Dart, no Flutter imports in business logic
- Providers in `providers/` — no direct widget/screen imports
- Screens depend on providers/use cases only, never directly on repositories
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
- After completing any phase's code, always prompt the user to hot reload (`r` in the terminal or save in IDE) and verify on both simulators before marking items `[x]`
- Product planning rule: Mudra is month-first. All planning, runway, debit forecasting, and UX framing should default to the current month, not a 7-day or weekly window, unless the user explicitly asks for a shorter horizon.
- Profile rule: Profile is identity/settings-oriented. Do not add income, pay date, outflow, currency, or other finance-editing controls back to Profile unless explicitly requested. App Map belongs in Profile only, not Home quick actions.
- Home gauge rule: Home → This Month should lead with the fuel gauge, without the old gold Month Runway hero. Gauge color is based on projected month-end value: 0 grey, positive green, negative red.

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

## Isar Data Safety (REQUIRED)

Isar v3 bypasses Dart null safety at runtime. Non-nullable `double`/`int`/`String`/`enum`
fields can return null for records written by older schema versions.

Rules (enforced on every new model and every widget):

1. **Every Isar model MUST include a Safe extension** at the bottom of its file:
   ```dart
   extension MySafe on MyModel {
     double get safeAmount   => ((amount as dynamic) as double?) ?? 0.0;
     int    get safeDate     => ((date as dynamic) as int?) ?? 0;
     String get safeName     => ((name as dynamic) as String?) ?? '';
     MyEnum get safeField    => ((field as dynamic) as MyEnum?) ?? MyEnum.fallback;
   }
   ```

2. **Safe extensions must cover all persisted non-nullable fields used by the app**:
   `String`, `double`, `int`, `bool`, and `enum` fields all need safe getters if they are read outside write code.

3. **Providers / repositories**: prefer model safe getters over raw Isar fields whenever reading persisted values.
   Do not assume non-nullable schema fields are safe at runtime.

4. **Widgets**: NEVER read `.amount`, `.balance`, `.debitDate`, or any primitive
   field directly on an Isar object. Always use the safe extension getters.
   Widgets must receive pre-typed `double`/`String` primitives — never raw Isar objects.

5. **Important caveat**: safe getters do not prevent hydration-time crashes from stale local data.
   Generated Isar deserializers can still throw `"Null" is not a subtype ...` before your getter runs if an old row contains null in a non-nullable stored field.
   If that happens, confirm with a local DB reset and then implement an app-level recovery path if needed.

## Conventions to Avoid

- No `GetX` — use Riverpod
- No `setState` in widgets that hold business logic
- No direct `http` calls in `presentation/` — go through repository
- No platform-specific code outside of designated platform files
- No hardcoded colors/sizes — use the theme
- No unused imports or dead code committed
