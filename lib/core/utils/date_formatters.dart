import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormatters {
  DateFormatters._();

  static String dateTime(DateTime dt) => DateFormat('MMM d, y  h:mm a').format(dt);

  static String date(DateTime dt) => DateFormat('MMM d, y').format(dt);

  static String time(DateTime dt) => DateFormat('h:mm a').format(dt);

  static String timeOfDay(TimeOfDay t) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat('h:mm a').format(dt);
  }

  static String relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
