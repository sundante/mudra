import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Coordinates the centralized nav FAB with per-screen actions.
/// $1 = tab index (0=Home, 1=Funds, 2=Debts, 3=Invests)
/// $2 = sequence counter (incremented on each press to re-trigger)
final fabTriggerProvider = StateProvider<(int, int)>((ref) => (0, 0));
