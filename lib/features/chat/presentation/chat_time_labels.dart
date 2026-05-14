String shortRelativeChatTime(DateTime time, DateTime now) {
  final diff = now.difference(time);
  if (diff.inSeconds < 45) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${time.month}/${time.day}';
}

/// Facebook Messenger–style centered divider timestamp (e.g. `APR 21 AT 6:07 AM`).
String messengerThreadTimestamp(DateTime t) {
  const months = <String>[
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  final mon = months[t.month - 1];
  final day = t.day;
  final h24 = t.hour;
  final hour = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
  final min = t.minute.toString().padLeft(2, '0');
  final ampm = h24 >= 12 ? 'PM' : 'AM';
  return '$mon $day AT $hour:$min $ampm';
}
