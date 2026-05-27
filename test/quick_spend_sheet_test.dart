import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudra/data/models/variable_expense.dart';
import 'package:mudra/widgets/common/quick_spend_sheet.dart';

void main() {
  testWidgets('QuickSpendSheet keeps zero amount save disabled',
      (tester) async {
    await tester.pumpWidget(_SheetHost(onSave: (_) async {}));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final saveButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Log ₹ 0 spend'));
    expect(saveButton.onPressed, isNull);
  });

  testWidgets('QuickSpendSheet submits amount and selected category',
      (tester) async {
    QuickSpendDraft? saved;
    await tester.pumpWidget(_SheetHost(onSave: (draft) async => saved = draft));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '500');
    await tester.tap(find.textContaining('Food'));
    await tester.pump();
    final saveButton =
        tester.widget<ElevatedButton>(find.byType(ElevatedButton).last);
    expect(saveButton.onPressed, isNotNull);
    saveButton.onPressed!.call();
    await tester.pumpAndSettle();

    expect(saved?.amount, 500);
    expect(saved?.category, VariableCategory.food);
  });
}

class _SheetHost extends StatelessWidget {
  const _SheetHost({required this.onSave});

  final Future<void> Function(QuickSpendDraft draft) onSave;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => QuickSpendSheet(currency: 'INR', onSave: onSave),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }
}
