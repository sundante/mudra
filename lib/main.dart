import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/database.dart';
import 'data/models/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isar = await openDatabase();

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
