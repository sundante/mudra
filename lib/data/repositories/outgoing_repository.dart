import 'package:isar/isar.dart';
import '../models/outgoing.dart';

class OutgoingRepository {
  final Isar _isar;
  OutgoingRepository(this._isar);

  Stream<List<Outgoing>> watchAll() =>
      _isar.outgoings.where().watch(fireImmediately: true);

  Future<void> save(Outgoing outgoing) async {
    await _isar.writeTxn(() => _isar.outgoings.put(outgoing));
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.outgoings.delete(id));
  }
}
