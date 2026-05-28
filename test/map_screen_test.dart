import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudra/screens/map/map_screen.dart';

void main() {
  testWidgets(
      'map supports root-only, node expansion, expand all, collapse all',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MapScreen()));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('Mudra App').evaluate().isNotEmpty) break;
    }

    expect(find.text('Mudra App'), findsOneWidget);
    expect(find.text('Splash Screen'), findsNothing);
    expect(find.text('Expand all'), findsOneWidget);

    await tester.tap(find.text('Mudra App'));
    await tester.pump();

    expect(find.text('Splash Screen'), findsOneWidget);
    expect(find.text('Authentication Entry'), findsOneWidget);
    expect(find.text('Session gate'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('map-expand-toggle')));
    await tester.pump();

    expect(find.text('Collapse all'), findsOneWidget);
    expect(find.text('Session gate'), findsOneWidget);
    expect(find.text('[Save] → VariableExpense created'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('map-expand-toggle')));
    await tester.pump();

    expect(find.text('Expand all'), findsOneWidget);
    expect(find.text('Mudra App'), findsOneWidget);
    expect(find.text('Splash Screen'), findsNothing);
  });
}
