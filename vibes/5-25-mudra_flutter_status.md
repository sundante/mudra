# Mudra Flutter — Build Status
**Local-first MVP · No Backend · No Auth · Flutter**

> `[ ]` Not Started · `[~]` In Progress · `[x]` Complete · `[!]` Blocked

Last Updated: May 2026

---

## Phase 0 — Scaffold & Simulator Run

- [ ] Flutter SDK installed and `flutter doctor` passes cleanly
- [ ] iOS Simulator available (Xcode installed)
- [ ] Android Emulator available (Android Studio + AVD configured)
- [ ] Flutter project created: `flutter create mudra`
- [ ] Project opens without errors in VS Code / Android Studio
- [ ] `flutter run` on iOS simulator — default counter app visible
- [ ] `flutter run` on Android emulator — default counter app visible
- [ ] `pubspec.yaml` updated with all dependencies (see build prompt)
- [ ] `flutter pub get` runs without errors
- [ ] Folder structure created (lib/core, lib/data, lib/screens, lib/widgets etc.)
- [ ] `main.dart` cleaned up (counter app removed)
- [ ] App launches on both simulators showing blank screen (no errors)

---

## Phase 1 — Design System

- [ ] `lib/core/theme/colors.dart` — all colour constants defined
- [ ] `lib/core/theme/typography.dart` — all TextStyle definitions
- [ ] `lib/core/theme/app_theme.dart` — ThemeData with warm light theme
- [ ] `lib/core/constants/spacing.dart` — spacing scale
- [ ] `lib/core/utils/currency_formatter.dart` — INR lakh/crore + international
- [ ] `lib/core/utils/date_utils.dart` — days until debit, month boundaries
- [ ] Google Fonts loading verified (Cormorant Garamond, IBM Plex Sans, IBM Plex Mono)
- [ ] Theme applied to `MaterialApp` — cream background visible on all screens

---

## Phase 2 — Navigation Shell

- [ ] `go_router` configured in `app.dart`
- [ ] Bottom navigation bar with 5 tabs (Home, Accounts, Outgoings, Portfolio, Settings)
- [ ] Gold accent on active tab
- [ ] Each tab shows a placeholder screen with the tab name
- [ ] Navigation between all tabs works on both simulators
- [ ] App bar with "Mudra" wordmark (Cormorant Garamond, gold)

---

## Phase 3 — Data Layer (Isar + Riverpod)

### Isar Models
- [ ] `Account` model with Isar annotations
- [ ] `Outgoing` model with Isar annotations
- [ ] `InvestmentPlatform` model with Isar annotations
- [ ] `Debt` model with Isar annotations
- [ ] `AppSettings` model with Isar annotations
- [ ] `lib/data/database.dart` — Isar initialisation
- [ ] Isar opens successfully on iOS simulator
- [ ] Isar opens successfully on Android emulator

### Repositories
- [ ] `AccountRepository` — CRUD operations
- [ ] `OutgoingRepository` — CRUD operations
- [ ] `InvestmentRepository` — CRUD operations
- [ ] `SettingsRepository` — read/write settings

### Riverpod Providers
- [ ] `accountsProvider` — stream of all accounts
- [ ] `outgoingsProvider` — stream of all outgoings
- [ ] `investmentsProvider` — stream of all investment platforms
- [ ] `debtsProvider` — stream of all debts
- [ ] `settingsProvider` — current app settings
- [ ] `dashboardProvider` — computed: liquidTotal, balanceForMonth, netWorth, debitRadar
- [ ] Sample data seeds correctly and persists across app restarts

---

## Phase 4 — Dashboard Screen

- [ ] `FuelGaugeRing` widget built (CustomPainter SVG ring)
  - [ ] Ring animates from 0 to current percentage on mount
  - [ ] Colour changes: green (>50%) → amber (20-50%) → red (<20%)
  - [ ] Centre amount display (Cormorant Garamond, large)
  - [ ] "available this month" label below amount
- [ ] Liquid total displayed below ring
- [ ] Fixed committed displayed below liquid total
- [ ] Net worth figure (tappable → Portfolio)
- [ ] 7-day debit radar list
  - [ ] `DebitRadarItem` widget
  - [ ] "Today" / "Tomorrow" / "in X days" labels
  - [ ] Red for expenses, amber for investments
  - [ ] Urgent items (≤2 days) shown with red badge
  - [ ] Empty state: "No debits in the next 7 days ✓"
- [ ] Quick account tiles (horizontal scroll)
- [ ] Pull-to-refresh (re-computes dashboard values)
- [ ] Loading skeleton while data loads

---

## Phase 5 — Accounts Screen

- [ ] Accounts grouped by type: Personal / Joint / Business
- [ ] `AccountTile` widget (nickname, bank, balance, updated-at)
- [ ] CC accounts shown with red balance and "CC" badge
- [ ] Liquid Total + Total FD header
- [ ] Segment switcher (Personal / Joint / Business)
- [ ] FAB (+) opens Add Account bottom sheet
- [ ] **Add Account Sheet:**
  - [ ] Nickname input
  - [ ] Bank name input (with quick-add chips: SBI, HDFC, ICICI, Axis, Jupiter)
  - [ ] Balance input (numeric, formatted)
  - [ ] Account type picker (Personal / Joint / Business)
  - [ ] Is Credit Card toggle
  - [ ] FD Amount input (conditional, hides if CC)
  - [ ] Include in Liquid toggle
  - [ ] Save button → persists to Isar
- [ ] Tap account tile → Edit Account sheet (same form, pre-filled)
- [ ] Tap balance in tile → Quick Balance Update sheet (large numeric input)
- [ ] Swipe-to-delete with confirmation
- [ ] Empty state per segment

---

## Phase 6 — Outgoings Screen

- [ ] Tab switcher: Expenses | Investments
- [ ] Upcoming debits strip at top (next 7 days, horizontal scroll chips)
- [ ] `OutgoingRow` widget (coloured left bar, name, date, amount)
- [ ] Items sorted by debit date ascending
- [ ] Monthly total footer for each tab
- [ ] FAB (+) opens Add Expense or Add Investment sheet (based on active tab)
- [ ] **Add Expense Sheet:**
  - [ ] Name input with smart suggestion chips (Home Loan EMI, Insurance, Subscriptions)
  - [ ] Amount input (numeric)
  - [ ] Debit date picker (1–31 horizontal scroll)
  - [ ] Category picker chips
  - [ ] Save button
- [ ] **Add Investment Sheet:**
  - [ ] Same structure, amber theme
  - [ ] Categories: SIP, PPF, NPS, EPF, Stocks, Other
- [ ] Tap row → Edit sheet (same form, pre-filled)
- [ ] Swipe-to-delete with confirmation
- [ ] Empty state for each tab with instructions

---

## Phase 7 — Portfolio Screen

- [ ] Net Worth hero (Cormorant Garamond 600, gold if positive, red if negative)
- [ ] Total Assets and Total Liabilities row below hero
- [ ] Tap hero → Net Worth breakdown bottom sheet
- [ ] **Net Worth Breakdown Sheet:**
  - [ ] Assets: Liquid + FDs + Investments listed
  - [ ] Liabilities: CC Outstanding + Debts listed
  - [ ] Formula shown: "₹X Assets − ₹X Liabilities = ₹X"
- [ ] Investment Platforms section
  - [ ] `PlatformCard` widget (name, asset type, invested, current value, P&L chip)
  - [ ] P&L chip: green if positive, red if negative
  - [ ] FAB → Add Platform sheet
  - [ ] **Add Platform Sheet:**
    - [ ] Platform name input
    - [ ] Asset type picker
    - [ ] Invested amount
    - [ ] Current value
    - [ ] Live P&L preview as user types
    - [ ] Save button
  - [ ] Tap card → Edit sheet
  - [ ] Swipe-to-delete
- [ ] Personal Debts section
  - [ ] Subsections: "I Owe" | "Owed to Me"
  - [ ] Each debt: name, amount, due date (if set)
  - [ ] "Mark Settled" swipe action
  - [ ] Add Debt button (inline, not FAB)
  - [ ] **Add Debt Sheet:**
    - [ ] Direction toggle (I Owe / They Owe Me)
    - [ ] Person name, amount, due date (optional), notes
- [ ] Empty states for both sections

---

## Phase 8 — Settings Screen

- [ ] **Monthly Income**
  - [ ] Large amount input (formatted)
  - [ ] Currency symbol prefix
  - [ ] Updates `AppSettings.monthlyIncome` in Isar
- [ ] **Pay Date**
  - [ ] 1–31 horizontal scroll picker
  - [ ] Updates `AppSettings.payDate`
- [ ] **Currency**
  - [ ] Currency picker chips: INR 🇮🇳 USD 🇺🇸 GBP 🇬🇧 AED 🇦🇪 SGD 🇸🇬 AUD 🇦🇺 EUR 🇪🇺
  - [ ] Changing currency reformats all amounts app-wide
- [ ] **Data Management**
  - [ ] "Clear all data" button with double-confirmation dialog
- [ ] App version displayed at bottom (IBM Plex Mono, ink-dim)

---

## Phase 9 — Polish & Edge Cases

- [ ] Haptic feedback on all save/delete actions
- [ ] All amounts formatted correctly: INR in lakh/crore (₹ 1,50,000 not ₹ 150,000)
- [ ] Fuel gauge animation smooth (no jank on both simulators)
- [ ] Empty app (fresh install) shows instructional empty states everywhere
- [ ] All bottom sheets scroll correctly when keyboard appears
- [ ] Back button / swipe-to-dismiss works on all sheets
- [ ] Numbers never overflow their containers (test with large amounts)
- [ ] Orientation locked to portrait
- [ ] App icon set (cream background, gold "M" or mudra symbol)
- [ ] Splash screen (cream background, Mudra wordmark)
- [ ] Dark text readable on all cream backgrounds (contrast ratio check)
- [ ] Tested on iOS 16+ simulator (iPhone 15 Pro size)
- [ ] Tested on Android 12+ emulator (Pixel size)
- [ ] No debug banner visible
- [ ] No console errors or warnings in release mode

---

## Progress Summary

| Phase | Items | Done | Remaining |
|---|---|---|---|
| 0 — Scaffold | 11 | 0 | 11 |
| 1 — Design System | 8 | 0 | 8 |
| 2 — Navigation | 6 | 0 | 6 |
| 3 — Data Layer | 16 | 0 | 16 |
| 4 — Dashboard | 14 | 0 | 14 |
| 5 — Accounts | 14 | 0 | 14 |
| 6 — Outgoings | 14 | 0 | 14 |
| 7 — Portfolio | 18 | 0 | 18 |
| 8 — Settings | 8 | 0 | 8 |
| 9 — Polish | 14 | 0 | 14 |
| **TOTAL** | **123** | **0** | **123** |

---

*Status v2.0 · Mudra Flutter MVP · May 2026*
*Update at end of every build session. Commit to git after each phase.*
