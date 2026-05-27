import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'data/models/app_settings.dart';
import 'providers/settings_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/accounts/funds_screen.dart';
import 'screens/debts/debts_screen.dart';
import 'screens/portfolio/investments_screen.dart';
import 'screens/net/net_screen.dart';
import 'screens/profile/profile_screen.dart';

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
          GoRoute(path: '/accounts', builder: (c, s) => const FundsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/debts', builder: (c, s) => const DebtsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/portfolio', builder: (c, s) => const InvestmentsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/net', builder: (c, s) => const NetScreen()),
        ]),
      ],
    ),
    GoRoute(
      path: '/profile',
      builder: (c, s) => const ProfileScreen(),
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

class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final name = settings?.safeUserName ?? '';
    final initials = _initials(name);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Mudra',
          style: AppTypography.headingMedium.copyWith(color: AppColors.gold),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings_outlined),
              activeIcon: Icon(Icons.savings),
              label: 'Funds',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_outlined),
              activeIcon: Icon(Icons.account_balance),
              label: 'Debts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_outlined),
              activeIcon: Icon(Icons.show_chart),
              label: 'Invests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.donut_large_outlined),
              activeIcon: Icon(Icons.donut_large),
              label: 'Net',
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
