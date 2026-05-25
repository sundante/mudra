import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import '../data/models/app_settings.dart';
import '../data/repositories/settings_repository.dart';

final settingsRepoProvider = Provider<SettingsRepository>((ref) =>
    SettingsRepository(ref.watch(isarProvider)));

final settingsProvider = FutureProvider<AppSettings>((ref) =>
    ref.watch(settingsRepoProvider).get());
