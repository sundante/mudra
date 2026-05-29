import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import '../data/models/account.dart';
import '../data/repositories/account_repository.dart';

final accountRepoProvider = Provider<AccountRepository>(
    (ref) => AccountRepository(ref.watch(isarProvider)));

final accountsStreamProvider = StreamProvider<List<Account>>(
    (ref) => ref.watch(accountRepoProvider).watchAll());

