import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/db/app_database.dart';
import 'package:paydo/features/settings/data/sqlite_settings_repository.dart';
import 'package:paydo/features/settings/domain/app_language.dart';

import '../../../support/open_test_database.dart';

void main() {
  late AppDatabase db;
  late SqliteSettingsRepository repository;

  setUp(() async {
    db = await openTestDatabase();
    repository = SqliteSettingsRepository(db);
  });
  tearDown(() async => db.close());

  test('returns null when no language was saved', () async {
    expect(await repository.loadLanguage(), isNull);
  });

  test('saves and loads the language', () async {
    await repository.saveLanguage(AppLanguage.en);
    expect(await repository.loadLanguage(), AppLanguage.en);
  });

  test('overwrites the previously saved language with a single row', () async {
    await repository.saveLanguage(AppLanguage.en);
    await repository.saveLanguage(AppLanguage.pl);

    expect(await repository.loadLanguage(), AppLanguage.pl);
    expect(await db.db.query('user_settings', where: 'key = ?', whereArgs: [SqliteSettingsRepository.languageKey]), hasLength(1));
  });

  test('stores the language code as TEXT', () async {
    await repository.saveLanguage(AppLanguage.en);
    expect(await db.db.query('user_settings'), [
      {'key': SqliteSettingsRepository.languageKey, 'value': 'en'},
    ]);
  });

  test('returns null for an unknown stored code', () async {
    await db.db.insert('user_settings', {'key': SqliteSettingsRepository.languageKey, 'value': 'xx'});
    expect(await repository.loadLanguage(), isNull);
  });
}
