# Runway Engine v2 — Codex Hand-off

> **Status**: Historical hand-off. The current codebase has moved beyond this spec.
> Runway Engine v3 now uses an as-of-day simulation, a current-month date picker in the sticky header,
> and a gauge arc driven by selected-day balance percent rather than the original projected-month-end ratio.

> **Context**: This document describes the next major dashboard update for Mudra.
> It is a hand-off for implementation. Execute steps in order.
> Run `flutter analyze` after every step. Run `dart run build_runner build` after Step 1.

---

## What We're Building

Four changes in one pass:

| # | Feature | Why |
|---|---|---|
| 1 | **Credits model** | Replace single income field with manual credit entries (salary, refund, interest, cashback) |
| 2 | **Day slider on gauge** | Scrub 1–31 to simulate any day of month; Debits/Commitments split updates live |
| 3 | **Collapsible table** | Four expandable sections: Cash / Credits / Debits / Commitments |
| 4 | **Fix gauge clipping** | `₹79,200` shows as `₹9,200` — hero number overflows the circle |

Also: remove the Pay Day banner, update CLAUDE.md with Isar safety rule.

---

## The Formula (unchanged core, day-parameterised)

```
runway(selectedDay) = bankBalance − ccOutstanding − futureCommitted(selectedDay)

bankBalance       = sum(liquid non-CC account balances)        ← today's reality
ccOutstanding     = sum(CC account balances)                   ← always a commitment
futureCommitted   = sum(outgoings WHERE debitDate > selectedDay AND isActive)

Arc % = (runway / bankBalance × 100).clamp(0, 100)
Colour: >60% → green · 30–60% → amber · <30% → red
```

Credits are **informational only** — bankBalance already reflects received credits.
Credits do not change the runway formula.

---

## Isar Safety Rule (APPLY EVERYWHERE)

Isar v3 bypasses Dart null safety at runtime. Non-nullable `double`/`int`/`String`/`enum`
fields can return `null` for records written by older schema versions.

**Every Isar model MUST have a Safe extension:**
```dart
extension MySafe on MyModel {
  double get safeAmount   => ((amount as dynamic) as double?) ?? 0.0;
  int    get safeDate     => ((date as dynamic) as int?) ?? 0;
  String get safeName     => ((name as dynamic) as String?) ?? '';
  MyEnum get safeCategory => ((category as dynamic) as MyEnum?) ?? MyEnum.fallback;
}
```

**Providers**: use local `safeDouble(dynamic v) => (v as double?) ?? 0.0` helpers in all folds.

**Widgets**: NEVER access `.amount`, `.balance`, `.debitDate` directly on raw Isar objects.
`_TableRow` items are constructed inside `_compute()` with safe accessors; widgets receive plain `double`/`String` primitives only.

---

## Files to Create / Modify

| File | Action |
|---|---|
| `lib/data/models/credit.dart` | CREATE — new Isar model |
| `lib/data/models/account.dart` | MODIFY — add `AccountSafe` extension |
| `lib/data/database.dart` | MODIFY — add `CreditSchema` |
| `lib/providers/credit_provider.dart` | CREATE — stream provider |
| `lib/providers/selected_day_provider.dart` | CREATE — `StateProvider<int>` |
| `lib/providers/dashboard_provider.dart` | MODIFY — watch credits + selectedDay; refactor DashboardData |
| `lib/widgets/fuel_gauge_ring.dart` | MODIFY — fix clipping; add selectedDay label param |
| `lib/screens/dashboard/dashboard_screen.dart` | MODIFY — slider + collapsible table |
| `lib/data/seed_data.dart` | MODIFY — add 2 Credit entries |
| `CLAUDE.md` | MODIFY — add Isar Data Safety section |

---

## Step 1 — New Credit model

**Create `lib/data/models/credit.dart`:**
```dart
import 'package:isar/isar.dart';

part 'credit.g.dart';

@collection
class Credit {
  Id id = Isar.autoIncrement;

  late String uid;
  late String name;

  @enumerated
  late CreditCategory category;

  double amount = 0.0;
  int creditDate = 1;   // day of month this credit arrives
  bool isActive = true;
  late DateTime createdAt;
}

enum CreditCategory { salary, interest, refund, cashback, dividend, other }

extension CreditSafe on Credit {
  double get safeAmount       => ((amount as dynamic) as double?) ?? 0.0;
  int    get safeCreditDate   => ((creditDate as dynamic) as int?) ?? 0;
  String get safeName         => ((name as dynamic) as String?) ?? '';
  CreditCategory get safeCategory =>
      ((category as dynamic) as CreditCategory?) ?? CreditCategory.other;
}
```

**Add `AccountSafe` to `lib/data/models/account.dart`:**
```dart
extension AccountSafe on Account {
  double get safeBalance  => ((balance as dynamic) as double?) ?? 0.0;
  double get safeFdAmount => ((fdAmount as dynamic) as double?) ?? 0.0;
  String get safeNickname => ((nickname as dynamic) as String?) ?? '';
  String get safeBankName => ((bankName as dynamic) as String?) ?? '';
}
```

**Register in `lib/data/database.dart`** — add `CreditSchema` to the Isar schemas list.

**Then run:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Step 2 — New providers

**Create `lib/providers/selected_day_provider.dart`:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Drives the day-slider simulation. Defaults to today's day of month.
final selectedDayProvider = StateProvider<int>(
  (ref) => DateTime.now().day,
);
```

**Create `lib/providers/credit_provider.dart`:**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/database.dart';
import '../data/models/credit.dart';

part 'credit_provider.g.dart';

@riverpod
Stream<List<Credit>> creditsStream(CreditsStreamRef ref) {
  final isar = ref.watch(isarProvider);
  return isar.credits.where().watch(fireImmediately: true);
}
```

Run `build_runner` again after creating this file.

---

## Step 3 — Refactor DashboardData

Replace the current `DashboardData` class and `_compute()` in `lib/providers/dashboard_provider.dart`.

### New DashboardData fields

```dart
// ─── Formula components ────────────────────────────────────────────────────
final double bankBalance;           // liquid non-CC account balances (today)
final double ccOutstanding;         // CC account balances
final double futureCommitted;       // outgoings debitDate > selectedDay
final double monthRunway;           // bankBalance − ccOutstanding − futureCommitted
final double runwayPercent;         // (monthRunway / bankBalance * 100).clamp(0,100)
final int selectedDay;              // from selectedDayProvider

// ─── Credits ──────────────────────────────────────────────────────────────
final double creditsTotal;          // sum(received credits)
final List<_CreditRow> receivedCredits;  // creditDate <= selectedDay
final List<_CreditRow> pendingCredits;   // creditDate > selectedDay (shown greyed)

// ─── Debits (fired as of selectedDay) ─────────────────────────────────────
final double alreadyFired;
final List<_CategoryGroup> firedGroups;  // grouped by OutgoingCategory

// ─── Commitments (after selectedDay) ──────────────────────────────────────
final List<_OutgoingRow> futureRows;     // debitDate > selectedDay (sorted)

// ─── Cash in Accounts ──────────────────────────────────────────────────────
final List<_AccountRow> liquidRows;      // liquid non-CC accounts

// ─── Overall tab ──────────────────────────────────────────────────────────
final double fdTotal;
final double investmentsTotal;
final double netWorth;
final double totalAssets;
final double totalLiabilities;
final int fixedItemsCount;
final int accountsCount;
final String currency;

// ─── Computed ─────────────────────────────────────────────────────────────
RunwayState get gaugeState { ... }   // retained as percent-derived context
Color get gaugeColor { ... }         // monthRunway > 0 green, == 0 grey, < 0 red
bool get isOvercommitted => monthRunway < 0;
```

### Row types (simple value objects — NOT Isar objects)

```dart
class _AccountRow {
  final String nickname;
  final double balance;
}

class _CreditRow {
  final String name;
  final CreditCategory category;
  final double amount;
  final bool isPending;
}

class _CategoryGroup {
  final OutgoingCategory category;
  final double total;
  final List<_OutgoingRow> items;
}

class _OutgoingRow {
  final String name;
  final double amount;
  final OutgoingType type;     // expense or investment (drives color: red vs amber)
  final int debitDate;
}
```

### `_compute()` core logic

```dart
DashboardData _compute(...) {
  final today = DateTime.now().day;

  double safeDouble(dynamic v) => (v as double?) ?? 0.0;
  int    safeInt(dynamic v)    => (v as int?) ?? 0;

  final selectedDay = ref.watch(selectedDayProvider);

  // ── Bank balance ─────────────────────────────────────────────────────
  final liquidAccounts = accounts.where((a) =>
      a.accountType == AccountType.personal &&
      !a.isCreditCard &&
      a.includeInLiquid);
  final bankBalance = liquidAccounts.fold(0.0, (s, a) => s + a.safeBalance);
  final liquidRows  = liquidAccounts.map((a) =>
      _AccountRow(nickname: a.safeNickname, balance: a.safeBalance)).toList();

  // ── CC ───────────────────────────────────────────────────────────────
  final ccOutstanding = accounts
      .where((a) => a.isCreditCard)
      .fold(0.0, (s, a) => s + a.safeBalance);

  // ── Credits ──────────────────────────────────────────────────────────
  final receivedCredits = credits
      .where((c) => c.isActive && c.safeCreditDate <= selectedDay)
      .map((c) => _CreditRow(name: c.safeName, category: c.safeCategory,
                             amount: c.safeAmount, isPending: false))
      .toList();
  final pendingCredits = credits
      .where((c) => c.isActive && c.safeCreditDate > selectedDay)
      .map((c) => _CreditRow(name: c.safeName, category: c.safeCategory,
                             amount: c.safeAmount, isPending: true))
      .toList();
  final creditsTotal = receivedCredits.fold(0.0, (s, c) => s + c.amount);

  // ── Outgoings split ──────────────────────────────────────────────────
  final firedOutgoings = outgoings
      .where((o) => o.isActive && o.safeDebitDate <= selectedDay).toList();
  final futureOutgoings = outgoings
      .where((o) => o.isActive && o.safeDebitDate > selectedDay)
      .toList()
      ..sort((a, b) => a.safeDebitDate.compareTo(b.safeDebitDate));

  final alreadyFired    = firedOutgoings.fold(0.0, (s, o) => s + o.safeAmount);
  final futureCommitted = futureOutgoings.fold(0.0, (s, o) => s + o.safeAmount);

  // Group fired by category
  final groupMap = <OutgoingCategory, List<_OutgoingRow>>{};
  for (final o in firedOutgoings) {
    groupMap.putIfAbsent(o.safeCategory, () => []).add(_OutgoingRow(
      name: o.safeName, amount: o.safeAmount,
      type: o.safeType, debitDate: o.safeDebitDate,
    ));
  }
  final firedGroups = groupMap.entries.map((e) => _CategoryGroup(
    category: e.key,
    total: e.value.fold(0.0, (s, r) => s + r.amount),
    items: e.value,
  )).toList();

  final futureRows = futureOutgoings.map((o) => _OutgoingRow(
    name: o.safeName, amount: o.safeAmount,
    type: o.safeType, debitDate: o.safeDebitDate,
  )).toList();

  // ── Core formula ─────────────────────────────────────────────────────
  final monthRunway    = bankBalance - ccOutstanding - futureCommitted;
  final runwayPercent  = bankBalance > 0
      ? (monthRunway / bankBalance * 100).clamp(0.0, 100.0)
      : 0.0;

  // ... net worth, investments, fdTotal same as before ...

  return DashboardData(
    bankBalance: bankBalance,
    ccOutstanding: ccOutstanding,
    futureCommitted: futureCommitted,
    monthRunway: monthRunway,
    runwayPercent: runwayPercent,
    selectedDay: selectedDay,
    creditsTotal: creditsTotal,
    receivedCredits: receivedCredits,
    pendingCredits: pendingCredits,
    alreadyFired: alreadyFired,
    firedGroups: firedGroups,
    futureRows: futureRows,
    liquidRows: liquidRows,
    // ... rest of fields
  );
}
```

---

## Step 4 — FuelGaugeRing: fix clipping + add selectedDay label

**In `FuelGaugeRing`**, add `final int selectedDay` param.

**Fix clipping** — wrap hero amount in a constrained FittedBox:
```dart
SizedBox(
  width: widget.size * 0.62,
  child: FittedBox(
    fit: BoxFit.scaleDown,
    child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: widget.runway),
      duration: const Duration(milliseconds: 600),
      builder: (_, v, __) => AmountDisplay(
        amount: v, currency: widget.currency,
        style: AppTypography.monoHero.copyWith(color: widget.arcColor),
      ),
    ),
  ),
)
```

**Add selected day indicator** below the "available this month" label:
```dart
Text(
  widget.selectedDay == DateTime.now().day
      ? 'today · day ${widget.selectedDay}'
      : 'day ${widget.selectedDay}',
  style: AppTypography.monoXSmall.copyWith(color: AppColors.inkDim),
)
```

---

## Step 5 — Dashboard screen redesign

`_ThisMonthTab` must become a **`ConsumerStatefulWidget`** (needs `ref` for the slider).

**Remove**: Pay Day banner entirely.
**Remove**: MONTH CONTEXT card (alreadyFired now in Debits section; income now in Credits section).

**Add day slider** between the gauge section and LIQUID|AFTER DEBITS:
```dart
// Header row
Padding(
  padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
  child: Row(
    children: [
      SectionLabel('simulate day'),
      const Spacer(),
      Text('Day $selectedDay', style: monoSmall, gold),
      if (selectedDay != DateTime.now().day)
        TextButton(
          onPressed: () => ref.read(selectedDayProvider.notifier).state = DateTime.now().day,
          child: Text('Reset', style: labelSmall, gold),
        ),
    ],
  ),
)
// Slider
Slider(
  value: selectedDay.toDouble(),
  min: 1, max: 31, divisions: 30,
  activeColor: dashboard.gaugeColor,
  inactiveColor: AppColors.border,
  onChanged: (v) => ref.read(selectedDayProvider.notifier).state = v.round(),
)
```

**Replace the flat "THIS MONTH" card + "MONTH CONTEXT" card** with `_RunwayTable`:

```dart
_RunwayTable(dashboard: dashboard)
```

### `_RunwayTable` layout

```
Container (white, border, radius 10)
  _TableSection — Cash in Accounts   (ink, no prefix)
  Divider
  _TableSection — Credits             (green, '+ ')
  Divider
  _TableSection — Debits              (inkDim, '− ', grouped by category)
  Divider
  _TableSection — Commitments         (red, '− ', CC first then future outgoings)
  Divider
  Result row — Projected Month End    (gaugeColor, bold)
```

### `_TableSection` widget

```dart
class _TableSection extends StatefulWidget {
  final String title;
  final String? subtitle;    // e.g. "as of Day 15"
  final double total;
  final String prefix;       // '' / '+ ' / '− '
  final Color totalColor;
  final Widget Function() bodyBuilder;  // builds the expanded rows
}
```

Each section: tappable header row → `AnimatedSize` wrapping body.

**Cash in Accounts body**: one row per `dashboard.liquidRows` (nickname + balance).

**Credits body**: received credits in green; pending credits in `AppColors.inkDim` with italic style + "(Day N)" suffix. Show `pendingCredits` even when collapsed count (in the subtitle: "2 received · 1 upcoming").

**Debits body**: grouped by `firedGroups`. Each group: `SectionLabel(category.name)` + indented items. Item color: `AppColors.inkDim` (already gone).

**Commitments body**:
- CC outstanding row first (red, bold)
- Then each `futureRow` (red for expense, amber for investment, "Debits on Nth" subtitle)

**Result row** (not a `_TableSection`, just a raw container):
```dart
Container(
  decoration: BoxDecoration(
    color: dashboard.isOvercommitted ? Color(0xFFF5DBD8) : Color(0xFFF5ECD4),
    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
  ),
  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('Month runway', style: bodyMedium.w600),
      AmountDisplay(dashboard.monthRunway, currency, monoMedium.w600, color: gaugeColor),
    ],
  ),
)
```

---

## Step 6 — Seed data

In `lib/data/seed_data.dart` inside the existing `isar.writeTxn()`:

```dart
final salary = Credit()
  ..uid = _uuid.v4()
  ..name = 'Salary — Employer'
  ..category = CreditCategory.salary
  ..amount = 120000
  ..creditDate = 1
  ..isActive = true
  ..createdAt = DateTime.now();

final interest = Credit()
  ..uid = _uuid.v4()
  ..name = 'HDFC Savings Interest'
  ..category = CreditCategory.interest
  ..amount = 412
  ..creditDate = 10
  ..isActive = true
  ..createdAt = DateTime.now();

await isar.credits.putAll([salary, interest]);
```

---

## Step 7 — CLAUDE.md update

Add this section to `CLAUDE.md` (before "Conventions to Avoid"):

```markdown
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

2. **Providers**: use local `safeDouble`/`safeInt` helpers in all `_compute()` folds.

3. **Widgets**: NEVER read `.amount`, `.balance`, `.debitDate`, or any primitive
   field directly on an Isar object. Always use the safe extension getters.
   Widgets must receive pre-typed `double`/`String` primitives — never raw Isar objects.
```

---

## Verification Checklist

```
□ dart run build_runner build --delete-conflicting-outputs   → no errors
□ flutter analyze                                            → 0 issues
□ Uninstall app from simulator → flutter run                 → seed data loads
□ Gauge: ₹79,200 shows fully without clipping
□ Slider: drag 1→31 → Debits/Commitments totals update live
□ Credits section expands: Salary ₹1,20,000 + Interest ₹412 in green
□ Pending credits (creditDate > selectedDay) appear greyed/italic
□ Debits section expands with category groups (Loans, Insurance, Subscriptions)
□ Commitments section: CC outstanding + future outgoings
□ Projected month-end value coloured with gaugeColor
□ No Pay Day banner visible
□ Overall tab, quick stats tiles, Next 7 Days radar unchanged
□ flutter analyze after all changes                          → 0 issues
```
