import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> openLegalWebUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;

  try {
    if (!await canLaunchUrl(uri)) return false;
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e, st) {
    debugPrint('MeetRadius: openLegalWebUrl failed: $e\n$st');
    return false;
  }
}
