class DateHelpers {
  DateHelpers._();

  static int daysUntilDebit(int debitDay) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next = nextDebitDate(debitDay);
    return next.difference(today).inDays;
  }

  static DateTime nextDebitDate(int debitDay) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Clamp to last day of current month
    final lastDayThisMonth =
        DateTime(now.year, now.month + 1, 0).day;
    final clampedDay =
        debitDay > lastDayThisMonth ? lastDayThisMonth : debitDay;
    final thisMonthDate = DateTime(now.year, now.month, clampedDay);

    if (!thisMonthDate.isBefore(today)) return thisMonthDate;

    // Next month
    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    final nextYear = now.month == 12 ? now.year + 1 : now.year;
    final lastDayNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
    final clampedNextDay =
        debitDay > lastDayNextMonth ? lastDayNextMonth : debitDay;
    return DateTime(nextYear, nextMonth, clampedNextDay);
  }

  static String debitLabel(int daysUntil) {
    if (daysUntil == 0) return 'Today';
    if (daysUntil == 1) return 'Tomorrow';
    return 'in $daysUntil days';
  }

  static bool isUrgent(int daysUntil) => daysUntil <= 2;
}
