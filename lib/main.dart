import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/database.dart';
import 'data/models/account.dart';
import 'data/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isar = await openDatabase();

  // Fresh install: seed demo data so the app is never empty on first launch
  final accountCount = await isar.accounts.count();
  if (accountCount == 0) {
    await seedDemoData(isar);
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
