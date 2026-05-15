import 'package:flutter/material.dart';

import '../../../core/theme/meet_radius_palette.dart';
import '../data/submit_report.dart';

const reportReasons = [
  'Spam or misleading',
  'Harassment or hate',
  'Unsafe meetup',
  'Wrong location',
  'Other',
];

Future<bool> showReportActivityDialog(
  BuildContext context, {
  required String activityId,
  String? reportedUserUid,
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
          'Report activity',
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
      reportedUserUid: reportedUserUid,
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
