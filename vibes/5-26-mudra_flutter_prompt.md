# Mudra — Flutter Build Prompt
**Claude Code · Phase-by-Phase · Local-first · No Backend · No Auth**

> **How to use:**
> Paste the MASTER CONTEXT at the start of every Claude Code session.
> Then paste ONE phase at a time. Complete and test before moving on.
> Never paste multiple phases together.

---

## MASTER CONTEXT
*(Paste this at the start of every new Claude Code session)*

```
You are building Mudra — a Flutter mobile finance app for iOS and Android.

PRODUCT CONTEXT:
  Mudra is a personal finance dashboard app. It gives the user a single
  screen showing their complete financial picture: how much they can
  spend this month, what debits are coming, and their net worth.
  
  This version is LOCAL ONLY — no backend, no auth, no internet.
  All data is stored on-device using Isar (NoSQL local database).

  Core feature — "BalanceForTheMonth":
    = (sum of all personal liquid account balances)
      minus (sum of all fixed monthly outgoings that haven't debited yet)
    This is the "fuel gauge" — the most important number in the app.

TECH STACK:
  Framework:  Flutter (latest stable channel)
  Language:   Dart
  State:      Riverpod 2.x (flutter_riverpod)
  Storage:    Isar 3.x (local NoSQL)
  Navigation: GoRouter
  Fonts:      google_fonts (Cormorant Garamond, IBM Plex Sans, IBM Plex Mono)
  Numbers:    intl package
  Animation:  flutter_animate

DESIGN SYSTEM:
  Theme: Warm light. Clean. Premium without being cold.

  COLOURS (define as static const in AppColors class):
    background:   Color(0xFFFAF8F4)   warm off-white, page base
    surface:      Color(0xFFFFFFFF)   cards, sheets
    surface2:     Color(0xFFF2EFE9)   alternate sections
    border:       Color(0xFFE4E0D8)   dividers
    border2:      Color(0xFFD4CFC6)   stronger borders
    ink:          Color(0xFF1C1814)   primary text
    inkMid:       Color(0xFF4A443C)   body copy
    inkDim:       Color(0xFF8A8278)   labels, hints
    gold:         Color(0xFF8A6520)   PRIMARY accent, CTAs
    goldLight:    Color(0xFFF5ECD4)   gold bg tint
    goldBorder:   Color(0xFFC9A55A)   gold borders
    green:        Color(0xFF2A6B4F)   positive states
    greenLight:   Color(0xFFD4ECE3)
    red:          Color(0xFFA83226)   expenses, debt, warning
    redLight:     Color(0xFFF5DBD8)
    amber:        Color(0xFFA05A10)   investments, neutral
    amberLight:   Color(0xFFFDE8CC)
    blue:         Color(0xFF1E4FA0)   info
    blueLight:    Color(0xFFD8E4F7)

  TYPOGRAPHY:
    displayFont:  'Cormorant Garamond'  — hero numbers, headings
    bodyFont:     'IBM Plex Sans'       — all UI text
    monoFont:     'IBM Plex Mono'       — ALL currency amounts (no exceptions)

  SPACING: base unit 8dp
    xs:4, sm:8, md:16, lg:24, xl:32, xxl:48, xxxl:64

  KEY RULES:
    1. Every currency amount displayed in IBM Plex Mono font
    2. Positive amounts → green. Negative → red. Investments → amber.
    3. Haptic feedback on every financial action (HapticFeedback.lightImpact)
    4. Bottom sheets for all forms (not full-screen routes)
    5. Warm cream background (#FAF8F4) everywhere — never pure white as bg
    6. Skeleton shimmer while data loads, never spinners on content

APP STRUCTURE:
  lib/
  ├── main.dart
  ├── app.dart                     ← MaterialApp + GoRouter + ProviderScope
  ├── core/
  │   ├── theme/
  │   │   ├── app_colors.dart
  │   │   ├── app_typography.dart
  │   │   └── app_theme.dart
  │   ├── constants/spacing.dart
  │   └── utils/
  │       ├── currency_formatter.dart
  │       └── date_helpers.dart
  ├── data/
  │   ├── models/               ← Isar schemas
  │   │   ├── account.dart
  │   │   ├── outgoing.dart
  │   │   ├── investment_platform.dart
  │   │   ├── debt.dart
  │   │   └── app_settings.dart
  │   ├── repositories/
  │   └── database.dart
  ├── providers/
  │   ├── account_provider.dart
  │   ├── outgoing_provider.dart
  │   ├── investment_provider.dart
  │   ├── settings_provider.dart
  │   └── dashboard_provider.dart
  ├── screens/
  │   ├── dashboard/dashboard_screen.dart
  │   ├── accounts/accounts_screen.dart
  │   ├── outgoings/outgoings_screen.dart
  │   ├── portfolio/portfolio_screen.dart
  │   └── settings/settings_screen.dart
  └── widgets/
      ├── common/
      │   ├── mudra_button.dart
      │   ├── mudra_input.dart
      │   ├── mudra_card.dart
      │   ├── amount_display.dart
      │   ├── section_label.dart
      │   └── empty_state.dart
      ├── fuel_gauge_ring.dart
      ├── account_tile.dart
      ├── outgoing_row.dart
      ├── debit_radar_item.dart
      └── platform_card.dart

DATA MODELS (key computed values):
  liquidTotal = SUM(account.balance)
    WHERE account.includeInLiquid == true
    AND account.isCreditCard == false
    AND account.accountType == 'personal'

  fixedCommitted = SUM(outgoing.amount)
    WHERE outgoing.debitDate >= DateTime.now().day
    AND outgoing.isActive == true

  balanceForMonth = liquidTotal - fixedCommitted
  balancePercent  = (balanceForMonth / liquidTotal * 100).clamp(0, 100)

  totalAssets     = liquidTotal + fdTotal + SUM(platform.currentValue)
  totalLiabilities = SUM(cc.balance WHERE isCreditCard)
                   + SUM(debt.amount WHERE direction == 'i_owe' AND !settled)
  netWorth        = totalAssets - totalLiabilities

  debitRadar = outgoings
    WHERE daysUntilDebit(debitDate) <= 7
    sorted by daysUntil ascending
```

---

## PHASE 0 — Scaffold & Simulator Test
*(Goal: Flutter app running on BOTH iOS simulator and Android emulator)*

```
STEP 1 — Create the Flutter project:
  Run: flutter create mudra --org com.mudramaster --platforms ios,android
  cd mudra
  Verify: flutter doctor passes (no critical errors)

STEP 2 — Update pubspec.yaml with all dependencies.
  Replace the entire pubspec.yaml with:

name: mudra
description: Your money. Clear, every morning.
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Local database
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.3

  # Navigation
  go_router: ^14.2.2

  # Fonts
  google_fonts: ^6.2.1

  # Number formatting
  intl: ^0.19.0

  # Animations
  flutter_animate: ^4.5.0

  # Utils
  uuid: ^4.4.0
  collection: ^1.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  isar_generator: ^3.1.0+1
  riverpod_generator: ^2.4.3
  build_runner: ^2.4.11
  custom_lint: ^0.6.7
  riverpod_lint: ^2.3.13

flutter:
  uses-material-design: true

STEP 3 — Run: flutter pub get
  Verify no errors.

STEP 4 — Create the folder structure.
  Create all directories as defined in the app structure above.
  Create a placeholder .dart file in each folder with just a comment:
  // TODO: implement [folder name]

STEP 5 — Replace lib/main.dart with:

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MudraApp(),
    ),
  );
}

class MudraApp extends StatelessWidget {
  const MudraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mudra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAF8F4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8A6520),
          background: const Color(0xFFFAF8F4),
        ),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Mudra',
            style: TextStyle(
              fontSize: 32,
              color: Color(0xFF8A6520),
            ),
          ),
        ),
      ),
    );
  }
}

STEP 6 — Run on iOS simulator:
  Open iOS simulator first (run: open -a Simulator)
  Then: flutter run -d [ios-device-id]
  Or:   flutter run (select the iOS simulator when prompted)
  
  Expected result: Cream background, "Mudra" text in gold, centred.
  NO errors in console.

STEP 7 — Run on Android emulator:
  Start Android emulator from Android Studio AVD Manager first.
  Then: flutter run -d [android-device-id]
  Or:   flutter run (select Android emulator when prompted)
  
  Expected result: Same as iOS. No errors.

STEP 8 — Run on BOTH simultaneously:
  flutter run -d all
  Both devices should show the same screen.

DO NOT PROCEED until both simulators show the app with zero errors.
```

---

## PHASE 1 — Design System

```
Build the complete design system. No screens yet — just the foundation.

FILE 1: lib/core/theme/app_colors.dart
  Create class AppColors with all static const Color values
  from the master context. Group them with comments:
  // Background & Surface
  // Text
  // Brand Gold
  // Semantic: Positive
  // Semantic: Negative  
  // Semantic: Investment
  // Semantic: Info

FILE 2: lib/core/theme/app_typography.dart
  Create class AppTypography.
  
  Use GoogleFonts for all text styles.
  Define these static methods/getters:
  
  // Display (Cormorant Garamond) — for hero numbers and headings
  static TextStyle displayLarge   → CormorantGaramond, 600, 64px
  static TextStyle displayMedium  → CormorantGaramond, 600, 48px
  static TextStyle displaySmall   → CormorantGaramond, 600, 36px
  static TextStyle headingLarge   → CormorantGaramond, 600, 28px
  static TextStyle headingMedium  → CormorantGaramond, 600, 22px
  static TextStyle headingSmall   → CormorantGaramond, 600, 18px
  static TextStyle displayItalic  → CormorantGaramond, 400 italic, 22px

  // Body (IBM Plex Sans) — for all UI text
  static TextStyle bodyLarge      → IBMPlexSans, 400, 16px, height 1.65
  static TextStyle bodyMedium     → IBMPlexSans, 400, 14px, height 1.65
  static TextStyle bodySmall      → IBMPlexSans, 400, 12px
  static TextStyle labelLarge     → IBMPlexSans, 600, 14px
  static TextStyle labelMedium    → IBMPlexSans, 500, 13px
  static TextStyle labelSmall     → IBMPlexSans, 500, 11px

  // Mono (IBM Plex Mono) — for ALL currency amounts
  static TextStyle monoHero       → IBMPlexMono, 600, 48px
  static TextStyle monoLarge      → IBMPlexMono, 600, 28px
  static TextStyle monoMedium     → IBMPlexMono, 500, 16px
  static TextStyle monoSmall      → IBMPlexMono, 400, 13px
  static TextStyle monoXSmall     → IBMPlexMono, 400, 10px (ALL CAPS via letterSpacing)
  
  // Section labels (IBM Plex Mono, uppercase, tracked)
  static TextStyle sectionLabel   → IBMPlexMono, 400, 9.5px, 
                                     letterSpacing: 1.8, colour inkDim

FILE 3: lib/core/theme/app_theme.dart
  Create ThemeData for Mudra:
  
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.light(
      primary: AppColors.gold,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      background: AppColors.background,
      outline: AppColors.border,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.border,
      centerTitle: false,
      titleTextStyle: AppTypography.headingMedium.copyWith(
        color: AppColors.gold,
      ),
      iconTheme: IconThemeData(color: AppColors.ink),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.inkDim,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.border),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: AppColors.gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: AppColors.red),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: AppTypography.labelLarge,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );

FILE 4: lib/core/constants/spacing.dart
  class AppSpacing {
    static const double xs = 4;
    static const double sm = 8;
    static const double md = 16;
    static const double lg = 24;
    static const double xl = 32;
    static const double xxl = 48;
    static const double screenH = 20.0;  // horizontal screen padding
    static const double screenV = 24.0;  // vertical screen padding
  }
  class AppRadius {
    static const double sm = 6;
    static const double md = 10;
    static const double lg = 14;
    static const double xl = 20;
    static const double full = 999;
  }

FILE 5: lib/core/utils/currency_formatter.dart
  class CurrencyFormatter {
    
    // Format to display: ₹ 1,50,000 (INR) or $ 10,000.00 (others)
    static String format(double amount, String currency) {
      switch (currency) {
        case 'INR':
          return '₹ ' + _formatIndian(amount);
        case 'USD': return '\$ ' + _formatStandard(amount);
        case 'GBP': return '£ ' + _formatStandard(amount);
        case 'AED': return 'AED ' + _formatStandard(amount);
        case 'SGD': return 'S\$ ' + _formatStandard(amount);
        case 'AUD': return 'A\$ ' + _formatStandard(amount);
        case 'EUR': return '€ ' + _formatStandard(amount);
        default: return amount.toStringAsFixed(2);
      }
    }
    
    // Compact: ₹ 1.5L, ₹ 2.3Cr, $ 1.5K, $ 2.3M
    static String compact(double amount, String currency) { ... }
    
    // Symbol only
    static String symbol(String currency) { ... }
    
    // Indian number format: 1,50,000 (lakhs/crores)
    static String _formatIndian(double amount) { ... }
    
    // International: 10,000.00
    static String _formatStandard(double amount) { ... }
  }

FILE 6: lib/core/utils/date_helpers.dart
  class DateHelpers {
    // How many days until day X of next/current month debits?
    static int daysUntilDebit(int debitDay) { ... }
    
    // Get the actual next debit date for a given day-of-month
    static DateTime nextDebitDate(int debitDay) { ... }
    
    // "Today", "Tomorrow", "in 3 days", "in 7 days"
    static String debitLabel(int daysUntil) { ... }
    
    // Is a debit urgent (≤ 2 days away)?
    static bool isUrgent(int daysUntil) => daysUntil <= 2;
    
    // Days remaining in current month
    static int daysRemainingInMonth() { ... }
  }

After creating all files:
  Update app.dart to use AppTheme.lightTheme.
  Run flutter run on both simulators.
  App should look identical — cream background, gold app bar text.
```

---

## PHASE 2 — Navigation Shell

```
Build the bottom navigation shell with 5 placeholder screens.

FILE 1: lib/app.dart — Replace with full app using GoRouter:

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/accounts/accounts_screen.dart';
import 'screens/outgoings/outgoings_screen.dart';
import 'screens/portfolio/portfolio_screen.dart';
import 'screens/settings/settings_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (c, s) => const DashboardScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/accounts', builder: (c, s) => const AccountsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/outgoings', builder: (c, s) => const OutgoingsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/portfolio', builder: (c, s) => const PortfolioScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
        ]),
      ],
    ),
  ],
);

class MudraApp extends ConsumerWidget {
  const MudraApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Mudra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_outlined),
              activeIcon: Icon(Icons.account_balance), label: 'Accounts'),
            BottomNavigationBarItem(icon: Icon(Icons.swap_vert_outlined),
              activeIcon: Icon(Icons.swap_vert), label: 'Outgoings'),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart_outlined),
              activeIcon: Icon(Icons.show_chart), label: 'Portfolio'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

FILE 2-6: Create placeholder screens for each tab.
  Each screen is identical in structure, just different title:

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mudra', style: AppTypography.headingMedium
          .copyWith(color: AppColors.gold)),
      ),
      body: Center(
        child: Text('Dashboard — coming soon',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.inkDim)),
      ),
    );
  }
}

Do the same for AccountsScreen, OutgoingsScreen, PortfolioScreen, SettingsScreen.

Run on both simulators. Expected:
  - Cream background
  - Gold "Mudra" in app bar
  - 5-tab bottom nav with gold active tab
  - Tab switching works perfectly
  - No errors
```

---

## PHASE 3 — Data Layer (Isar + Riverpod)

```
Build the complete data layer. This is the foundation everything runs on.

STEP 1 — Isar Models. Each model needs Isar annotations.

FILE: lib/data/models/account.dart
import 'package:isar/isar.dart';
part 'account.g.dart';

@collection
class Account {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String uid;           // uuid string (generated on create)
  
  late String nickname;      // "SBI Daily", "Jupiter"
  String? bankName;          // "SBI", "HDFC"
  
  @enumerated
  late AccountType accountType;
  
  bool isCreditCard = false;
  double balance = 0.0;
  double fdAmount = 0.0;
  bool includeInLiquid = true;
  DateTime? balanceUpdatedAt;
  int sortOrder = 0;
  bool isDeleted = false;
  late DateTime createdAt;
}

enum AccountType { personal, joint, business }

FILE: lib/data/models/outgoing.dart
@collection
class Outgoing {
  Id id = Isar.autoIncrement;
  late String uid;
  late String name;
  
  @enumerated
  late OutgoingType outgoingType;
  
  @enumerated
  late OutgoingCategory category;
  
  double amount = 0.0;
  int debitDate = 1;       // day of month 1-31
  bool isActive = true;
  late DateTime createdAt;
}

enum OutgoingType { expense, investment }
enum OutgoingCategory { loan, insurance, utility, subscription, sip, ppf, epf, nps, other }

FILE: lib/data/models/investment_platform.dart
@collection
class InvestmentPlatform {
  Id id = Isar.autoIncrement;
  late String uid;
  late String platformName;
  
  @enumerated
  late AssetType assetType;
  
  double investedAmount = 0.0;
  double currentValue = 0.0;
  DateTime? valueUpdatedAt;
  bool isDeleted = false;
  late DateTime createdAt;
}

enum AssetType { indianStocks, usStocks, mutualFund, ppf, epf, nps, gold, other }

FILE: lib/data/models/debt.dart
@collection
class Debt {
  Id id = Isar.autoIncrement;
  late String uid;
  late String counterpartyName;
  
  @enumerated
  late DebtDirection direction;
  
  double amount = 0.0;
  DateTime? dueDate;
  String? notes;
  bool isSettled = false;
  late DateTime createdAt;
}

enum DebtDirection { iOwe, theyOwe }

FILE: lib/data/models/app_settings.dart
@collection
class AppSettings {
  Id id = 1;  // singleton — always ID 1
  String baseCurrency = 'INR';
  double monthlyIncome = 0.0;
  int payDate = 1;
}

STEP 2 — Generate Isar code:
  Run: dart run build_runner build --delete-conflicting-outputs
  Verify: .g.dart files created for each model

STEP 3 — lib/data/database.dart:
  Initialise Isar with all collections:
  
  Future<Isar> openDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [AccountSchema, OutgoingSchema, InvestmentPlatformSchema,
       DebtSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }
  
  // Riverpod provider for Isar instance
  final isarProvider = Provider<Isar>((ref) {
    throw UnimplementedError('Must be overridden in main');
  });

STEP 4 — Update main.dart to initialise Isar before app starts:
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    final isar = await openDatabase();
    
    // Create default settings if first launch
    if (await isar.appSettings.get(1) == null) {
      await isar.writeTxn(() async {
        await isar.appSettings.put(AppSettings());
      });
    }
    
    runApp(
      ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
        ],
        child: const MudraApp(),
      ),
    );
  }

STEP 5 — Repositories (simple wrappers):

lib/data/repositories/account_repository.dart:
class AccountRepository {
  final Isar _isar;
  AccountRepository(this._isar);
  
  Stream<List<Account>> watchAll() =>
    _isar.accounts.filter().isDeletedEqualTo(false).watch(fireImmediately: true);
  
  Future<void> save(Account account) async {
    account.createdAt ??= DateTime.now();
    await _isar.writeTxn(() => _isar.accounts.put(account));
  }
  
  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      final acc = await _isar.accounts.get(id);
      if (acc != null) {
        acc.isDeleted = true;
        await _isar.accounts.put(acc);
      }
    });
  }
}

Do the same for OutgoingRepository, InvestmentRepository, SettingsRepository.

STEP 6 — Riverpod providers:

lib/providers/account_provider.dart:
final accountRepoProvider = Provider((ref) =>
  AccountRepository(ref.watch(isarProvider)));

final accountsStreamProvider = StreamProvider<List<Account>>((ref) =>
  ref.watch(accountRepoProvider).watchAll());

// Filtered by type
final personalAccountsProvider = Provider<List<Account>>((ref) {
  final accounts = ref.watch(accountsStreamProvider).valueOrNull ?? [];
  return accounts.where((a) => a.accountType == AccountType.personal).toList();
});
// Repeat for joint, business

lib/providers/dashboard_provider.dart — THE CRITICAL PROVIDER:
@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  @override
  DashboardData build() {
    final accounts = ref.watch(accountsStreamProvider).valueOrNull ?? [];
    final outgoings = ref.watch(outgoingsStreamProvider).valueOrNull ?? [];
    final platforms = ref.watch(platformsStreamProvider).valueOrNull ?? [];
    final debts = ref.watch(debtsStreamProvider).valueOrNull ?? [];
    final settings = ref.watch(settingsProvider);
    
    return _compute(accounts, outgoings, platforms, debts, settings);
  }
  
  DashboardData _compute(...) {
    final today = DateTime.now().day;
    
    final personalAccounts = accounts.where(
      (a) => a.accountType == AccountType.personal &&
             !a.isCreditCard && a.includeInLiquid
    );
    
    final liquidTotal = personalAccounts.fold(0.0, (sum, a) => sum + a.balance);
    final fdTotal = accounts.fold(0.0, (sum, a) => sum + a.fdAmount);
    
    final fixedCommitted = outgoings
      .where((o) => o.isActive && o.debitDate >= today)
      .fold(0.0, (sum, o) => sum + o.amount);
    
    final balanceForMonth = liquidTotal - fixedCommitted;
    final balancePercent = liquidTotal > 0
      ? (balanceForMonth / liquidTotal * 100).clamp(0.0, 100.0)
      : 0.0;
    
    final ccOutstanding = accounts
      .where((a) => a.isCreditCard)
      .fold(0.0, (sum, a) => sum + a.balance);
    
    final investmentsTotal = platforms.fold(0.0, (sum, p) => sum + p.currentValue);
    final totalAssets = liquidTotal + fdTotal + investmentsTotal;
    
    final personalDebts = debts
      .where((d) => d.direction == DebtDirection.iOwe && !d.isSettled)
      .fold(0.0, (sum, d) => sum + d.amount);
    final totalLiabilities = ccOutstanding + personalDebts;
    
    final netWorth = totalAssets - totalLiabilities;
    
    final debitRadar = outgoings
      .where((o) => o.isActive)
      .map((o) => (outgoing: o, daysUntil: DateHelpers.daysUntilDebit(o.debitDate)))
      .where((item) => item.daysUntil <= 7)
      .toList()
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    
    return DashboardData(
      liquidTotal: liquidTotal,
      fdTotal: fdTotal,
      fixedCommitted: fixedCommitted,
      balanceForMonth: balanceForMonth,
      balancePercent: balancePercent,
      netWorth: netWorth,
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
      debitRadar: debitRadar,
      currency: settings.baseCurrency,
    );
  }
}

// DashboardData is a plain Dart class (not Isar model)
class DashboardData {
  final double liquidTotal;
  final double fdTotal;
  final double fixedCommitted;
  final double balanceForMonth;
  final double balancePercent;  // 0-100
  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;
  final List<({Outgoing outgoing, int daysUntil})> debitRadar;
  final String currency;
  const DashboardData({...});
}

Run flutter pub run build_runner build after adding providers.
Test: app still runs on both simulators with no errors.
```

---

## PHASE 4 — Dashboard Screen

```
Build the Dashboard (Home) screen. This is the most important screen.

lib/widgets/fuel_gauge_ring.dart:
  Use CustomPainter to draw the ring.
  
  Constructor: FuelGaugeRing({ 
    required double percentage,  // 0-100
    required double amount,
    required String currency,
    double size = 220,
  })
  
  CustomPainter draws:
    1. Background arc (240 degrees, from 150° to 390°, clockwise)
       Paint: stroke, AppColors.border, strokeWidth 12, StrokeCap.round
    
    2. Progress arc (percentage/100 * 240 degrees)
       Colour: 
         percentage > 50 → AppColors.green
         percentage >= 20 → AppColors.amber
         percentage < 20  → AppColors.red
       Paint: stroke, strokeWidth 12, StrokeCap.round
       Animate with AnimationController when value changes
    
    3. Centre content (Stack overlay, not painted):
       AmountDisplay widget (monoHero style) for amount
       "available this month" SectionLabel below
  
  Animate the ring: use AnimationController + Tween<double>
  When percentage changes, animate from old to new value over 800ms.
  Use Curves.easeInOut.

lib/widgets/common/amount_display.dart:
  AmountDisplay widget:
    Props: amount, currency, style (TextStyle), showSign, coloured
    
    Always uses IBM Plex Mono font (override the passed style's fontFamily)
    If coloured:
      amount > 0 → AppColors.green
      amount < 0 → AppColors.red
      amount == 0 → AppColors.inkDim
    Format using CurrencyFormatter.format()
    If showSign and amount > 0: prefix "+"

lib/widgets/common/section_label.dart:
  SectionLabel widget:
    Props: label (String), color
    Renders: Text(label.toUpperCase(), style: AppTypography.sectionLabel)

lib/widgets/debit_radar_item.dart:
  DebitRadarItem widget:
    Props: outgoing (Outgoing), daysUntil (int), currency (String)
    
    Layout:
      Row [
        Container(width:3, color: outgoing.outgoingType==expense ? red : amber)
        SizedBox(width:12)
        Expanded(Column [
          Text(outgoing.name, bodyMedium, ink)
          Text(outgoing.category label, monoXSmall, inkDim)
        ])
        Column(crossAxisEnd) [
          AmountDisplay(outgoing.amount, mono, no colour)
          Container(
            label: DateHelpers.debitLabel(daysUntil),
            color: isUrgent ? redLight : (daysUntil<=5 ? amberLight : surface2)
            text color: isUrgent ? red : (daysUntil<=5 ? amber : inkDim)
          )
        ]
      ]

lib/screens/dashboard/dashboard_screen.dart:
  ConsumerWidget using dashboardNotifierProvider.
  
  Layout (CustomScrollView with SliverList):
  
  1. App Bar:
     Left: "Mudra" wordmark (Cormorant Garamond, gold)
     Right: IconButton(Icons.settings_outlined) → navigates to settings
  
  2. FUEL GAUGE SECTION (centred, padding top 24):
     FuelGaugeRing(
       percentage: dashboard.balancePercent,
       amount: dashboard.balanceForMonth,
       currency: dashboard.currency,
     )
     Below ring, Row with vertical divider:
       Left: Column(SectionLabel("LIQUID"), AmountDisplay(liquidTotal))
       Divider
       Right: Column(SectionLabel("COMMITTED"), AmountDisplay(fixedCommitted))
  
  3. QUICK STATS ROW (horizontal scroll or 3 equal tiles):
     Tile 1: AmountDisplay(netWorth, compact) + SectionLabel("NET WORTH")
             → tap: go to portfolio
     Tile 2: number of active outgoings + SectionLabel("FIXED ITEMS")
             → tap: go to outgoings
     Tile 3: number of accounts + SectionLabel("ACCOUNTS")
             → tap: go to accounts
     
     Each tile: Card with no accent, tap highlight in goldLight
  
  4. DEBIT RADAR SECTION:
     SectionLabel("NEXT 7 DAYS")
     
     if debitRadar.isEmpty:
       EmptyState(
         icon: "✓",
         title: "All clear",
         message: "No debits in the next 7 days"
       )
     else:
       ListView of DebitRadarItem (non-scrolling, inside parent scroll)
       If more than 5: show first 5 + TextButton "See all in Outgoings"
  
  5. FOOTER:
     Padding bottom 24.
     Text("Pull to refresh · Tap any amount to edit",
          monoXSmall, inkDim, centred)
  
  Pull-to-refresh: RefreshIndicator with gold color
    onRefresh: invalidate all providers
```

---

## PHASE 5 — Accounts Screen

```
lib/screens/accounts/accounts_screen.dart:
  ConsumerStatefulWidget.
  
  State: selectedType (AccountType, default personal)
  
  App Bar: "Accounts" title
           Trailing: + IconButton → show Add Account sheet
  
  Body:
  
  1. HEADER CARD (gold-lt background):
     Large AmountDisplay(liquidTotal, monoLarge, gold)
     SectionLabel("LIQUID TOTAL")
     Below: Row [ fdTotal + "FD" | totalAssets + "TOTAL ASSETS" ]
  
  2. SEGMENT CONTROL (3 tabs: Personal / Joint / Business):
     Custom widget — 3 equal buttons, selected has gold bg + white text
     Others: surface2 bg, inkMid text
     Animates on selection
  
  3. ACCOUNTS LIST (filtered by selectedType):
     if empty: EmptyState with specific message per type
     else: ListView of AccountTile widgets
     Each tile: Dismissible with red delete background (right-to-left)
     
  4. FAB: FloatingActionButton(
       backgroundColor: AppColors.gold,
       child: Icon(Icons.add, color: Colors.white),
       onPressed: () => showAddAccountSheet(context),
     )

lib/widgets/account_tile.dart:
  AccountTile widget. Props: account, onTap, onBalanceTap, onDelete.
  
  Layout: Card wrapping a ListTile-style row:
    Leading: CircleAvatar with bank initial (gold bg, white text)
    Title: account.nickname (labelLarge, ink)
    Subtitle: account.bankName + " · " + account.accountType label (monoXSmall, inkDim)
    Trailing: Column [
      AmountDisplay(account.balance, monoMedium,
        coloured: account.isCreditCard)  // CC balance in red
      Text("Updated X ago", monoXSmall, inkDim)
    ]
    
    If isCreditCard: show Badge("CC", redLight, red) after nickname
    If fdAmount > 0: show small "FD: ₹X" in amber below balance

ADD ACCOUNT BOTTOM SHEET:
  showModalBottomSheet with isScrollControlled: true.
  
  Contains a Form with:
  - "Add Account" or "Edit Account" title + X close button
  - Input: Nickname (required)
  - Input: Bank Name (optional)
    Below: Horizontal scroll chips for quick-fill:
    [SBI] [HDFC] [ICICI] [Axis] [Jupiter] [Kotak] [Canara] [Yes Bank]
    Tap chip: fills bank name input
  - Input: Current Balance (numeric, currency prefix)
  - Segmented control: Personal / Joint / Business
  - Toggle: Is Credit Card (red tint when on)
  - Input: FD Amount (hides if isCreditCard, optional, defaultValue "0")
  - Toggle: Include in Liquid total (default on, hides if isCreditCard)
  - Full-width ElevatedButton: "Save Account"
  - If editing: TextButton in red: "Delete Account" with confirmation
  
  Validation:
    Nickname required
    Balance must be valid number (can be 0)
  
  On save: accountRepo.save(account) → HapticFeedback.lightImpact() → close sheet

QUICK BALANCE UPDATE SHEET:
  Simpler sheet, snap to ~40% height.
  Account name as title.
  Shows current balance (monoMedium, inkMid, "Current: ₹X,XXX")
  Large numeric input (monoHero size, centred, pre-filled, all selected)
  "Update Balance" button
  On save: update balance + balanceUpdatedAt → haptic medium → close
```

---

## PHASE 6 — Outgoings Screen

```
lib/screens/outgoings/outgoings_screen.dart:
  ConsumerStatefulWidget.
  State: selectedTab (OutgoingType, default expense)
  
  App Bar: "Outgoings"
  
  Body:
  
  1. UPCOMING STRIP (horizontal scroll):
     SectionLabel("NEXT 7 DAYS")
     SingleChildScrollView(scrollDirection: Axis.horizontal) of chips:
     Each chip: "[name] · [label]" (e.g. "Home Loan · Tomorrow")
     Chip colours: red for expense, amber for investment
     If empty: Text("No upcoming debits", monoXSmall, inkDim)
  
  2. TAB SWITCHER: Expenses | Investments (same custom segment as Accounts)
  
  3. MONTHLY TOTAL (below tabs):
     "₹ X,XX,XXX this month" (AmountDisplay compact, bold)
     coloured per tab: red for expenses, amber for investments
  
  4. OUTGOINGS LIST (filtered by selectedTab):
     Sorted by debitDate ascending
     Each: OutgoingRow, Dismissible with delete
     if empty: EmptyState with tab-specific instructions
  
  5. FAB: Add Expense or Add Investment (based on selectedTab)

lib/widgets/outgoing_row.dart:
  Layout: Row [
    Container(width:3, full height, colour: expense→red, investment→amber)
    Padding [
      Column [
        Row [ Text(name, labelLarge) ... Spacer ... AmountDisplay(amount, monoMedium) ]
        Row [ 
          Badge(category label, surface2, inkDim)
          Spacer
          Text("Debits on the ${debitDate}th", monoXSmall, inkDim)
        ]
      ]
    ]
  ]

ADD EXPENSE SHEET:
  - Name input with smart suggestions (scrollable chips below input):
    [Home Loan EMI] [Car Loan] [Rent] [Term Life] [Health Insurance]
    [LIC] [Netflix] [Spotify] [Claude] [Apple One] [Electricity]
    Tap chip → fills name field + auto-selects category
  - Amount input (numeric, currency prefix)
  - Debit Date: custom horizontal date picker widget
    Numbers 1–31 in a horizontal scrollable row
    Selected: gold circle bg, white text
    Default: today's date
  - Category picker: wrapped chips in 2 rows
    Expense categories: [Loan] [Insurance] [Utility] [Subscription] [Other]
  - Save button

ADD INVESTMENT SHEET:
  Same structure, amber accent theme.
  Investment categories: [SIP] [PPF] [NPS] [EPF] [Stocks] [Other]
  Name suggestions: [Nippon Small Cap] [HDFC Flexi Cap] [PPF HDFC] [NPS Tier 1]
```

---

## PHASE 7 — Portfolio Screen

```
lib/screens/portfolio/portfolio_screen.dart:
  ConsumerWidget.
  
  Body: CustomScrollView [
  
  1. NET WORTH HERO (gold-lt Container, tappable):
     Large AmountDisplay(netWorth, monoHero → but use Cormorant Garamond!)
       colour: green if positive, red if negative, inkDim if zero
     SectionLabel("NET WORTH")
     Row below: 
       [Assets chip, green-lt] [Liabilities chip, red-lt]
     Tap → show NetWorthDetailSheet
  
  2. INVESTMENTS SECTION:
     SectionLabel("INVESTMENTS")
     
     if empty:
       EmptyState: "Add your investment platforms to track P&L"
                   Button: "Add Platform"
     else:
       List of PlatformCard widgets
       Dismissible for delete
     
     Trailing FAB or TextButton "+ Add Platform"
  
  3. DEBTS & RECEIVABLES SECTION:
     SectionLabel("DEBTS & RECEIVABLES")
     
     Subsection "I Owe" (red-lt header):
       List of debts WHERE direction==iOwe AND !settled
     
     Subsection "Owed to Me" (green-lt header):
       List of debts WHERE direction==theyOwe AND !settled
     
     TextButton "+ Add Debt / Receivable"
  ]

lib/widgets/platform_card.dart:
  Card layout:
    Row [
      Column(crossStart) [
        Text(platformName, labelLarge, ink)
        Badge(assetType label, blue-lt, blue)
      ]
      Spacer
      Column(crossEnd) [
        AmountDisplay(currentValue, monoMedium, coloured: false)
        Text("Current value", monoXSmall, inkDim)
      ]
    ]
    Divider
    Row [
      Text("Invested: " + format(investedAmount), monoSmall, inkMid)
      Spacer
      P&L Chip:
        pnl = currentValue - investedAmount
        colour: pnl >= 0 ? green : red
        bg: pnl >= 0 ? greenLight : redLight
        text: (pnl >= 0 ? "+" : "") + format(pnl)
    ]
    if valueUpdatedAt != null:
      Text("Updated X ago", monoXSmall, inkDim) bottom-right

ADD PLATFORM SHEET:
  - Platform name input
    Suggestions: [HDFC Demat] [Zerodha] [Vested] [Stake] [ETMoney]
                 [Groww] [Kuvera] [INDmoney] [EPFO]
  - Asset type picker (pill grid)
  - Invested amount input
  - Current value input
  - LIVE P&L PREVIEW (updates as user types):
    Container with gold-lt bg:
    Text("P&L: " + format(currentValue - investedAmount))
    Coloured green if positive, red if negative

NET WORTH DETAIL SHEET (snapPoints ~70%):
  ASSETS:
    Row: "Liquid Cash" → format(liquidTotal) [green]
    Row: "Fixed Deposits" → format(fdTotal) [amber]
    Row: "Investments" → format(investmentsTotal) [blue]
    Divider
    Row: "TOTAL ASSETS" → format(totalAssets) [green, bold]
  
  Gap
  
  LIABILITIES:
    Row: "CC Outstanding" → format(ccOutstanding) [red]
    Row: "Personal Debts" → format(personalDebtsTotal) [red]
    Divider
    Row: "TOTAL LIABILITIES" → format(totalLiabilities) [red, bold]
  
  Gap (goldLight line)
  
  FORMULA ROW:
    Text("₹X  −  ₹X  =  ₹X", monoMedium)
    Text("Assets  −  Liabilities  =  Net Worth", monoXSmall, inkDim)
```

---

## PHASE 8 — Settings Screen

```
lib/screens/settings/settings_screen.dart:
  ConsumerStatefulWidget.
  
  App Bar: "Settings"
  
  Body: ListView of settings groups.
  
  Each group has:
    - SectionLabel above the group
    - Card wrapping all rows
    - Rows separated by Divider(indent: 16)

  GROUP 1 — "MONTHLY INCOME":
    Row: "Monthly Income"
         → tap: bottom sheet with large amount input + currency symbol
    Row: "Pay Date"
         → tap: bottom sheet with 1-31 day picker
  
  GROUP 2 — "CURRENCY":
    Current currency displayed (flag + code)
    Tap → bottom sheet with currency grid:
    [🇮🇳 INR] [🇺🇸 USD] [🇬🇧 GBP] [🇦🇪 AED] [🇸🇬 SGD] [🇦🇺 AUD] [🇪🇺 EUR]
    Selected: gold bg, white text
    On change: update AppSettings + all amounts reformat globally
  
  GROUP 3 — "DATA":
    Row: "Clear All Data" (red text)
    → tap: AlertDialog "Are you sure? This will delete all accounts,
           outgoings, and investments."
    Actions: [Cancel] [Delete Everything] (red)
    On confirm: clear all Isar collections → HapticFeedback.heavy

  FOOTER:
    Centred:
    Text("Mudra", Cormorant Garamond 18px, gold)
    Text("v1.0.0 · mudramaster.com", monoXSmall, inkDim)
    Text("Your money. Clear, every morning.", bodySmall italic, inkDim)
```

---

## PHASE 9 — Polish

```
After all screens are built, complete this polish pass:

1. EMPTY STATES:
   Every screen/section must have an EmptyState widget.
   EmptyState takes: emoji (large), title, message, optional action button.
   Ensure no screen shows a blank white area — always instruct the user.

2. HAPTICS:
   Audit every action and add haptic feedback:
   - Save/create: HapticFeedback.lightImpact()
   - Delete: HapticFeedback.mediumImpact()
   - Balance updated: HapticFeedback.mediumImpact()
   - Error/validation fail: HapticFeedback.vibrate() (subtle)
   - Pull to refresh complete: HapticFeedback.lightImpact()

3. ANIMATIONS (flutter_animate):
   - Dashboard fuel gauge: animate ring on first load
   - Screen transitions: smooth (GoRouter default)
   - Bottom sheets opening: already handled by Material
   - Amount changes: use TweenAnimationBuilder for live P&L preview
   - Empty state: fade in with slight upward motion

4. KEYBOARD HANDLING:
   All bottom sheets: resizeToAvoidBottomInset: true
   Numeric inputs: TextInputType.numberWithOptions(decimal: true)
   All inputs: scroll so focused field is visible above keyboard

5. EDGE CASES TO TEST:
   - Zero balance (liquidTotal = 0) → fuel gauge shows 0%, no divide-by-zero
   - Negative balanceForMonth (overspent) → fuel gauge red, shows negative
   - No outgoings → fixedCommitted = 0 → balanceForMonth = liquidTotal
   - Very large numbers (₹ 10,00,00,000) → test formatting doesn't overflow
   - Empty debit radar → shows "All clear" empty state
   - All accounts deleted → dashboard shows zeros gracefully

6. FINAL RUN:
   flutter run --release on both simulators
   Check: no debug banner, no console logs, cream background throughout,
   gold accent consistent, all fonts loading correctly.
```

---

## IMPORTANT RULES (read before every session)

```
1. DART NULL SAFETY: strict null safety throughout. No ! operators
   unless you are 100% certain the value cannot be null.

2. ISAR TRANSACTIONS: all writes must be inside isar.writeTxn().
   Reads use .get(), .getAll(), or .watch() streams.

3. RIVERPOD: use ref.watch() in build methods only.
   Use ref.read() inside callbacks and event handlers.
   Never use ref.watch() inside a callback.

4. CURRENCY AMOUNTS: EVERY displayed currency amount uses
   CurrencyFormatter.format() AND IBM Plex Mono font family.
   This rule has NO exceptions anywhere in the app.

5. COLOUR RULE: Positive financial values → AppColors.green.
   Expenses/negative values → AppColors.red.
   Investment amounts → AppColors.amber.
   Never reverse this colour grammar.

6. NO HARDCODED COLOURS: all colours reference AppColors constants.
   No Color(0xFF...) inline in widgets — use AppColors.gold etc.

7. LOADING STATES: all StreamProvider data must handle the loading
   state (.when(data:, loading:, error:)). Loading state shows
   SkeletonLoader, not a blank screen.

8. BACKGROUND: scaffold background is always AppColors.background
   (#FAF8F4). Never Colors.white as a screen background.

9. BOTTOM SHEETS: use showModalBottomSheet with:
   isScrollControlled: true (allows full height)
   backgroundColor: AppColors.surface
   shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(
     top: Radius.circular(16)))

10. PHASE DISCIPLINE: complete one phase fully before starting the
    next. Run on both simulators after each phase. If there are errors,
    fix them before proceeding.
```

---

*Prompt v2.0 · Mudra Flutter · Local-first MVP · May 2026*
*Phase by phase. Test after every phase. Commit to git after every phase.*
