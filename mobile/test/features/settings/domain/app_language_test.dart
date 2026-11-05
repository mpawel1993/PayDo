import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/settings/domain/app_language.dart';

void main() {
  test('codes are the ISO 639-1 language codes', () {
    expect(AppLanguage.pl.code, 'pl');
    expect(AppLanguage.en.code, 'en');
  });

  test('fallback is Polish', () {
    expect(AppLanguage.fallback, AppLanguage.pl);
  });

  test('fromCode maps known codes', () {
    for (final language in AppLanguage.values) {
      expect(AppLanguage.fromCode(language.code), language);
    }
  });

  test('fromCode returns null for unknown, empty or null codes', () {
    expect(AppLanguage.fromCode('de'), isNull);
    expect(AppLanguage.fromCode(''), isNull);
    expect(AppLanguage.fromCode('PL'), isNull);
    expect(AppLanguage.fromCode(null), isNull);
  });
}
