import 'legal_section.dart';

const kTermsLastUpdated = 'May 15, 2026';
const kTermsWebUrl = 'https://meetradius.app/terms';

const kTermsOfService = LegalDocument(
  title: 'Terms of Service',
  lastUpdated: kTermsLastUpdated,
  webUrl: kTermsWebUrl,
  sections: [
    LegalSection(
      title: 'Agreement',
      paragraphs: [
        'By using MeetRadius, you agree to these Terms of Service. '
        'If you do not agree, do not use the app.',
        'MeetRadius helps people discover and join real-world activities near them. '
        'We may update these terms; continued use after changes means you accept the updated terms.',
      ],
    ),
    LegalSection(
      title: 'Eligibility & account',
      paragraphs: [
        'You must be at least 13 years old (or the minimum age required in your region) to use MeetRadius.',
        'You are responsible for your account credentials and for activity under your account.',
        'Provide accurate registration information and keep it reasonably up to date.',
      ],
    ),
    LegalSection(
      title: 'Activities & conduct',
      paragraphs: [
        'Hosts and participants are responsible for their own safety and decisions when meeting in person.',
        'Do not use MeetRadius for illegal activity, harassment, hate speech, scams, or sexual solicitation.',
        'Do not post false locations, spam activities, or impersonate others.',
        'We may remove content or suspend accounts that violate these terms or harm the community.',
      ],
    ),
    LegalSection(
      title: 'Content you share',
      paragraphs: [
        'You retain ownership of content you post. You grant MeetRadius a license to host, display, '
        'and distribute that content solely to operate the service (for example, activity details, chat messages, and profile information).',
        'Do not upload content you do not have rights to share.',
      ],
    ),
    LegalSection(
      title: 'Disclaimer & liability',
      paragraphs: [
        'MeetRadius is provided “as is.” We do not guarantee uninterrupted service or the behavior of other users.',
        'To the fullest extent permitted by law, MeetRadius is not liable for indirect or consequential damages '
        'arising from your use of the app or in-person meetups organized through it.',
      ],
    ),
    LegalSection(
      title: 'Contact',
      paragraphs: [
        'Questions about these terms: support@meetradius.app',
      ],
    ),
  ],
);
