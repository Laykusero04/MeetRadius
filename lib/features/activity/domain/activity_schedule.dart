/// Defaults and validation for activity [startsAt] / [endsAt].
const Duration kDefaultActivityDuration = Duration(hours: 3);
const Duration kMaxActivityDuration = Duration(hours: 24);

DateTime defaultEndsAt(DateTime startsAt) =>
    startsAt.add(kDefaultActivityDuration);

/// Friendly label: Today · 6:30 PM
String formatActivityDateTimeLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dDay = DateTime(d.year, d.month, d.day);
  final diff = dDay.difference(today).inDays;
  final dayPart = switch (diff) {
    0 => 'Today',
    1 => 'Tomorrow',
    _ => '${d.month}/${d.day}/${d.year}',
  };
  final h24 = d.hour;
  final hour = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
  final min = d.minute.toString().padLeft(2, '0');
  final ampm = h24 >= 12 ? 'PM' : 'AM';
  return '$dayPart · $hour:$min $ampm';
}

/// Returns null if valid; otherwise an error message for SnackBars.
String? validateScheduledEnd({
  required DateTime startsAt,
  required DateTime? endsAt,
  required bool hasScheduledEnd,
}) {
  if (!hasScheduledEnd || endsAt == null) return null;
  if (!endsAt.isAfter(startsAt)) {
    return 'End time must be after the start time.';
  }
  if (endsAt.difference(startsAt) > kMaxActivityDuration) {
    return 'Activities can run at most ${kMaxActivityDuration.inHours} hours.';
  }
  return null;
}
