import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudra/app.dart';
import 'package:mudra/screens/auth/auth_screens.dart';
import 'package:mudra/screens/dashboard/dashboard_screen.dart';

void main() {
  testWidgets('signed-out first launch opens Welcome rather than Dashboard',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MudraApp()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
  });

  testWidgets('registration requires user details and consent',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MudraApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account').first);
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pump();
    final submit = find.byKey(const ValueKey('register-submit'));
    await tester.tap(submit);
    await tester.pump();
    expect(find.text('This field is required'), findsWidgets);
    expect(find.text('Enter a valid email address'), findsOneWidget);
  });
}
