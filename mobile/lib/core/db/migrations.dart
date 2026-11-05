import 'migration.dart';

final List<Migration> appMigrations = [
  Migration(1, (db) => db.execute('CREATE TABLE app_meta (key TEXT PRIMARY KEY NOT NULL, value TEXT NOT NULL)')),
];
