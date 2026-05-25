# Mudra — Build Plan
**Flutter MVP · Local-first · No Backend · No Auth**
Version 2.0 · May 2026

> This is the canonical agent-facing build plan. For the detailed phase-by-phase
> Claude Code prompts (exact code to generate), see `vibes/5-26-mudra_flutter_prompt.md`.
> For live build status, see `docs/STATUS.md`.

---

## What We're Building

A local Flutter finance awareness app (iOS + Android). No backend. No login. All data on-device via Isar. The core feature is the **"BalanceForTheMonth" fuel gauge** — what the user can actually spend this month after fixed commitments are subtracted from liquid cash.

**This version replaces an Excel sheet.** It will later evolve into the full MudraMaster product.

---

## Tech Stack

| Layer | Choice | Notes |
|---|---|---|
| Framework | Flutter (latest stable) | iOS + Android from one codebase |
| State | Riverpod 2.x + `riverpod_generator` | `@riverpod` annotation style; generator pinned to `2.4.0` |
| Storage | Isar 3.x | On-device NoSQL; requires Android build patches (see below) |
| Navigation | GoRouter | `StatefulShellRoute` for tab persistence |
| Fonts | `google_fonts` | Cormorant Garamond · IBM Plex Sans · IBM Plex Mono |
| Numbers | `intl` | Indian lakh/crore formatting |
| Animation | `flutter_animate` | Declarative, simple |

### Known Dependency Constraints

**`riverpod_generator` pinned to `2.4.0`** — `isar_generator 3.x` requires `analyzer <6.0.0`; `riverpod_generator ≥2.4.2` requires `analyzer ^6.x`. Pin resolves the conflict. Do not upgrade without checking.

**Android `build.gradle.kts` patches (permanent)** — `isar_flutter_libs 3.x` was built against AGP 7.3 and is incompatible with AGP 8+ out of the box. Two patches live in `android/build.gradle.kts`:
1. `plugins.withId` → sets `namespace = "dev.isar.isar_flutter_libs"` (AGP 8+ requirement)
2. `afterEvaluate` → overrides `compileSdk` to 34 (isar sets 30; transitive deps need 33+)

---

## The 5 Screens

| Tab | Screen | Purpose |
|---|---|---|
| 🏠 Home | Dashboard | Two-tab layout: "This Month" (fuel gauge, debit radar) + "Overall" (net worth hero, assets/liabilities) |
| 💰 Funds | Funds | Bank accounts by type, add/edit/delete, quick balance update |
| 🧾 Debits | Debits | Fixed expenses + investments with debit dates, monthly totals |
| 📈 Investments | Investments | Investment platforms P&L, debts owed/receivable, net worth breakdown |
| ⚙️ Settings | Settings | Income, currency, data management |

All forms open as **bottom sheets**, never full-screen routes.

### Home Screen — Two Tabs

**"This Month"** — What's my financial health right now?
- Fuel gauge ring (balanceForMonth / liquidTotal, animated, green/amber/red)
- Liquid total + Committed split row
- 7-day debit radar (upcoming fixed debits)

**"Overall"** — What does my full picture look like?
- Net Worth hero (Cormorant Garamond, large, colour-coded)
- Three stat tiles: Total Assets · Investments · Liabilities
- Breakdown rows: Liquid / FD / Investments / Total Liabilities

---

## Data Models

### Account
```
id, uid, nickname, bankName
accountType: personal | joint | business
isCreditCard, balance, fdAmount
includeInLiquid, balanceUpdatedAt, sortOrder, isDeleted, createdAt
```

### Outgoing
```
id, uid, name
outgoingType: expense | investment
category: loan | insurance | utility | subscription | sip | ppf | epf | nps | other
amount, debitDate (1–31), isActive, createdAt
```

### InvestmentPlatform
```
id, uid, platformName
assetType: indianStocks | usStocks | mutualFund | ppf | epf | nps | gold | other
investedAmount, currentValue, valueUpdatedAt, isDeleted, createdAt
```

### Debt
```
id, uid, counterpartyName
direction: iOwe | theyOwe
amount, dueDate?, notes?, isSettled, createdAt
```

### AppSettings (singleton, id=1)
```
baseCurrency, monthlyIncome, payDate (1–31)
```

---

## Key Computed Values (DashboardData)

```
liquidTotal      = SUM(balance) WHERE personal + includeInLiquid + NOT creditCard
fdTotal          = SUM(fdAmount) across ALL accounts
fixedCommitted   = SUM(amount) WHERE isActive AND debitDate >= today.day
balanceForMonth  = liquidTotal - fixedCommitted
balancePercent   = (balanceForMonth / liquidTotal * 100).clamp(0, 100)
investmentsTotal = SUM(platform.currentValue)
totalAssets      = liquidTotal + fdTotal + investmentsTotal
totalLiabilities = SUM(cc.balance) + SUM(debt.amount WHERE iOwe + !settled)
netWorth         = totalAssets - totalLiabilities
debitRadar       = outgoings WHERE daysUntilDebit <= 7, sorted by daysUntil
```

---

## Design System (Non-Negotiable Rules)

### Colour Grammar
- Positive / income → `AppColors.green` (#2A6B4F)
- Expense / negative / debt → `AppColors.red` (#A83226)
- Investment / neutral → `AppColors.amber` (#A05A10)
- Primary CTA / accent → `AppColors.gold` (#8A6520)
- Background → `AppColors.background` (#FAF8F4) — **never** `Colors.white` as scaffold bg

### Typography Grammar
- **Hero numbers / headings** → Cormorant Garamond (`AppTypography.displayLarge` etc.)
- **All UI text** → IBM Plex Sans (`AppTypography.bodyLarge` etc.)
- **ALL currency amounts** → IBM Plex Mono (`AppTypography.monoMedium` etc.) — **zero exceptions**
- **Section labels** → IBM Plex Mono, 9.5px, 1.8 letterSpacing, ALL CAPS, `AppColors.inkDim`

### Interaction Grammar
- Save / create → `HapticFeedback.lightImpact()`
- Delete → `HapticFeedback.mediumImpact()`
- Balance updated → `HapticFeedback.mediumImpact()`
- Error / validation fail → `HapticFeedback.vibrate()`
- Loading → skeleton shimmer, never a spinner on content areas

---

## Build Phases

| Phase | Name | Gate before next phase |
|---|---|---|
| **0** | ~~Scaffold~~ ✅ | ~~Both simulators show cream bg + "Mudra" gold text, zero errors~~ **DONE** |
| **1** | Design System | Theme applied, fonts loading, `flutter analyze` clean |
| **2** | Navigation Shell | 5-tab nav working on both simulators |
| **3** | Data Layer | Isar opens, providers compile, sample data persists on hot restart |
| **4** | Dashboard | Both tabs render: fuel gauge animates, debit radar loads, Overall tab shows net worth |
| **5** | Funds | Full CRUD: add/edit/delete/quick-update, all 3 segments working |
| **6** | Debits | Full CRUD: expenses + investments, date picker, monthly totals |
| **7** | Investments | Net worth hero, P&L platforms, debt sections, breakdown sheet |
| **8** | Settings | Income/date/currency/clear-data all saving to Isar |
| **9** | Polish | Release build clean on both simulators, all edge cases handled |

**Phase discipline:** Complete one phase fully. Test on both simulators. Commit to git. Then advance.

---

## Folder Structure

```
lib/
├── main.dart                          # app entry, Isar init, ProviderScope
├── app.dart                           # MudraApp, GoRouter, ScaffoldWithNavBar
├── core/
│   ├── theme/
│   │   ├── app_colors.dart            # AppColors static constants
│   │   ├── app_typography.dart        # AppTypography (3 fonts)
│   │   └── app_theme.dart             # AppTheme.lightTheme ThemeData
│   ├── constants/
│   │   └── spacing.dart               # AppSpacing + AppRadius
│   └── utils/
│       ├── currency_formatter.dart    # CurrencyFormatter (INR lakh/crore)
│       └── date_helpers.dart          # daysUntilDebit, debitLabel, isUrgent
├── data/
│   ├── models/
│   │   ├── account.dart               # @collection + AccountType enum
│   │   ├── outgoing.dart              # @collection + enums
│   │   ├── investment_platform.dart   # @collection + AssetType enum
│   │   ├── debt.dart                  # @collection + DebtDirection enum
│   │   └── app_settings.dart          # @collection, singleton id=1
│   ├── repositories/
│   │   ├── account_repository.dart
│   │   ├── outgoing_repository.dart
│   │   ├── investment_repository.dart
│   │   └── settings_repository.dart
│   └── database.dart                  # openDatabase(), isarProvider
├── providers/
│   ├── account_provider.dart          # accountsStreamProvider + filtered
│   ├── outgoing_provider.dart         # outgoingsStreamProvider
│   ├── investment_provider.dart       # platformsStreamProvider + debtsStreamProvider
│   ├── settings_provider.dart         # settingsProvider
│   └── dashboard_provider.dart        # DashboardNotifier → DashboardData
├── screens/
│   ├── dashboard/dashboard_screen.dart   # two-tab: This Month + Overall
│   ├── accounts/funds_screen.dart        # tab label: Funds
│   ├── outgoings/debits_screen.dart      # tab label: Debits
│   ├── portfolio/investments_screen.dart # tab label: Investments
│   └── settings/settings_screen.dart
└── widgets/
    ├── common/
    │   ├── amount_display.dart        # IBM Plex Mono, colour-coded
    │   ├── section_label.dart         # Mono, uppercase, tracked
    │   ├── empty_state.dart           # emoji + title + message + optional CTA
    │   ├── mudra_button.dart
    │   ├── mudra_input.dart
    │   └── mudra_card.dart
    ├── fuel_gauge_ring.dart           # CustomPainter, animated
    ├── account_tile.dart
    ├── outgoing_row.dart
    ├── debit_radar_item.dart
    └── platform_card.dart
```

---

## pubspec.yaml Dependencies

```yaml
dependencies:
  flutter: {sdk: flutter}
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.3
  go_router: ^14.2.2
  google_fonts: ^6.2.1
  intl: ^0.19.0
  flutter_animate: ^4.5.0
  uuid: ^4.4.0
  collection: ^1.18.0

dev_dependencies:
  flutter_test: {sdk: flutter}
  flutter_lints: ^4.0.0
  isar_generator: ^3.1.0+1
  riverpod_generator: ^2.4.3
  build_runner: ^2.4.11
  custom_lint: ^0.6.7
  riverpod_lint: ^2.3.13
```

---

## P0 User Stories (Must ship)

| # | Story | Screen |
|---|---|---|
| US-01 | Add a bank account with name, balance, type | Accounts |
| US-02 | Update an account balance quickly | Accounts |
| US-03 | See total liquid balance across personal accounts | Dashboard |
| US-04 | Add a fixed monthly expense with debit date | Outgoings |
| US-05 | Add a fixed monthly investment (SIP, PPF) with debit date | Outgoings |
| US-06 | See BalanceForTheMonth — what I can actually spend | Dashboard |
| US-07 | See which debits are coming in the next 7 days | Dashboard |
| US-08 | Set monthly income to anchor the fuel gauge | Settings |

## P1 User Stories (Strong MVP)

| # | Story |
|---|---|
| US-09 | Add investment platforms with invested + current value |
| US-10 | See net worth (assets − liabilities) |
| US-11 | Add personal debts (what I owe, what others owe me) |
| US-12 | Delete / edit any account, outgoing, or investment |
| US-13 | Choose base currency (INR/USD/GBP/AED/SGD/AUD/EUR) |

---

## Edge Cases to Handle

| Case | Expected behaviour |
|---|---|
| `liquidTotal == 0` | Fuel gauge shows 0%, no divide-by-zero |
| `balanceForMonth < 0` | Gauge shows 0%, amount displayed in red |
| No outgoings | `fixedCommitted = 0`, gauge full |
| Very large numbers (₹10Cr) | Compact formatting, no overflow |
| Empty debit radar | "All clear" empty state |
| Fresh install | Instructional empty states everywhere, settings default to INR |

---

*Full phase prompts: `vibes/5-26-mudra_flutter_prompt.md`*
*Live status: `docs/STATUS.md`*
*Project conventions: `CLAUDE.md`*
