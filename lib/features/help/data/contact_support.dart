import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

const kSupportEmail = 'support@meetradius.app';

/// Opens the device mail client with a pre-filled support request.
Future<bool> launchSupportEmail() async {
  final user = FirebaseAuth.instance.currentUser;
  final bodyLines = <String>[
    'Describe your issue or question:',
    '',
    '',
    '---',
    'App: MeetRadius',
    if (user?.uid != null) 'User ID: ${user!.uid}',
    if (user?.email != null) 'Email: ${user!.email}',
  ];
  final uri = Uri(
    scheme: 'mailto',
    path: kSupportEmail,
    query: _encodeQuery({
      'subject': 'MeetRadius support',
      'body': bodyLines.join('\n'),
    }),
  );

  try {
    if (!await canLaunchUrl(uri)) return false;
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e, st) {
    debugPrint('MeetRadius: launchSupportEmail failed: $e\n$st');
    return false;
  }
}

String _encodeQuery(Map<String, String> params) {
  return params.entries
      .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
      .join('&');
}
