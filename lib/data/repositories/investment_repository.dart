import 'package:isar/isar.dart';
import '../models/debt.dart';
import '../models/investment_holding.dart';
import '../models/investment_platform.dart';

class InvestmentRepository {
  final Isar _isar;
  InvestmentRepository(this._isar);

  Stream<List<InvestmentPlatform>> watchPlatforms() => _isar.investmentPlatforms
      .filter()
      .isDeletedEqualTo(false)
      .watch(fireImmediately: true);

  Stream<List<InvestmentHolding>> watchHoldings() =>
      _isar.investmentHoldings.where().watch(fireImmediately: true);

  Stream<List<Debt>> watchDebts() =>
      _isar.debts.where().watch(fireImmediately: true);

  Future<void> savePlatform(InvestmentPlatform platform) async {
    await _isar.writeTxn(() => _isar.investmentPlatforms.put(platform));
  }

  Future<void> deletePlatform(int id) async {
    await _isar.writeTxn(() async {
      final p = await _isar.investmentPlatforms.get(id);
      if (p != null) {
        p.isDeleted = true;
        await _isar.investmentPlatforms.put(p);
      }
    });
  }

  Future<void> saveHolding(InvestmentHolding holding) async {
    await _isar.writeTxn(() => _isar.investmentHoldings.put(holding));
  }

  Future<void> deleteHolding(int id) async {
    await _isar.writeTxn(() => _isar.investmentHoldings.delete(id));
  }

  Future<void> saveDebt(Debt debt) async {
    await _isar.writeTxn(() => _isar.debts.put(debt));
  }

  Future<void> deleteDebt(int id) async {
    await _isar.writeTxn(() => _isar.debts.delete(id));
  }

  Future<void> settleDebt(int id) async {
    await _isar.writeTxn(() async {
      final debt = await _isar.debts.get(id);
      if (debt != null) {
        debt.isSettled = true;
        await _isar.debts.put(debt);
      }
    });
  }
}
