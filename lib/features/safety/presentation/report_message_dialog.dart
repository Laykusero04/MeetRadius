import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../../chat/domain/chat_message.dart';
import '../data/submit_report.dart';
import 'report_activity_dialog.dart' show reportReasons;

/// Reports a single chat message for manual review.
Future<bool> showReportMessageDialog(
  BuildContext context, {
  required String activityId,
  required ChatMessage message,
}) async {
  final p = context.palette;
  final reasonCtrl = ValueNotifier<String?>(reportReasons.first);
  final detailsCtrl = TextEditingController();

  var selectedReason = reportReasons.first;
  final submitted = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) {
      return AlertDialog(
        backgroundColor: p.card,
        title: Text(
          'Report message',
          style: TextStyle(color: p.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Our team reviews reports manually. This is not an emergency line.',
                style: TextStyle(color: p.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.chipBorder),
                ),
                child: Text(
                  message.text,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.textPrimary, height: 1.35),
                ),
              ),
              const SizedBox(height: 16),
              ...reportReasons.map((r) {
                return ValueListenableBuilder<String?>(
                  valueListenable: reasonCtrl,
                  builder: (_, selected, __) {
                    return RadioListTile<String>(
                      value: r,
                      groupValue: selected,
                      onChanged: (v) => reasonCtrl.value = v,
                      title: Text(r, style: TextStyle(color: p.textPrimary)),
                      activeColor: p.liveAccent,
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                );
              }),
              const SizedBox(height: 8),
              TextField(
                controller: detailsCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Optional details',
                  hintStyle: TextStyle(color: p.textMuted),
                  filled: true,
                  fillColor: p.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: p.chipBorder),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text('Cancel', style: TextStyle(color: p.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              selectedReason = reasonCtrl.value ?? reportReasons.first;
              Navigator.pop(dialogCtx, true);
            },
            child: Text(
              'Submit',
              style: TextStyle(
                color: p.liveAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    },
  );

  final details = detailsCtrl.text;
  detailsCtrl.dispose();
  reasonCtrl.dispose();

  if (submitted != true || !context.mounted) return false;

  try {
    await submitActivityReport(
      activityId: activityId,
      reason: selectedReason,
      details: details,
      reportedUserUid: message.senderUid,
      reportType: 'message',
      messageId: message.id,
      messageText: message.text,
    );
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report submitted. Thank you.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return true;
  } catch (e) {
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$e'), behavior: SnackBarBehavior.floating),
    );
    return false;
  }
}
