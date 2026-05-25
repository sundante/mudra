import 'package:isar/isar.dart';
import '../models/credit.dart';

class CreditRepository {
  final Isar _isar;
  CreditRepository(this._isar);

  Stream<List<Credit>> watchAll() =>
      _isar.credits.where().watch(fireImmediately: true);

  Future<void> save(Credit credit) async {
    await _isar.writeTxn(() => _isar.credits.put(credit));
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.credits.delete(id));
  }
}
