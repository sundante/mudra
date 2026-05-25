import 'package:isar/isar.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  final Isar _isar;
  SettingsRepository(this._isar);

  Future<AppSettings> get() async {
    return await _isar.appSettings.get(1) ?? AppSettings();
  }

  Future<void> save(AppSettings settings) async {
    await _isar.writeTxn(() => _isar.appSettings.put(settings));
  }
}
