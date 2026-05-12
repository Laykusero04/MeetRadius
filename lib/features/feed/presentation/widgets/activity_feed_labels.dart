/// Human-readable labels for [Activity.startsAt] on the feed.
String activitySchedulePill(DateTime startsAt) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final wd = weekdays[startsAt.weekday - 1];
  final hour = startsAt.hour % 12 == 0 ? 12 : startsAt.hour % 12;
  final min = startsAt.minute.toString().padLeft(2, '0');
  final ampm = startsAt.hour >= 12 ? 'pm' : 'am';
  return '$wd · $hour:$min $ampm';
}

String activityStartsInLine(DateTime startsAt, DateTime now) {
  if (!startsAt.isAfter(now)) return 'Starting now';
  final diff = startsAt.difference(now);
  if (diff.inMinutes < 60) return 'Starts in ${diff.inMinutes} min';
  if (diff.inHours < 48) return 'Starts in ${diff.inHours} h';
  final days = diff.inDays;
  return 'Starts in $days d';
}
