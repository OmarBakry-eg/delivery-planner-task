import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class TimezoneUtils {
  static String formatInTimezone(
    DateTime dateUtc,
    String ianaTimezone, {
    String pattern = 'EEE, MMM d, yyyy h:mm a',
  }) {
    final location = tz.getLocation(ianaTimezone);
    final localTime = tz.TZDateTime.from(dateUtc.toUtc(), location);
    final formatted = DateFormat(pattern).format(localTime);
    final offset = _formatOffset(localTime.timeZoneOffset);
    final abbr = localTime.timeZoneName; // e.g. GST
    return '$formatted $abbr (UTC$offset)';
  }

  static String _formatOffset(Duration offset) {
    final sign = offset.isNegative ? '-' : '+';
    final totalMinutes = offset.inMinutes.abs();
    final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$sign$hours:$minutes';
  }
}
