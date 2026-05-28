import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'providers/auth_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/accounts/funds_screen.dart';
import 'screens/auth/auth_screens.dart';
import 'screens/debts/debts_screen.dart';
import 'screens/dev/dev_tools_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/onboarding/guest_handoff_screen.dart';
import 'screens/onboarding/setup_wizard_screen.dart';
import 'screens/portfolio/investments_screen.dart';
import 'screens/net/net_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/spend/spend_screen.dart';
import 'widgets/onboarding/guided_tour_overlay.dart';

CustomTransitionPage<void> _fade(GoRouterState s, Widget child) =>
    CustomTransitionPage<void>(
      key: s.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, animation, __, w) =>
          FadeTransition(opacity: animation, child: w),
    );

GoRouter _createRouter(AppSessionController session) => GoRouter(
      initialLocation: '/loading',
      refreshListenable: session,
      redirect: (context, state) {
        final path = state.uri.path;
        final stage = session.state.stage;
        final isAuthPath = path == '/welcome' ||
            path.startsWith('/auth/') ||
            path == '/callback' ||
            path == '/reset-password';
        switch (stage) {
          case AppSessionStage.loading:
            return path == '/loading' ? null : '/loading';
          case AppSessionStage.signedOut:
            return isAuthPath ? null : '/welcome';
          case AppSessionStage.guest:
            return (path == '/loading' || isAuthPath) ? '/' : null;
          case AppSessionStage.verificationRequired:
            return path == '/auth/verify-email' ? null : '/auth/verify-email';
          case AppSessionStage.passwordRecovery:
            return path == '/auth/new-password' ? null : '/auth/new-password';
          case AppSessionStage.legacyDataDecision:
            return path == '/legacy-data' ? null : '/legacy-data';
          case AppSessionStage.setupRequired:
            return path == '/onboarding/setup' ? null : '/onboarding/setup';
          case AppSessionStage.ready:
            return isAuthPath ||
                    path == '/loading' ||
                    path == '/legacy-data' ||
                    path == '/setup/welcome' ||
                    path == '/onboarding/setup' ||
                    path == '/onboarding/handoff'
                ? '/'
                : null;
        }
      },
      routes: [
        GoRoute(
          path: '/loading',
          pageBuilder: (c, s) => _fade(s, const AuthLoadingScreen()),
        ),
        GoRoute(
          path: '/welcome',
          pageBuilder: (c, s) => _fade(s, const WelcomeScreen()),
        ),
        GoRoute(
          path: '/auth/login',
          pageBuilder: (c, s) => _fade(s, const LoginScreen()),
        ),
        GoRoute(
          path: '/auth/register',
          pageBuilder: (c, s) => _fade(s, const RegisterScreen()),
        ),
        GoRoute(
          path: '/auth/verify-email',
          pageBuilder: (c, s) => _fade(s, const VerifyEmailScreen()),
        ),
        GoRoute(
          path: '/auth/forgot-password',
          pageBuilder: (c, s) => _fade(s, const ForgotPasswordScreen()),
        ),
        GoRoute(
          path: '/auth/new-password',
          pageBuilder: (c, s) => _fade(s, const NewPasswordScreen()),
        ),
        GoRoute(
          path: '/callback',
          pageBuilder: (c, s) => _fade(s, const AuthLoadingScreen()),
        ),
        GoRoute(
          path: '/reset-password',
          pageBuilder: (c, s) => _fade(s, const AuthLoadingScreen()),
        ),
        GoRoute(
          path: '/legacy-data',
          pageBuilder: (c, s) => _fade(s, const LegacyDataScreen()),
        ),
        GoRoute(
          path: '/setup/welcome',
          pageBuilder: (c, s) => _fade(s, const SetupWelcomeScreen()),
        ),
        GoRoute(
          path: '/onboarding/setup',
          pageBuilder: (c, s) => _fade(s, const SetupWizardScreen()),
        ),
        GoRoute(
          path: '/onboarding/handoff',
          pageBuilder: (c, s) => _fade(s, const GuestHandoffScreen()),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ScaffoldWithNavBar(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/',
                  pageBuilder: (c, s) => _fade(s, const DashboardScreen())),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/accounts',
                  pageBuilder: (c, s) => _fade(s, const FundsScreen())),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/debts',
                  pageBuilder: (c, s) => _fade(s, const DebtsScreen())),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/portfolio',
                  pageBuilder: (c, s) => _fade(s, const InvestmentsScreen())),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/net',
                  pageBuilder: (c, s) => _fade(s, const NetScreen())),
            ]),
          ],
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (c, s) => _fade(s, const ProfileScreen()),
        ),
        GoRoute(
          path: '/map',
          pageBuilder: (c, s) => _fade(s, const MapScreen()),
        ),
        if (kDebugMode)
          GoRoute(
            path: '/dev-tools',
            pageBuilder: (c, s) => _fade(s, const DevToolsScreen()),
          ),
        GoRoute(
          path: '/spend',
          pageBuilder: (c, s) => _fade(s, const SpendScreen()),
        ),
      ],
    );

class MudraApp extends ConsumerStatefulWidget {
  const MudraApp({super.key});

  @override
  ConsumerState<MudraApp> createState() => _MudraAppState();
}

class _MudraAppState extends ConsumerState<MudraApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _createRouter(ref.read(appSessionControllerProvider));
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    final stage =
        ref.watch(appSessionControllerProvider).state.stage;
    final isGuest = stage == AppSessionStage.guest;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          body: navigationShell,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isGuest) _DemoBanner(ref: ref),
              Container(
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
            ],
          ),
        ),
        if (isGuest) const GuidedTourOverlay(),
      ],
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF9A5510),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Text(
            'DEMO MODE  ·  SAMPLE DATA',
            style: AppTypography.sectionLabel.copyWith(color: Colors.white),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              ref.read(appSessionControllerProvider).exitGuestMode();
              GoRouter.of(context).go('/auth/register');
            },
            child: Text(
              'SIGN UP',
              style: AppTypography.sectionLabel.copyWith(
                color: Colors.white,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
