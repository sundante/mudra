import 'package:flutter_riverpod/flutter_riverpod.dart';

// Drives the day-slider simulation on the dashboard.
// Defaults to today's day-of-month; user can scrub 1–31 to project.
final selectedDayProvider = StateProvider<int>(
  (ref) => DateTime.now().day,
);
