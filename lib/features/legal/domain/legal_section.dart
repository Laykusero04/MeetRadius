/// A titled block within Terms of Service or Privacy Policy.
final class LegalSection {
  const LegalSection({
    required this.title,
    required this.paragraphs,
  });

  final String title;
  final List<String> paragraphs;
}

final class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.lastUpdated,
    required this.sections,
    this.webUrl,
  });

  final String title;
  final String lastUpdated;
  final List<LegalSection> sections;
  final String? webUrl;
}
