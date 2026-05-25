import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import '../data/models/outgoing.dart';
import '../data/repositories/outgoing_repository.dart';

final outgoingRepoProvider = Provider<OutgoingRepository>((ref) =>
    OutgoingRepository(ref.watch(isarProvider)));

final outgoingsStreamProvider = StreamProvider<List<Outgoing>>((ref) =>
    ref.watch(outgoingRepoProvider).watchAll());
