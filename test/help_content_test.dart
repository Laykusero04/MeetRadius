import 'package:flutter_test/flutter_test.dart';
import 'package:meet_radius/features/help/domain/help_content.dart';

void main() {
  test('help FAQ and safety content is non-empty', () {
    expect(kHelpFaqItems, isNotEmpty);
    expect(kSafetyTips, isNotEmpty);
    expect(kReportGuidance.trim(), isNotEmpty);
  });
}
