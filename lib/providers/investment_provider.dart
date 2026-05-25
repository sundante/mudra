import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import '../data/models/debt.dart';
import '../data/models/investment_platform.dart';
import '../data/repositories/investment_repository.dart';

final investmentRepoProvider = Provider<InvestmentRepository>((ref) =>
    InvestmentRepository(ref.watch(isarProvider)));

final platformsStreamProvider = StreamProvider<List<InvestmentPlatform>>((ref) =>
    ref.watch(investmentRepoProvider).watchPlatforms());

final debtsStreamProvider = StreamProvider<List<Debt>>((ref) =>
    ref.watch(investmentRepoProvider).watchDebts());
