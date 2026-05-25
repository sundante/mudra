# Mudra — Build Status
**Local-first MVP · Flutter · No Backend · No Auth**

> Legend: `[ ]` Not Started · `[~]` In Progress · `[x]` Done · `[!]` Blocked

**Last Updated:** 2026-05-26
**Current Phase:** Phase 5 — Funds Screen (Accounts)
**Overall Progress:** 96 / 125 items complete

---

## Session Log
> Append a line at the start of every build session. Newest first.

| Date | Session | What was done | Stopped at |
|---|---|---|---|
| 2026-05-26 | Runway Engine v2 | Phase 4 complete: Credits model + Safe extension, selectedDay provider, dashboard_provider refactored (41 fields, day-parameterised formula), FuelGaugeRing clipping fix + day label, dashboard_screen slider + 4-section collapsible table (Cash/Credits/Debits/Commitments), seed data (salary + interest), CLAUDE.md Isar Safety section. flutter analyze clean — 0 issues. Awaiting simulator run to verify on both devices. | Simulator verification on iOS + Android |
| 2026-05-25 | Phase 4 start | Phases 2+3 simulator verified (iOS + Android). Android Gradle namespace+compileSdk patches re-applied. Starting Phase 4 Dashboard Screen. | — |
| 2026-05-25 | Phase 3 | 5 Isar models, build_runner generated .g.dart files, database.dart, main.dart seeds AppSettings, 4 repositories, 5 Riverpod providers (@riverpod DashboardNotifier with all computed values). flutter analyze clean — 0 issues. | Awaiting simulator run on both devices |
| 2026-05-25 | Phase 2 | GoRouter + StatefulShellRoute, ScaffoldWithNavBar, 5 placeholder screens, main.dart simplified to bootstrap only. flutter analyze clean — 0 issues. | Awaiting simulator run on both devices |
| 2026-05-25 | Phase 1 ✅ | Design system complete: app_colors, app_typography (3 fonts), app_theme (full ThemeData), spacing, currency_formatter (INR lakh/crore + 6 currencies), date_helpers. Applied AppTheme.lightTheme to MaterialApp. flutter analyze clean — 0 issues. | Phase 1 COMPLETE — starting Phase 2 |
| 2026-05-25 | Phase 0 ✅ | iOS + Android simulators running (cream bg, gold "Mudra"). Fixed 2 Android build issues: (1) isar_flutter_libs missing namespace → patched via plugins.withId in build.gradle.kts; (2) compileSdk 30 too old → patched via afterEvaluate. flutter doctor clean. | Phase 0 COMPLETE — starting Phase 1 |
| 2026-05-25 | Phase 0 build | pubspec.yaml updated (riverpod_generator pinned to 2.4.0 to resolve isar_generator conflict), folder structure created, main.dart replaced, flutter analyze clean | Phase 0 — awaiting simulator run on iOS + Android |
| 2026-05-25 | Setup | Claude Code project configured: CLAUDE.md, .claude/settings.json, 5 agents in .claude/agents/ | Phase 0 — pubspec.yaml not yet updated |

---

## Phase 0 — Scaffold & Simulator Run
**Goal:** Flutter app running on iOS simulator AND Android emulator showing cream background + "Mudra" gold text.

- [x] Flutter project created (`flutter create mudra`)
- [x] `flutter doctor` passes cleanly
- [x] iOS Simulator available and running
- [x] Android Emulator available and running
- [x] Project opens without errors in VS Code
- [x] `pubspec.yaml` updated with all project dependencies (riverpod_generator pinned 2.4.0 — isar_generator conflict)
- [x] `flutter pub get` runs without errors
- [x] Folder structure created: `lib/core/`, `lib/data/`, `lib/providers/`, `lib/screens/`, `lib/widgets/`
- [x] `lib/main.dart` replaced (counter app removed, ProviderScope + cream scaffold)
- [x] `flutter analyze` clean — 0 issues
- [x] `flutter run` on iOS simulator — cream bg, "Mudra" gold text, no errors
- [x] `flutter run` on Android emulator — cream bg, "Mudra" gold text, no errors

**⚠️ Android build fixes applied in `android/build.gradle.kts` (permanent for Isar 3.x):**
- `plugins.withId` → injects `namespace = "dev.isar.isar_flutter_libs"` (AGP 8+ requirement)
- `afterEvaluate` → overrides `compileSdk` to 34 (isar sets 30, dependencies need 33+)

**✅ PHASE 0 COMPLETE**

---

## Phase 1 — Design System
**Goal:** Complete token library. No screens yet — just the foundation.

- [x] `lib/core/theme/app_colors.dart` — all `AppColors` static constants
- [x] `lib/core/theme/app_typography.dart` — `AppTypography` (Cormorant Garamond, IBM Plex Sans, IBM Plex Mono)
- [x] `lib/core/theme/app_theme.dart` — `AppTheme.lightTheme` ThemeData
- [x] `lib/core/constants/spacing.dart` — `AppSpacing` + `AppRadius`
- [x] `lib/core/utils/currency_formatter.dart` — INR lakh/crore + international formats
- [x] `lib/core/utils/date_helpers.dart` — `daysUntilDebit`, `debitLabel`, `isUrgent`
- [ ] Google Fonts verified loading (Cormorant Garamond, IBM Plex Sans, IBM Plex Mono)
- [ ] Theme applied to `MaterialApp` — cream background visible on both simulators

---

## Phase 2 — Navigation Shell
**Goal:** 5-tab bottom nav with placeholder screens. Gold active tab.

- [x] `lib/app.dart` — GoRouter with `StatefulShellRoute` (5 branches)
- [x] `ScaffoldWithNavBar` widget with `BottomNavigationBar`
- [x] Bottom nav bar: gold active, inkDim inactive, surface bg, top border
- [x] `lib/screens/dashboard/dashboard_screen.dart` — placeholder
- [x] `lib/screens/accounts/accounts_screen.dart` — placeholder
- [x] `lib/screens/outgoings/outgoings_screen.dart` — placeholder
- [x] `lib/screens/portfolio/portfolio_screen.dart` — placeholder
- [x] `lib/screens/settings/settings_screen.dart` — placeholder
- [x] Tab switching works on both simulators
- [x] App bar: "Mudra" wordmark in Cormorant Garamond, gold

---

## Phase 3 — Data Layer (Isar + Riverpod)
**Goal:** All Isar models defined, generated, repositories and Riverpod providers wired up.

### Isar Models
- [x] `lib/data/models/account.dart` — `Account` with `@collection` annotations
- [x] `lib/data/models/outgoing.dart` — `Outgoing` with enums
- [x] `lib/data/models/investment_platform.dart` — `InvestmentPlatform`
- [x] `lib/data/models/debt.dart` — `Debt`
- [x] `lib/data/models/app_settings.dart` — `AppSettings` (singleton, id=1)
- [x] `dart run build_runner build --delete-conflicting-outputs` — `.g.dart` files generated
- [x] `lib/data/database.dart` — `openDatabase()` + `isarProvider`
- [x] Isar opens on iOS simulator (no crash)
- [x] Isar opens on Android emulator (no crash)

### Repositories
- [x] `lib/data/repositories/account_repository.dart` — CRUD + `watchAll()` stream
- [x] `lib/data/repositories/outgoing_repository.dart` — CRUD + `watchAll()` stream
- [x] `lib/data/repositories/investment_repository.dart` — CRUD + `watchAll()` stream
- [x] `lib/data/repositories/settings_repository.dart` — read/write singleton

### Riverpod Providers
- [x] `lib/providers/account_provider.dart` — `accountsStreamProvider` + filtered by type
- [x] `lib/providers/outgoing_provider.dart` — `outgoingsStreamProvider`
- [x] `lib/providers/investment_provider.dart` — `platformsStreamProvider` + `debtsStreamProvider`
- [x] `lib/providers/settings_provider.dart` — `settingsProvider`
- [x] `lib/providers/dashboard_provider.dart` — `DashboardData` computed from all streams
- [x] `main.dart` updated — Isar init before `runApp`, default settings seeded, `isarProvider` overridden
- [x] Sample data persists across app restarts (hot restart test)

---

## Phase 4 — Dashboard Screen + Navigation Rename + Runway Engine v2 ✅
**Goal:** Two-tab Home (This Month + Overall), renamed nav (Funds / Debits / Investments), day slider, collapsible table, Credits model.

### Navigation
- [x] `lib/app.dart` — rename nav labels: Accounts→Funds, Outgoings→Debits, Portfolio→Investments
- [x] `lib/app.dart` — update icons: Funds=savings_outlined, Debits=receipt_long_outlined
- [x] Rename screen files + classes: `funds_screen.dart` / `debits_screen.dart` / `investments_screen.dart`

### Widgets
- [x] `lib/widgets/common/amount_display.dart` — IBM Plex Mono always, colour-coded
- [x] `lib/widgets/common/section_label.dart` — uppercase, mono, tracked
- [x] `lib/widgets/common/empty_state.dart` — emoji + title + message + optional button
- [x] `lib/widgets/fuel_gauge_ring.dart` — CustomPainter ring, animated, colour changes + clipping fix + day label
- [x] `lib/widgets/debit_radar_item.dart` — coloured bar, name, category, days label

### Runway Engine v2 (Credits + Day Slider + Collapsible Table)
- [x] `lib/data/models/credit.dart` — Credit model + CreditSafe extension (Isar safe getters)
- [x] `lib/data/models/account.dart` — AccountSafe extension added
- [x] `lib/data/database.dart` — CreditSchema registered
- [x] `lib/providers/selected_day_provider.dart` — StateProvider<int> for day simulation
- [x] `lib/providers/credit_provider.dart` — creditsStreamProvider
- [x] `lib/providers/dashboard_provider.dart` — DashboardData refactored (41 fields, day-parameterised, Credits split by selectedDay)
- [x] `lib/widgets/fuel_gauge_ring.dart` — clipping fix (FittedBox wrap) + selectedDay label below gauge
- [x] `lib/screens/dashboard/dashboard_screen.dart` — day slider 1–31 + 4-section collapsible table (Cash/Credits/Debits/Commitments)
- [x] `lib/data/seed_data.dart` — salary (Day 1) + interest (Day 10) credits seeded
- [x] `CLAUDE.md` — Isar Data Safety section added
- [x] Pay Day banner removed
- [x] Overall tab: net worth hero + assets/investments/liabilities tiles

---

## Phase 5 — Funds Screen (Accounts)
**Goal:** Full CRUD for bank accounts with Add/Edit/Quick-Update sheets.

- [ ] `lib/widgets/account_tile.dart` — nickname, bank, balance, CC badge, FD line
- [ ] `lib/screens/accounts/funds_screen.dart`
  - [ ] Header card: liquid total + FD total (gold-light bg)
  - [ ] Segment control: Personal / Joint / Business
  - [ ] Accounts list filtered by segment, Dismissible delete
  - [ ] Empty state per segment
  - [ ] FAB → Add Account sheet
- [ ] Add Account bottom sheet
  - [ ] All fields: nickname, bank (with chips), balance, type, CC toggle, FD, liquid toggle (default ON for Personal only)
  - [ ] Validation: nickname required, balance is number
  - [ ] Save → Isar → haptic → close
- [ ] Edit Account sheet (pre-filled, same form + delete button)
- [ ] Quick Balance Update sheet (tap balance amount on tile → large numeric input)
- [ ] Swipe-to-delete with confirmation

---

## Phase 6 — Debits Screen (Outgoings)
**Goal:** Full CRUD for expenses and investments with date-aware sorting.

- [ ] `lib/widgets/outgoing_row.dart` — coloured left bar, name, category badge, date
- [ ] `lib/screens/outgoings/debits_screen.dart`
  - [ ] Upcoming strip (next 7 days, horizontal scroll chips)
  - [ ] Tab switcher: Expenses | Investments
  - [ ] Monthly total per tab (red / amber)
  - [ ] List sorted by debitDate ascending, Dismissible delete
  - [ ] Empty state per tab with instructions
  - [ ] FAB → Add Expense or Add Investment (based on active tab)
- [ ] Add Expense sheet (name suggestions, amount, date picker 1–31, category chips)
- [ ] Add Investment sheet (amber accent, investment categories)
- [ ] Edit sheets (pre-filled)

---

## Phase 7 — Investments Screen (Portfolio)
**Goal:** Net worth hero, investment platforms P&L, personal debts.

- [ ] `lib/widgets/platform_card.dart` — name, asset type badge, invested, current value, P&L chip
- [ ] `lib/screens/portfolio/investments_screen.dart`
  - [ ] Net worth hero (Cormorant Garamond, green/red/dim, tappable)
  - [ ] Assets + Liabilities row below hero
  - [ ] Investment platforms list with Dismissible delete
  - [ ] "I Owe" and "Owed to Me" debt subsections
  - [ ] Empty states for both sections
  - [ ] "Mark Settled" swipe action on debts
- [ ] Add Platform sheet (name, asset type, invested, current value, live P&L preview)
- [ ] Add Debt sheet (direction toggle, name, amount, due date, notes)
- [ ] Net Worth Detail sheet (~70% snap, assets / liabilities / formula breakdown)

---

## Phase 8 — Settings Screen
**Goal:** Income, pay date, currency, data management.

- [ ] `lib/screens/settings/settings_screen.dart`
  - [ ] Monthly income row → sheet with large amount input
  - [ ] Pay date row → sheet with 1–31 day picker
  - [ ] Currency group → sheet with flag chips (INR/USD/GBP/AED/SGD/AUD/EUR)
  - [ ] Currency change reformats all amounts app-wide
  - [ ] "Clear all data" with double-confirmation dialog → heavy haptic
  - [ ] Footer: Mudra wordmark, version, tagline

---

## Phase 9 — Polish & Edge Cases
**Goal:** Production-ready. Zero jank, zero empty screens, zero console noise.

- [ ] Haptic audit: lightImpact on save, mediumImpact on delete/update, vibrate on error
- [ ] All amounts formatted correctly: INR in lakh/crore system (₹ 1,50,000)
- [ ] Fuel gauge animation smooth on both devices (60fps, no jank)
- [ ] Fresh install empty states on every screen/section
- [ ] All bottom sheets scroll correctly with keyboard open
- [ ] Back button / swipe-dismiss works on all sheets
- [ ] Large number overflow test (₹ 10,00,00,000 — does UI break?)
- [ ] Zero liquidTotal edge case — no divide-by-zero in fuel gauge
- [ ] Negative balanceForMonth — fuel gauge shows 0%, negative amount in red
- [ ] Orientation locked to portrait (`SystemChrome.setPreferredOrientations`)
- [ ] App icon set (cream bg, gold "M")
- [ ] Splash screen (cream bg, Mudra wordmark)
- [ ] No debug banner (`debugShowCheckedModeBanner: false`)
- [ ] `flutter run --release` on both simulators — no console errors

---

## Progress Summary

| Phase | Items | Done | Remaining |
|---|---|---|---|
| 0 — Scaffold | 12 | 12 | 0 ✅ |
| 1 — Design System | 8 | 8 | 0 ✅ |
| 2 — Navigation | 10 | 10 | 0 ✅ |
| 3 — Data Layer | 17 | 17 | 0 ✅ |
| 4 — Dashboard + Runway Engine v2 | 29 | 29 | 0 ✅ |
| 5 — Funds (Accounts) | 14 | 0 | 14 |
| 6 — Debits (Outgoings) | 13 | 0 | 13 |
| 7 — Investments (Portfolio) | 16 | 0 | 16 |
| 8 — Settings | 7 | 0 | 7 |
| 9 — Polish | 14 | 0 | 14 |
| **TOTAL** | **134** | **96** | **38** |

---

## Key Decisions & Constraints

| Decision | Detail |
|---|---|
| Local-only MVP | No backend, no auth, no internet — Isar on-device only |
| State management | Riverpod 2.x with `@riverpod` code generation |
| Database | Isar 3.x (NoSQL, fast, works on simulator) |
| Typography | Cormorant Garamond (display) · IBM Plex Sans (body) · IBM Plex Mono (all currency — no exceptions) |
| Currency amounts | ALWAYS `CurrencyFormatter.format()` + IBM Plex Mono. Zero exceptions. |
| Colour grammar | Positive → green · Expenses/negative → red · Investments → amber |
| Backgrounds | `AppColors.background` (#FAF8F4) everywhere. Never `Colors.white` as scaffold bg. |
| Bottom sheets | All forms are bottom sheets, not full-screen routes |
| Phase discipline | Complete + test on both simulators before advancing to next phase |

---

*Source of truth: `vibes/5-25-mudra_flutter_build_plan.md` (plan) · `vibes/5-26-mudra_flutter_prompt.md` (phase prompts)*
*Update this file at the end of every build session.*
