import 'legal_section.dart';

const kPrivacyLastUpdated = 'May 15, 2026';
const kPrivacyWebUrl = 'https://meetradius.app/privacy';

const kPrivacyPolicy = LegalDocument(
  title: 'Privacy Policy',
  lastUpdated: kPrivacyLastUpdated,
  webUrl: kPrivacyWebUrl,
  sections: [
    LegalSection(
      title: 'Overview',
      paragraphs: [
        'This policy describes how MeetRadius collects, uses, and shares information when you use the app.',
        'We build for local, in-person activities—not endless public social feeds.',
      ],
    ),
    LegalSection(
      title: 'Information we collect',
      paragraphs: [
        'Account information such as email, display name, and profile details you provide.',
        'Activity and chat content you create (for example, hosted activities, join actions, and group messages).',
        'Location information when you enable GPS or set a discovery anchor, used to rank nearby activities within the app’s discovery radius.',
        'Device and usage data needed to secure the service, fix bugs, and understand aggregate usage.',
      ],
    ),
    LegalSection(
      title: 'How we use information',
      paragraphs: [
        'Operate core features: authentication, feeds, maps, activity hosting and joining, and group chat.',
        'Keep users safe through reporting, blocking, and manual review workflows.',
        'Improve reliability and product experience.',
        'Send notifications you opt into (when push is enabled).',
      ],
    ),
    LegalSection(
      title: 'Sharing',
      paragraphs: [
        'We do not sell your personal information.',
        'We use service providers (for example, cloud hosting and authentication) who process data on our behalf under contractual safeguards.',
        'We may disclose information if required by law or to protect users and the service.',
        'Other users see information you choose to show in activities, chat, or your profile according to in-app visibility.',
      ],
    ),
    LegalSection(
      title: 'Your choices',
      paragraphs: [
        'Update notification preferences in Settings.',
        'Block users from Settings when that feature is available in your build.',
        'Request account deletion by contacting support@meetradius.app (self-serve deletion may be added later).',
        'You can stop sharing precise location by disabling GPS for discovery in Settings when that control is available.',
      ],
    ),
    LegalSection(
      title: 'Retention & security',
      paragraphs: [
        'We retain data while your account is active and as needed for legal, safety, and operational purposes.',
        'We use reasonable technical and organizational measures to protect data; no system is perfectly secure.',
      ],
    ),
    LegalSection(
      title: 'Children',
      paragraphs: [
        'MeetRadius is not directed at children under 13. If you believe a child has provided personal information, contact us at support@meetradius.app.',
      ],
    ),
    LegalSection(
      title: 'Contact',
      paragraphs: [
        'Privacy questions: support@meetradius.app',
      ],
    ),
  ],
);
