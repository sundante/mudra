import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import '../data/models/account.dart';
import '../data/repositories/account_repository.dart';

final accountRepoProvider = Provider<AccountRepository>(
    (ref) => AccountRepository(ref.watch(isarProvider)));

final accountsStreamProvider = StreamProvider<List<Account>>(
    (ref) => ref.watch(accountRepoProvider).watchAll());

final personalAccountsProvider = Provider<List<Account>>((ref) {
  final accounts = ref.watch(accountsStreamProvider).valueOrNull ?? [];
  return accounts
      .where((a) => a.safeAccountType == AccountType.personal)
      .toList();
});

final jointAccountsProvider = Provider<List<Account>>((ref) {
  final accounts = ref.watch(accountsStreamProvider).valueOrNull ?? [];
  return accounts.where((a) => a.safeAccountType == AccountType.joint).toList();
});

final businessAccountsProvider = Provider<List<Account>>((ref) {
  final accounts = ref.watch(accountsStreamProvider).valueOrNull ?? [];
  return accounts
      .where((a) => a.safeAccountType == AccountType.business)
      .toList();
});
