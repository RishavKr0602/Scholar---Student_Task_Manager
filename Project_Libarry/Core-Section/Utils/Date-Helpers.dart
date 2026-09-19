import 'package:intl/intl.dart';

class DateHelpers {
  static String formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDay = DateTime(date.year, date.month, date.day);

    final timeString = DateFormat('h:mm a').format(date);

    if (targetDay == today) {
      return 'Today at $timeString';
    } else if (targetDay == tomorrow) {
      return 'Tomorrow at $timeString';
    } else if (targetDay.isBefore(today)) {
      final daysAgo = today.difference(targetDay).inDays;
      return daysAgo == 1 ? 'Yesterday at $timeString' : '$daysAgo days overdue';
    } else if (targetDay.difference(today).inDays < 7) {
      return '${DateFormat('EEEE').format(date)} at $timeString';
    } else {
      return DateFormat('MMM d, yyyy • h:mm a').format(date);
    }
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static bool isOverdue(DateTime date, bool completed) {
    if (completed) return false;
    return date.isBefore(DateTime.now());
  }

  static bool isDueToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
