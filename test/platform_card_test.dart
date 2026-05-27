import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudra/data/models/investment_platform.dart';
import 'package:mudra/widgets/platform_card.dart';

void main() {
  testWidgets('PlatformCard shows positive percentage gain', (tester) async {
    await tester.pumpWidget(_card(invested: 100, current: 125));

    expect(find.textContaining('(+25.0%)'), findsOneWidget);
  });

  testWidgets('PlatformCard shows negative percentage loss', (tester) async {
    await tester.pumpWidget(_card(invested: 100, current: 75));

    expect(find.textContaining('(-25.0%)'), findsOneWidget);
  });

  testWidgets('PlatformCard handles zero invested amount', (tester) async {
    await tester.pumpWidget(_card(invested: 0, current: 10));

    expect(find.textContaining('(0.0%)'), findsOneWidget);
    expect(find.textContaining('Infinity'), findsNothing);
  });
}

Widget _card({required double invested, required double current}) {
  final platform = InvestmentPlatform()
    ..uid = 'test'
    ..platformName = 'Example Platform'
    ..assetType = AssetType.mutualFund
    ..investedAmount = invested
    ..currentValue = current
    ..isDeleted = false
    ..createdAt = DateTime(2026);

  return MaterialApp(
    home: Scaffold(
      body: PlatformCard(
        platform: platform,
        currency: 'INR',
        onTap: () {},
      ),
    ),
  );
}
