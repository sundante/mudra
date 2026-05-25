import 'package:isar/isar.dart';
import '../models/account.dart';

class AccountRepository {
  final Isar _isar;
  AccountRepository(this._isar);

  Stream<List<Account>> watchAll() =>
      _isar.accounts.filter().isDeletedEqualTo(false).watch(fireImmediately: true);

  Future<void> save(Account account) async {
    account.createdAt = account.createdAt;
    await _isar.writeTxn(() => _isar.accounts.put(account));
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() async {
      final acc = await _isar.accounts.get(id);
      if (acc != null) {
        acc.isDeleted = true;
        await _isar.accounts.put(acc);
      }
    });
  }
}
