import 'package:flutter_test/flutter_test.dart';
import 'package:meet_radius/features/legal/domain/privacy_policy.dart';
import 'package:meet_radius/features/legal/domain/terms_of_service.dart';

void main() {
  test('terms and privacy documents have sections', () {
    expect(kTermsOfService.sections, isNotEmpty);
    expect(kPrivacyPolicy.sections, isNotEmpty);
    expect(kTermsOfService.webUrl, isNotNull);
    expect(kPrivacyPolicy.webUrl, isNotNull);
  });
}
