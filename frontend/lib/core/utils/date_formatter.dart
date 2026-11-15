import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateTimeFormat = DateFormat('MMM d, yyyy • h:mm a');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _shortDateFormat = DateFormat('MMM d');

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _dateTimeFormat.format(dateTime.toLocal());
  }

  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _timeFormat.format(dateTime.toLocal());
  }

  static String formatShortDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _shortDateFormat.format(dateTime.toLocal());
  }

  static String formatRelativeOrTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final local = dateTime.toLocal();
    final now = DateTime.now();
    final difference = now.difference(local);

    if (difference.inDays == 0 && now.day == local.day) {
      return formatTime(local);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE, h:mm a').format(local);
    } else {
      return _dateTimeFormat.format(local);
    }
  }
}
