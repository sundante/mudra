# Mudra — Flutter MVP Build Plan
**Local-first · No Backend · No Auth · Personal Finance Dashboard**
Version 2.0 · May 2026

---

## Overview

This is a deliberately simplified build plan. The goal is a working,
beautiful, locally-stored finance dashboard you can use personally
**instead of the Excel sheet** — and later evolve into the full
MudraMaster product.

### What this version IS
- A local Flutter app (iOS + Android)
- All data stored on-device (Hive / Isar)
- No login, no backend, no internet required
- The core financial dashboard: fuel gauge, accounts, outgoings, portfolio
- Usable as a personal finance tool from day one

### What this version is NOT (yet)
- No authentication or user accounts
- No backend / API / cloud sync
- No push notifications
- No bank sync / Account Aggregator
- No subscription / paywall
- No onboarding wizard (manual setup via Settings)

---

## Tech Stack

| Layer | Choice | Why |
|---|---|---|
| Framework | Flutter (latest stable) | Cross-platform iOS + Android from one codebase |
| Language | Dart | Flutter's native language, Claude Code friendly |
| State | Riverpod 2.x | Modern, type-safe, scales well to full app later |
| Local Storage | Isar (NoSQL) | Fast queries, works on simulator, no SQL needed |
| Navigation | GoRouter | Declarative, deep-link ready for later |
| Fonts | google_fonts package | Cormorant Garamond + IBM Plex Sans + IBM Plex Mono |
| Numbers | intl package | Indian lakh/crore + international formatting |
| Animations | flutter_animate | Simple, declarative animation library |
| SVG | flutter_svg | For the fuel gauge ring and icons |

---

## Simplified User Stories (MVP)

### P0 — Core (Must have to replace the Excel sheet)

| # | Story | Screen |
|---|---|---|
| US-01 | Add a bank account with name, balance, and type (personal/joint/business) | Accounts |
| US-02 | Update an account balance quickly | Accounts |
| US-03 | See my total liquid balance across all personal accounts | Dashboard |
| US-04 | Add a fixed monthly expense with name, amount, and debit date | Outgoings |
| US-05 | Add a fixed monthly investment (SIP, PPF etc.) with amount and debit date | Outgoings |
| US-06 | See my BalanceForTheMonth — what I can actually spend | Dashboard |
| US-07 | See which debits are coming in the next 7 days | Dashboard |
| US-08 | Set my monthly income so the fuel gauge has an anchor | Settings |

### P1 — Strong MVP (Makes it a proper finance tool)

| # | Story | Screen |
|---|---|---|
| US-09 | Add investment platforms with invested + current value (Demat, MF, EPF etc.) | Portfolio |
| US-10 | See my net worth (assets minus liabilities) | Portfolio / Dashboard |
| US-11 | Add personal debts (what I owe and what others owe me) | Portfolio |
| US-12 | Delete or edit any account, outgoing, or investment | All screens |
| US-13 | Choose my base currency (INR/USD/GBP etc.) | Settings |

### P2 — Post-MVP (Not in this build)

| # | Story |
|---|---|
| US-14 | Month-on-month net worth trend chart |
| US-15 | Variable expense log (daily spending) |
| US-16 | Goal-based savings buckets |
| US-17 | CSV/PDF export |
| US-18 | Cloud sync / backup |

---

## Screen Inventory (6 screens)

| Screen | Tab | Purpose |
|---|---|---|
| Dashboard | 🏠 Home | Fuel gauge, liquid total, 7-day debit radar, net worth |
| Accounts | 🏦 Accounts | All bank accounts grouped by type, add/edit/delete |
| Outgoings | 📤 Outgoings | Fixed expenses + investments tabs, monthly total |
| Portfolio | 📈 Portfolio | Investment platforms + debts + net worth breakdown |
| Settings | ⚙️ Settings | Income, currency, app preferences |
| Add/Edit (Sheets) | — | Bottom sheet forms for each data type |

---

## Build Phases

### Phase 0 — Scaffold Only (Start Here)
Goal: Flutter app running on iOS simulator AND Android emulator.
Nothing else. Just the shell.

### Phase 1 — Design System
Colours, typography, spacing, shared widgets.

### Phase 2 — Navigation Shell
Bottom tab bar with 5 placeholder screens.

### Phase 3 — Data Layer
Isar database schema + Riverpod providers for each entity.

### Phase 4 — Dashboard Screen
Fuel gauge ring, liquid total, debit radar.

### Phase 5 — Accounts Screen
Add / edit / delete accounts. Balance update sheet.

### Phase 6 — Outgoings Screen
Add / edit / delete expenses and investments.

### Phase 7 — Portfolio Screen
Investment platforms, debts, net worth breakdown.

### Phase 8 — Settings Screen
Income, currency, data management.

### Phase 9 — Polish
Empty states, animations, haptics, edge cases.

---

## Folder Structure

```
mudra/
├── lib/
│   ├── main.dart
│   ├── app.dart                    ← MaterialApp, theme, GoRouter
│   ├── core/
│   │   ├── theme/
│   │   │   ├── colors.dart         ← All colour constants
│   │   │   ├── typography.dart     ← TextStyle definitions
│   │   │   └── app_theme.dart      ← ThemeData
│   │   ├── constants/
│   │   │   └── spacing.dart
│   │   └── utils/
│   │       ├── currency_formatter.dart
│   │       └── date_utils.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── account.dart        ← Isar schema
│   │   │   ├── outgoing.dart
│   │   │   ├── investment.dart
│   │   │   ├── debt.dart
│   │   │   └── app_settings.dart
│   │   ├── repositories/
│   │   │   ├── account_repository.dart
│   │   │   ├── outgoing_repository.dart
│   │   │   ├── investment_repository.dart
│   │   │   └── settings_repository.dart
│   │   └── database.dart           ← Isar init
│   ├── providers/
│   │   ├── account_provider.dart
│   │   ├── outgoing_provider.dart
│   │   ├── investment_provider.dart
│   │   ├── dashboard_provider.dart  ← Computed: balance, net worth
│   │   └── settings_provider.dart
│   ├── screens/
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── accounts/
│   │   │   └── accounts_screen.dart
│   │   ├── outgoings/
│   │   │   └── outgoings_screen.dart
│   │   ├── portfolio/
│   │   │   └── portfolio_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   └── widgets/
│       ├── common/
│       │   ├── mudra_button.dart
│       │   ├── mudra_input.dart
│       │   ├── mudra_card.dart
│       │   ├── amount_display.dart
│       │   ├── section_label.dart
│       │   ├── empty_state.dart
│       │   └── skeleton_loader.dart
│       ├── fuel_gauge_ring.dart    ← The hero widget
│       ├── account_tile.dart
│       ├── outgoing_row.dart
│       ├── debit_radar_item.dart
│       └── platform_card.dart
├── pubspec.yaml
└── test/
```

---

## Data Models

### Account
```dart
id, nickname, bankName, accountType (personal/joint/business),
isCreditCard, balance, fdAmount, includeInLiquid,
balanceUpdatedAt, sortOrder
```

### Outgoing
```dart
id, name, outgoingType (expense/investment),
category (loan/insurance/utility/subscription/sip/ppf/epf/other),
amount, debitDate (1-31), isActive
```

### InvestmentPlatform
```dart
id, platformName, assetType
(indian_stocks/us_stocks/mutual_fund/ppf/epf/nps/gold/other),
investedAmount, currentValue, valueUpdatedAt
```

### Debt
```dart
id, counterpartyName, direction (i_owe/they_owe),
amount, dueDate, notes, isSettled
```

### AppSettings
```dart
baseCurrency, monthlyIncome, payDate (1-31)
```

---

## Key Computed Values (Dashboard Provider)

```
liquidTotal      = SUM(balance) WHERE includeInLiquid AND NOT isCreditCard
                   (personal accounts only)

fdTotal          = SUM(fdAmount) across all accounts

fixedCommitted   = SUM(amount) WHERE outgoing.debitDate >= today.day
                   AND outgoing.isActive

balanceForMonth  = liquidTotal - fixedCommitted

balancePercent   = (balanceForMonth / liquidTotal) * 100
                   clamped to 0-100

totalAssets      = liquidTotal + fdTotal + SUM(currentValue of platforms)

totalLiabilities = SUM(balance WHERE isCreditCard)
                 + SUM(amount WHERE debt.direction == 'i_owe' AND !settled)

netWorth         = totalAssets - totalLiabilities

debitRadar       = outgoings WHERE daysUntilDebit(debitDate) <= 7
                   sorted by daysUntil ascending
```

---

## Design System Quick Reference

```
Background:   #FAF8F4   Warm off-white (never pure white)
Surface:      #FFFFFF   Cards, bottom sheets
Surface2:     #F2EFE9   Alternate section background
Border:       #E4E0D8   Default dividers
Ink:          #1C1814   Primary text
InkMid:       #4A443C   Body copy
InkDim:       #8A8278   Labels, placeholders

Gold:         #8A6520   Primary accent — CTAs, highlights
GoldLight:    #F5ECD4   Gold tinted backgrounds
Green:        #2A6B4F   Positive, success
GreenLight:   #D4ECE3
Red:          #A83226   Expenses, debt, warning
RedLight:     #F5DBD8
Amber:        #A05A10   Investments, neutral
AmberLight:   #FDE8CC
Blue:         #1E4FA0   Info
BlueLight:    #D8E4F7

Display font: Cormorant Garamond (big numbers, headlines)
Body font:    IBM Plex Sans (all UI text)
Mono font:    IBM Plex Mono (ALL currency amounts — no exceptions)

Rules:
  - Positive amounts → Green
  - Negative / expense amounts → Red
  - Investment amounts → Amber
  - Every currency amount uses Mono font
  - Haptic feedback on every financial state change
```

---

## Status Checklist

See `mudra_status.md` for the full build tracker.

---

*Build Plan v2.0 · Mudra by MudraMaster · Flutter Edition · May 2026*
