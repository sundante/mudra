import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import '../data/models/credit.dart';
import '../data/repositories/credit_repository.dart';

final creditRepoProvider = Provider<CreditRepository>((ref) =>
    CreditRepository(ref.watch(isarProvider)));

final creditsStreamProvider = StreamProvider<List<Credit>>((ref) =>
    ref.watch(creditRepoProvider).watchAll());
