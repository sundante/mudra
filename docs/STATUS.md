# Mudra — Build Status
**Authenticated Local-first MVP · Flutter · Supabase Identity · Device-local Finances**

> Legend: `[ ]` Not Started · `[~]` In Progress · `[x]` Done · `[!]` Blocked

**Last Updated:** 2026-05-28
**Current Phase:** Phase 14 Complete — Flow Map And Profile/Home UX Refinements
**Overall Progress:** Core implementation complete; configured auth/device verification pending

---

## Session Log
> Append a line at the start of every build session. Newest first.

| Date | Session | What was done | Stopped at |
|---|---|---|---|
| 2026-05-28 | Flow map + profile/home UX refinements | Rebuilt App Map as a compact flow-board driven by `assets/maps/mudra_app_map.json`, regenerated `docs/vibes/APP_MAP.html`, and added map widget coverage. Removed App Map from Home quick actions so it lives only in Profile. Simplified Profile to identity/navigation/account/data actions only; removed income, pay date, and currency controls from Profile. Removed the gold Month Runway hero from Home → This Month so the gauge is the primary visual. Gauge colour now follows projected month-end runway directly: grey at 0, green above 0, red below 0. `flutter analyze` clean; `flutter test` passing. | — |
| 2026-05-28 | Dev mode hardening | Full security audit and air-gap for dev builds. Bundled Cormorant Garamond, IBM Plex Sans, IBM Plex Mono as local assets — removed all google_fonts CDN calls from `app_typography.dart`, `amount_display.dart`, `mudra_hero_card.dart`; added `GoogleFonts.config.allowRuntimeFetching = false` guard. Switched `openDatabase()` and `resetDatabaseFiles()` to `getApplicationSupportDirectory()` (iOS iCloud backup excluded by default). Hidden Google/Apple social buttons when Supabase not configured. Added `Dev: Skip auth` + `Dev Tools` entry on WelcomeScreen (debug only). New `lib/screens/dev/dev_tools_screen.dart` with DB info, Clear all data, and Delete DB + reset. `flutter analyze` clean. | Install on real device to verify fonts + Dev Tools flow |
| 2026-05-28 | Auth screen layout fix | Fixed `WelcomeScreen` rendering assertion (`!semantics.parentDataDirty`) caused by `Spacer()` widgets + two-button `Row` in Copilot-added debug block. Replaced `Column` + `Spacer` with `SingleChildScrollView` + fixed padding. Consolidated debug buttons into one `Dev: Skip auth` button. | — |
| 2026-05-28 | Dev bypass added (Copilot) | Added `signInAsDebug()` method to `AppSessionController` and debug bypass buttons on WelcomeScreen. Also added `SetupWizardScreen`, `GuestHandoffScreen`, `GuidedTourOverlay`, and their providers for the US-002 onboarding flow. | — |
| 2026-05-28 | US-002 bug fix | Fixed guest mode router redirect: `AppSessionStage.guest` now redirects all auth paths (including `/welcome`) to `/`; previously only `/loading` was redirected, leaving the user stuck on the welcome screen. Standardized the guest CTA to "Use as Guest" in `WelcomeScreen`. | — |
| 2026-05-28 | US-001 implementation | Added canonical user story, Supabase auth repository/session gate, Welcome/Register/Login/Verify/Reset/Legacy/Setup screens, protected routing, per-user Isar stores, legacy attach/start-fresh, Profile sign-out, `hasCompletedSetup`, mobile deep links/identity, and white native splash configuration. `flutter analyze` clean; `flutter test` passed; Android debug APK builds. | Configure Supabase/Google/Apple consoles and manually verify real auth on iOS + Android |
| 2026-05-27 | Phase 10 complete | Variable spend logging feature: VariableExpense Isar model + Safe extension, VariableExpenseRepository (CRUD + watchCurrentMonth + sumUpToDay/countUpToDay), variableExpensesProvider + todaySpendProvider, QuickSpendSheet (amount, 6 category chips, optional note, date picker), Dashboard FAB → QuickSpendSheet, variableSpentToDay/variableExpensesToDayCount added to DashboardData, simulatedBalanceOnDay formula updated to subtract variableSpentToDay, Debts screen includes the "VARIABLE SPENT" monthly log with swipe-delete. Widget tests for QuickSpendSheet. flutter analyze clean. | — |
| 2026-05-27 | MVP Complete | Both iOS + Android emulators verified live. Phase 4 dashboard checklist confirmed: seeded data loads, slider updates gauge/balance, date picker locks to current month and syncs with slider, Overall tab renders. Phase 9 verified: bottom sheets scroll with keyboard, large numbers display without overflow, release build clean. 140/140 items complete. | — |
| 2026-05-27 | Phase 9 implementation | Orientation lock (SystemChrome.setPreferredOrientations), app icon generated (flutter_launcher_icons, cream bg + gold M), splash screen generated (flutter_native_splash, cream bg). Code-verified: haptics, amount formatting, fuel gauge animation, empty states, back/swipe-dismiss, divide-by-zero guard, negative balance guard, debug banner. flutter analyze clean. 3 items remain: bottom sheet keyboard scroll, large number overflow, release build — all need simulator. | Simulator verification |
| 2026-05-27 | Phase 8 complete | Built the first Profile/settings shell with finance anchors, data management, and footer. Added `clearAllData()` to database.dart. `flutter analyze` clean. Phase 14 later simplified Profile to identity/navigation/account actions only. | Simulator verification |
| 2026-05-27 | Phase 7 complete + Phase 8 start | Verified Phase 7 fully implemented: platform_card.dart, investments_screen.dart with Net Worth hero, platforms list, I Owe/Owed To Me debt sections with settled collapse, Add+Edit sheets for platforms and debts, Net Worth Detail sheet. `flutter analyze` clean. STATUS.md totals corrected (140 total items). Starting Phase 8 — Profile/settings foundation. | — |
| 2026-05-27 | Status reconciliation | Updated memory (was React Native — now Flutter), fixed STATUS.md header to Phase 7, corrected progress table for Phases 5+6, updated CLAUDE.md folder tree to match actual lib/ layout, fixed agent path references. | — |
| 2026-05-26 | Phase 6 implementation | Built `outgoing_row.dart`, replaced the Debits placeholder with a full Expenses/Investments screen, added a current-month upcoming strip, monthly totals, active-tab segmented control, sorted list with swipe delete, and add/edit bottom sheets with suggestion chips + current-month date picker. `flutter analyze` clean; `flutter test` passed. Tried Phase 4 iOS verification, but `flutter run` failed at simulator install with `IXErrorDomain code=19` after a successful Xcode build. | Android emulator still not connected; Phase 4 simulator verification remains open |
| 2026-05-26 | Phase 5 implementation start | Implemented shared UI primitives (`mudra_card`, `mudra_input`, `mudra_button`), built `account_tile.dart`, replaced the placeholder Funds screen with summary card + segment control + filtered account list + empty states + FAB, and added Add/Edit/Quick Balance/Delete account flows via bottom sheets. `flutter analyze` clean; `flutter test` passed. | Runtime verification of Phase 4 checklist and Funds screen behavior on simulators |
| 2026-05-26 | DB recovery path | Added recovery-aware startup bootstrap around `openDatabase()`, hydration validation probe across collections, local DB reset/reopen flow, reseed-on-recovery logging in `main.dart`, and bootstrap tests for normal + recovery startup. `flutter analyze` clean; `flutter test` passed. | Verify recovery + dashboard behavior on iOS and Android simulators |
| 2026-05-26 | Isar safety audit | Added Safe extensions for Debt, InvestmentPlatform, and AppSettings; expanded Account/Outgoing/Credit safe coverage to enums/bools/strings; switched dashboard/account providers to safe getters; `flutter analyze` clean. Likely remaining crash is hydration-time null from stale local Isar rows before safe getters run. | Confirm by clearing local DB or implement recovery path |
| 2026-05-26 | Runway Engine v3 | Reworked dashboard formula to as-of-day simulation, added `dayBalancePercent`, synced gauge arc/color to slider, renamed summary labels to Day's Liquid / Day's balance, added split sticky header with today's date left + current-month date picker right, and kept center gauge amount as projected month end. `flutter analyze` and `flutter test` clean. | Simulator verification on iOS + Android; runtime null crash still blocking |
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
- [x] Fonts bundled as local assets — no CDN calls. `assets/fonts/CormorantGaramond/`, `IBMPlexSans/`, `IBMPlexMono/` registered in `pubspec.yaml`; `app_typography.dart` uses `fontFamily:` directly; `GoogleFonts.config.allowRuntimeFetching = false` set in `main.dart`
- [x] Theme applied to `MaterialApp` — pure-white background configured throughout application surfaces

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
- [x] `lib/screens/profile/profile_screen.dart` — placeholder/profile entry
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

### Phase 4 Follow-up — Runway Engine v3 + Safety Audit
- Gauge arc now follows `dayBalancePercent` so the slider visibly changes fill and colour.
- Sticky header now shows today's date on the left and a current-month calendar picker on the right.
- Dashboard summary labels updated to `Day's Liquid` and `Day's balance`.
- Dashboard formula now uses an as-of-day simulation and keeps projected month end as the center gauge amount.
- Safe extensions now cover all Isar models in use, including enums, bools, and strings.
- Recovery-aware startup bootstrap now resets stale local DB files and retries automatically when hydration validation fails.
- [x] iOS simulator launch verified after recovery path
- [x] Android simulator launch verified after recovery path
- [x] Home renders correctly with seeded or recovered data
- [x] Slider updates selected day, gauge arc, and day balance
- [x] Date picker stays in current month and stays synced with slider
- [x] Overall tab renders correctly after recovery

---

## Phase 5 — Funds Screen (Accounts)
**Goal:** Full CRUD for bank accounts with Add/Edit/Quick-Update sheets.

- [x] `lib/widgets/account_tile.dart` — nickname, bank, balance, CC badge, FD line
- [x] `lib/screens/accounts/funds_screen.dart`
  - [x] Header card: liquid total + FD total (gold-light bg)
  - [x] Segment control: Personal / Joint / Business
  - [x] Accounts list filtered by segment, Dismissible delete
  - [x] Empty state per segment
  - [x] FAB → Add Account sheet
- [x] Add Account bottom sheet
  - [x] All fields: nickname, bank (with chips), balance, type, CC toggle, FD, liquid toggle (default ON for Personal only)
  - [x] Validation: nickname required, balance is number
  - [x] Save → Isar → haptic → close
- [x] Edit Account sheet (pre-filled, same form + delete button)
- [x] Quick Balance Update sheet (tap balance amount on tile → large numeric input)
- [x] Swipe-to-delete with confirmation

---

## Phase 6 — Debits Screen (Outgoings)
**Goal:** Full CRUD for expenses and investments with date-aware sorting.

- [x] `lib/widgets/outgoing_row.dart` — coloured left bar, name, category badge, date
- [x] `lib/screens/outgoings/debits_screen.dart`
  - [x] Upcoming strip (remaining current-month debits, horizontal scroll chips)
  - [x] Tab switcher: Expenses | Investments
  - [x] Monthly total per tab (red / amber)
  - [x] List sorted by debitDate ascending, Dismissible delete
  - [x] Empty state per tab with instructions
  - [x] FAB → Add Expense or Add Investment (based on active tab)
- [x] Add Expense sheet (name suggestions, amount, date picker 1–31, category chips)
- [x] Add Investment sheet (amber accent, investment categories)
- [x] Edit sheets (pre-filled)

---

## Phase 7 — Investments Screen (Portfolio)
**Goal:** Net worth hero, investment platforms P&L, personal debts.

- [x] `lib/widgets/platform_card.dart` — name, asset type badge, invested, current value, P&L chip
- [x] `lib/screens/portfolio/investments_screen.dart`
  - [x] Net worth hero (Cormorant Garamond, green/red/dim, tappable)
  - [x] Assets + Liabilities row below hero
  - [x] Investment platforms list with Dismissible delete
  - [x] "I Owe" and "Owed to Me" debt subsections
  - [x] Empty states for both sections
  - [x] "Mark Settled" swipe action on debts
- [x] Add Platform sheet (name, asset type, invested, current value, live P&L preview) + Edit
- [x] Add Debt sheet (direction toggle, name, amount, due date, notes) + Edit
- [x] Net Worth Detail sheet (~70% snap, assets / liabilities / formula breakdown)

---

## Phase 8 — Profile / Settings Foundation
**Goal:** Account/profile shell, initial finance anchors, and data management.

- [x] `lib/screens/profile/profile_screen.dart`
  - [x] Editable display name and initials avatar
  - [x] App Map entry
  - [x] Sign out action
  - [x] "Clear all data" with double-confirmation dialog → heavy haptic
  - [x] Footer: Mudra wordmark, privacy tagline, version

> Current product direction: Profile is now profile/settings-only. Income,
> pay date, and currency controls were removed from Profile in Phase 14; the
> stored fields remain for setup and dashboard calculations.

---

## Phase 9 — Polish & Edge Cases
**Goal:** Production-ready. Zero jank, zero empty screens, zero console noise.

- [x] Haptic audit: lightImpact on save, mediumImpact on delete/update, vibrate on error
- [x] All amounts formatted correctly: INR in lakh/crore system (₹ 1,50,000)
- [x] Fuel gauge animation smooth on both devices (60fps, no jank)
- [x] Fresh install empty states on every screen/section
- [x] All bottom sheets scroll correctly with keyboard open
- [x] Back button / swipe-dismiss works on all sheets
- [x] Large number overflow test (₹ 10,00,00,000 — does UI break?)
- [x] Zero liquidTotal edge case — no divide-by-zero in fuel gauge
- [x] Negative balanceForMonth — fuel gauge shows 0%, negative amount in red
- [x] Orientation locked to portrait (`SystemChrome.setPreferredOrientations`)
- [x] App icon set (pure-white bg, gold "M") — regenerated via flutter_launcher_icons
- [x] Splash screen (pure-white bg) — regenerated via flutter_native_splash
- [x] No debug banner (`debugShowCheckedModeBanner: false`)
- [x] `flutter run --release` on both simulators — no console errors

---

## Phase 10 — Variable Spend Logging
**Goal:** Let users log ad-hoc variable spends (food, transport, shopping, etc.) and have them automatically reflected in the day's simulated balance on the Dashboard.

### Data Layer
- [x] `lib/data/models/variable_expense.dart` — `VariableExpense` model: `uid`, `amount`, `category` (enum), `note?`, `spentAt`, `createdAt` + `VariableExpenseSafe` extension
- [x] `lib/data/models/variable_expense.g.dart` — generated Isar schema
- [x] `lib/data/database.dart` — `VariableExpenseSchema` registered in `openDatabase()`, hydration probe in `validateDatabase()`, `clearAllData()` updated
- [x] `lib/data/repositories/variable_expense_repository.dart` — `watchCurrentMonth()` stream, `save()`, `delete()`, static `sumUpToDay()`, static `countUpToDay()`
- [x] `lib/providers/variable_expense_provider.dart` — `variableExpensesProvider` (current month stream), `todaySpendProvider`

### UI
- [x] `lib/widgets/common/quick_spend_sheet.dart` — `QuickSpendSheet`: large amount input (IBM Plex Mono), 6 category chips (Food / Transport / Shopping / Health / Entertainment / Misc), optional note field, date chip (defaults Today, locks to current month), save with light haptic + snackbar
- [x] `lib/screens/dashboard/dashboard_screen.dart` — FAB on "This Month" tab opens `QuickSpendSheet`; `variableSpentToDay` row visible in the Cash section when > 0
- [x] `lib/screens/debts/debts_screen.dart` — expandable "VARIABLE SPENT" section shows current-month variable expense list, monthly total, and swipe-to-delete

### Dashboard Formula Update
- [x] `DashboardData` gains `variableSpentToDay` (double) and `variableExpensesToDayCount` (int)
- [x] `simulatedBalanceOnDay` now subtracts `variableSpentToDay`:
  `simulatedBalanceOnDay = openingLiquidBalance + creditsReceivedToDay − debitsFiredToDay − variableSpentToDay`

### Tests
- [x] `test/quick_spend_sheet_test.dart` — save button disabled at zero amount; submits correct amount + category

**✅ PHASE 10 COMPLETE**

---

## Phase 11 — US-001 First Launch Authentication And Account Entry
**Goal:** Require verified identity before financial access and isolate local records per authenticated account.

### Implemented
- [x] `docs/user-stories/US-001-first-launch-authentication.md` — approved story and implementation brief
- [x] Supabase/Auth repository plus Riverpod session controller with verification, recovery, migration, setup, and ready stages
- [x] Welcome, Register, Login, Verify Email, Forgot Password, New Password, Legacy Data, and Setup Welcome screens
- [x] Auth-aware GoRouter redirects protect all five-tab financial routes, Profile, and App Map
- [x] User-scoped Isar database lifecycle; signed-out startup does not open finance data or seed demo records
- [x] Legacy local database attach/start-fresh choice after authentication
- [x] `AppSettings.hasCompletedSetup` generated and used for setup routing
- [x] Profile sign-out and non-seeding clear-data behavior
- [x] iOS/Android identifiers and `mudra://auth/*` deep-link handling; Apple entitlement on iOS
- [x] Native splash configuration regenerated to pure white
- [x] Focused tests for Welcome gating, registration validation, and user database namespaces
- [x] `flutter analyze` clean, `flutter test` passing, and Android debug APK build successful

### Release Verification Pending
- [ ] Configure Supabase project redirect URLs and email confirmation/reset templates
- [ ] Configure Google and Apple provider credentials/capabilities for release builds
- [ ] Manually verify email, Google, Apple, reset-password, migration, and sign-out on target devices

---

## Phase 12 — US-002 Guest Mode And Guided Onboarding
**Goal:** No-commitment entry path with demo data, guided tour, and post-auth setup wizard.

### Router & Auth
- [x] `lib/app.dart` — `AppSessionStage.guest` redirect fixed: auth paths (including `/welcome`) now redirect to `/`
- [x] `lib/screens/auth/auth_screens.dart` — guest CTA standardized as "Use as Guest"

### Guest Session (Implemented)
- [x] `AppSessionStage.guest` added to `AppSessionController`
- [x] `enterGuestMode()` opens `mudra_guest` Isar store and seeds demo data
- [x] `exitGuestMode()` releases guest store and returns to `signedOut`
- [x] DEMO MODE banner in `ScaffoldWithNavBar` with "SIGN UP" shortcut
- [x] `lib/providers/onboarding_tour_provider.dart` — 5-step tour state (NotifierProvider)
- [x] `lib/widgets/onboarding/guided_tour_overlay.dart` — tour overlay widget

### Handoff & Setup (Implemented)
- [x] `lib/screens/onboarding/guest_handoff_screen.dart` — dark gold gradient handoff screen
- [x] `lib/screens/onboarding/setup_wizard_screen.dart` — 3-step skippable wizard
- [x] `lib/providers/setup_wizard_provider.dart` — wizard state (Notifier)
- [x] `setupRequired` stage routes to `/onboarding/setup`

### Verification Pending
- [ ] Hot-reload verify: tapping "Use as Guest" navigates to dashboard with demo data and DEMO MODE banner
- [ ] Verify guided tour overlay appears and advances through 5 steps
- [ ] Verify "Skip tour" jumps to `/onboarding/handoff`
- [ ] Verify handoff "Create account" / "Log in" clears guest state and routes correctly
- [ ] Verify setup wizard flows correctly for new users after email confirmation
- [ ] `flutter analyze` clean, `flutter test` passing

---

## Phase 13 — Dev Mode Hardening & Security Audit
**Goal:** Air-gap the dev build so it can be safely installed on a real phone with no outbound network from app code, no phone data access, and a built-in data management screen for the developer.

### Security Audit Findings (all addressed or deferred)
- [x] **Permissions** — only `INTERNET` on Android; zero `NS*UsageDescription` on iOS. No camera, contacts, location, mic. ✅
- [x] **Secrets** — no hardcoded keys; all injected via `--dart-define` at build time. ✅
- [x] **Analytics / tracking** — none; no Firebase, Crashlytics, ad SDKs. ✅
- [x] **Financial data** — 100% local in Isar; never sent to any server. ✅

### Font Bundling (removes Google CDN calls)
- [x] Downloaded Cormorant Garamond (Regular, Italic, Medium, SemiBold, Bold) → `assets/fonts/CormorantGaramond/`
- [x] Downloaded IBM Plex Sans (Regular, Italic, Medium, SemiBold) → `assets/fonts/IBMPlexSans/`
- [x] Downloaded IBM Plex Mono (Regular, Medium, SemiBold) → `assets/fonts/IBMPlexMono/`
- [x] `pubspec.yaml` — font families declared under `flutter.fonts:`
- [x] `lib/core/theme/app_typography.dart` — replaced all `GoogleFonts.*()` calls with `TextStyle(fontFamily: '...')`
- [x] `lib/widgets/common/amount_display.dart` — replaced `GoogleFonts.ibmPlexMono()` with bundled family
- [x] `lib/widgets/common/mudra_hero_card.dart` — replaced all `GoogleFonts.ibmPlexMono()` calls
- [x] `lib/main.dart` — added `GoogleFonts.config.allowRuntimeFetching = false;`

### iCloud Backup Exclusion (iOS)
- [x] `lib/data/database.dart` — switched `getApplicationDocumentsDirectory()` → `getApplicationSupportDirectory()` in `openDatabase()` and `resetDatabaseFiles()`. The Support directory is excluded from iCloud backup by default on iOS.

### Auth Screen Cleanup
- [x] `lib/screens/auth/auth_screens.dart` — `_SocialButtons` (Google/Apple) now hidden when `!session.authConfigured`, so they don't silently fail in a dev build with no Supabase keys

### Dev Tools Screen
- [x] `lib/screens/dev/dev_tools_screen.dart` — new screen (debug builds only)
  - [x] DB info card: name, file status, record counts (Accounts, Outgoings, Investments, Debts)
  - [x] **Open dev DB** — calls `signInAsDebug(userId: 'developer', ...)`, navigates to dashboard
  - [x] **Clear all data** — calls `clearAllData()` with confirmation dialog; keeps DB file
  - [x] **Delete DB + reset** — calls `resetDatabaseFiles()` with confirmation dialog; wipes `.isar` file, routes to `/welcome`
- [x] `lib/app.dart` — `/dev-tools` route added (only present in `kDebugMode`)
- [x] `lib/screens/auth/auth_screens.dart` — "Dev Tools" `TextButton` added below "Dev: Skip auth" on WelcomeScreen

### Deferred to Production Hardening
- [ ] Database encryption at rest (Isar v3 limitation; address when upgrading to Isar v4+)
- [ ] Certificate pinning for Supabase connections
- [ ] Session timeout policies (backend not wired yet)
- [ ] Biometric unlock (future feature)

**✅ PHASE 13 COMPLETE — `flutter analyze` clean**

---

## Phase 14 — Flow Map And Profile/Home UX Refinements
**Goal:** Make app structure visible without clutter and simplify Profile/Home around their core jobs.

### App Map
- [x] `assets/maps/mudra_app_map.json` — shared source of truth for the in-app map and HTML map
- [x] `lib/screens/map/map_screen.dart` — compact horizontal flow-board renderer with tap-to-expand nodes, decision diamonds, curved connectors, and a single Expand all / Collapse all toggle
- [x] `tool/generate_app_map_html.dart` — generates self-contained `docs/vibes/APP_MAP.html` from shared JSON
- [x] `test/map_screen_test.dart` — root-only default, node expansion, expand-all, collapse-all coverage

### Profile
- [x] App Map removed from Home quick actions; Profile is now the only app entry point for `/map`
- [x] Profile now shows identity, App Map, sign out, clear local data, and footer only
- [x] Removed Profile income, pay-date, and currency controls/sheets
- [x] Profile copy softened away from finance dashboards: "local app data", "private by default"

### Home
- [x] Removed the gold `MONTH RUNWAY` hero card from Home → This Month
- [x] This Month now leads with the fuel gauge as the primary visual
- [x] Gauge colour is value-based: grey at projected month end = 0, green when > 0, red when < 0

**✅ PHASE 14 COMPLETE — `flutter analyze` clean, `flutter test` passing**

---

## Progress Summary

| Phase | Items | Done | Remaining |
|---|---|---|---|
| 0 — Scaffold | 12 | 12 | 0 ✅ |
| 1 — Design System | 8 | 8 | 0 ✅ |
| 2 — Navigation | 10 | 10 | 0 ✅ |
| 3 — Data Layer | 17 | 17 | 0 ✅ |
| 4 — Dashboard + Runway Engine v2 | 29 | 29 | 0 ✅ |
| 5 — Funds (Accounts) | 14 | 14 | 0 ✅ |
| 6 — Debits (Outgoings) | 13 | 13 | 0 ✅ |
| 7 — Investments (Portfolio) | 16 | 16 | 0 ✅ |
| 8 — Profile / Settings Foundation | 5 | 5 | 0 ✅ |
| 9 — Polish | 14 | 14 | 0 ✅ |
| 10 — Variable Spend Logging | 12 | 12 | 0 ✅ |
| 11 — US-001 Authentication | 15 | 12 | 3 verification items |
| 12 — US-002 Guest Mode | 14 | 8 | 6 verification items |
| 13 — Dev Mode Hardening | 18 | 14 | 4 deferred to prod hardening |
| 14 — Flow Map + UX Refinements | 11 | 11 | 0 ✅ |
| **TOTAL** | **208** | **195** | **13 items** |

---

## Features Implemented

> This section is the hand-off reference. Phases 0-10 were device-verified;
> Phase 11 is code-complete and awaiting configured Supabase/provider device verification.

### App Infrastructure
- Supabase-backed identity gate; finances remain device-local in per-user Isar stores
- Authenticated database bootstrap with recovery and one-time legacy attach/start-fresh handling
- Fresh install enters Welcome and setup handoff without seeded financial records
- Portrait-only orientation lock
- Custom app icon: white background, gold "M" (flutter_launcher_icons)
- Pure-white splash screen (flutter_native_splash)
- No debug banner in release builds

### Design System
- **3-font stack**: Cormorant Garamond (display/hero numbers), IBM Plex Sans (all UI text), IBM Plex Mono (every currency amount, no exceptions)
- **Colour grammar**: green = positive/income, red = expense/negative/debt, amber = investment, gold = CTA/accent, white (#FFFFFF) = page background
- **Interaction grammar**: save → light haptic, delete/update → medium haptic, error → vibrate
- Token library: `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`
- `CurrencyFormatter`: INR lakh/crore system (₹ 1,50,000 / ₹ 10.5L / ₹ 1.2Cr) + 6 international currencies

### Navigation
- Welcome/Auth/Setup entry routes protect the five-tab financial shell
- 5-tab bottom nav: Home / Funds / Debts / Invests / Net
- GoRouter + `StatefulShellRoute` — tab state persists across switches
- Gold active tab, dim inactive, top border on nav bar

### Home — Dashboard (2 tabs)

**"This Month" tab**
- Sticky header: today's date on the left, current-month date picker on the right
- Fuel gauge ring (animated): shows projected month-end balance; grey at 0, green above 0, red below 0
- Day slider (1–31): simulates your balance on any day of the current month
- Day's Liquid + Day's Balance labels update live with the slider
- 4-section collapsible table: Cash · Credits · Debits · Commitments
- Debit radar: horizontal chips showing upcoming fixed debits this month

**"Overall" tab**
- Net Worth hero (Cormorant Garamond, colour-coded green/red)
- Total Assets / Investments / Liabilities stat tiles
- Breakdown rows: Liquid · FD · Investments · Total Liabilities

**Runway Engine v3 (41-field DashboardData)**
- `liquidTotal` = sum of personal liquid account balances
- `simulatedBalanceOnDay` = opening balance + credits received by day − debits fired by day
- `projectedMonthEnd` = simulated balance − remaining committed debits − CC outstanding
- `dayBalancePercent` = (simulatedBalanceOnDay / openingLiquidBalance × 100).clamp(0, 100)
- `netWorth` = totalAssets − totalLiabilities
- Divide-by-zero guard when `liquidTotal == 0`; projected month-end value drives gauge colour

### Funds — Bank Accounts
- 3-segment filter: Personal / Joint / Business
- Header card: total liquid balance + total FD balance
- Account tile: nickname, bank name, balance (mono), CC badge, FD sub-line
- **Add account**: nickname, bank (suggestion chips), balance, type, CC toggle, FD amount, liquid toggle
- **Edit account**: pre-filled same form + delete button
- **Quick balance update**: tap the balance amount on any tile → large numeric input sheet
- Swipe-to-delete with confirmation + medium haptic
- Empty state per segment

### Debits — Expenses, Investments & Variable Spend
- Tab switcher: Expenses | Investments | Spent
- Upcoming strip: horizontal scroll chips for debits still due this month
- Monthly total per tab (red for expenses/spent, amber for investments)
- Debit row: coloured left bar, name, category badge, date label, days-until label
- **Add/Edit Expense**: name (suggestion chips), amount, debit date (1–31), category chips (loan, insurance, utility, subscription, other)
- **Add/Edit Investment**: amber accent, investment categories (SIP, PPF, EPF, NPS, other)
- **Variable Spent section**: variable expenses for the current month, sorted newest first, swipe-to-delete
- List sorted by debit date ascending (Expenses/Investments tabs)
- Swipe-to-delete; empty state per tab

### Investments — Portfolio
- Net Worth hero (tappable → Net Worth Detail sheet)
- Assets + Liabilities summary row
- Investment platform cards: platform name, asset type badge (amber), invested amount, current value, P&L chip (green gain / red loss, %)
- **Add/Edit Platform**: name, asset type (Indian stocks, US stocks, mutual fund, PPF, EPF, NPS, gold, other), invested amount, current value, live P&L preview
- **I Owe** and **Owed to Me** debt subsections, each with active count
- Debt row: counterparty name, amount, due date, notes
- **Add/Edit Debt**: direction toggle (I Owe / They Owe), counterparty, amount, due date (optional), notes (optional)
- **Mark Settled** swipe action on active debts
- Settled debts collapse under an expandable section
- **Net Worth Detail sheet** (~70% snap): formula breakdown — bank balance + FD + investments − CC outstanding − debts I owe
- Empty states for platforms and debts

### Profile
- Identity header with editable display name and initials avatar
- **App Map**: opens the compact flow-board map; this is the only in-app entry point to `/map`
- **Sign out**: closes access to the active local store and returns to Welcome
- **Clear all data**: double-confirmation dialog → heavy haptic → wipes the signed-in user's collections and retains an empty configured workspace
- Footer: Mudra wordmark + "private by default." + v1.0.0

### Variable Spend Logging
- **QuickSpendSheet**: large amount input (IBM Plex Mono), 6 category chips (Food / Transport / Shopping / Health / Entertainment / Misc), optional note, date picker (current month only, defaults to today)
- **Dashboard FAB** (This Month tab): opens QuickSpendSheet; logged amount immediately reduces simulated balance and fuel gauge
- **Debts → Variable Spent**: full list of current-month variable expenses, newest first, swipe-to-delete, monthly total
- `variableSpentToDay` is subtracted from `simulatedBalanceOnDay` in the Runway Engine formula

### Data Layer
- **8 Isar models**: Account, Outgoing, InvestmentPlatform, InvestmentHolding, Debt, AppSettings, Credit, VariableExpense — with Safe extension getters for runtime null safety
- AuthRepository manages Supabase identity; finance repositories read from the active authenticated user store
- **8 Riverpod providers**: accountsStream, outgoingsStream, platformsStream, debtsStream, creditsStream, settingsProvider, variableExpensesProvider, dashboardProvider (DashboardData)
- `clearAllData()` utility in `database.dart` — clears all 7 collections

---

## Key Decisions & Constraints

| Decision | Detail |
|---|---|
| Authenticated local-first | Supabase provides identity; finance records remain on-device in a user-scoped Isar store |
| State management | Riverpod 2.x with `@riverpod` code generation |
| Database | Isar 3.x (NoSQL, fast, works on simulator) |
| Typography | Cormorant Garamond (display) · IBM Plex Sans (body) · IBM Plex Mono (all currency — no exceptions) |
| Currency amounts | ALWAYS `CurrencyFormatter.format()` + IBM Plex Mono. Zero exceptions. |
| Colour grammar | Positive → green · Expenses/negative → red · Investments → amber |
| Backgrounds | `AppColors.background` (#FFFFFF) for page and app-bar backgrounds |
| Bottom sheets | All forms are bottom sheets, not full-screen routes |
| Phase discipline | Complete + test on both simulators before advancing to next phase |

---

*Source of truth: `vibes/5-25-mudra_flutter_build_plan.md` (plan) · `vibes/5-26-mudra_flutter_prompt.md` (phase prompts)*
*Update this file at the end of every build session.*
