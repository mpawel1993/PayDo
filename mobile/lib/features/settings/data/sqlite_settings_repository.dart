import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import '../domain/app_language.dart';
import '../domain/settings_repository.dart';

final class SqliteSettingsRepository implements SettingsRepository {
  const SqliteSettingsRepository(this._database);

  static const table = 'user_settings';
  static const languageKey = 'language';

  final AppDatabase _database;

  @override
  Future<AppLanguage?> loadLanguage() async {
    final rows = await _database.db.query(table, columns: ['value'], where: 'key = ?', whereArgs: [languageKey], limit: 1);
    return AppLanguage.fromCode(rows.firstOrNull?['value'] as String?);
  }

  @override
  Future<void> saveLanguage(AppLanguage language) =>
      _database.db.insert(table, {'key': languageKey, 'value': language.code}, conflictAlgorithm: ConflictAlgorithm.replace);
}
