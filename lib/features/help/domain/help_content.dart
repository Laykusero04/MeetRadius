/// FAQ entry for Help & support.
final class HelpFaqItem {
  const HelpFaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}

const kHelpFaqItems = <HelpFaqItem>[
  HelpFaqItem(
    question: 'How do I join an activity?',
    answer:
        'Open the Feed, tap an activity card, then tap Join. '
        'You will get access to that activity’s group chat for coordination.',
  ),
  HelpFaqItem(
    question: 'What is a live activity?',
    answer:
        'Live activities are happening now or starting very soon. '
        'They appear at the top of your feed so you can decide quickly.',
  ),
  HelpFaqItem(
    question: 'How does location work?',
    answer:
        'MeetRadius ranks activities within 15 miles of your discovery anchor. '
        'You can use GPS or set a manual city and ZIP in Settings when that option is available.',
  ),
  HelpFaqItem(
    question: 'Can I host my own activity?',
    answer:
        'Yes. Use the create button on the Feed to post time, place, type, and capacity. '
        'Hosts can manage members and see who checks in on site.',
  ),
];

const kSafetyTips = <String>[
  'Meet in public places when trying a new group.',
  'Share your plans with someone you trust before you go.',
  'Use activity group chat only for practical coordination.',
  'Leave or report anything that feels unsafe — we review reports manually.',
];

const kReportGuidance = '''
To report a problem:
• Activity — open the activity, then use Report from the menu.
• Chat — open the group info screen (top of the thread) and tap Report conversation.
• Person — report from their profile or activity context when available.

Blocking is available alongside report flows. You can manage blocked users in Settings.
''';
