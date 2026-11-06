import 'migration.dart';

final List<Migration> appMigrations = [
  Migration(1, (db) => db.execute('CREATE TABLE app_meta (key TEXT PRIMARY KEY NOT NULL, value TEXT NOT NULL)')),
  Migration(2, (db) => db.execute('CREATE TABLE user_settings (key TEXT PRIMARY KEY NOT NULL, value TEXT NOT NULL)')),
  Migration(3, (db) async {
    await db.execute('''
      CREATE TABLE bill_templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        start_month INTEGER NOT NULL,
        end_month INTEGER,
        created_at INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE bill_payments (
        template_id INTEGER NOT NULL REFERENCES bill_templates (id) ON DELETE CASCADE,
        month INTEGER NOT NULL,
        paid_at INTEGER NOT NULL,
        PRIMARY KEY (template_id, month)
      )''');
  }),
  Migration(4, (db) async {
    await db.execute('''
      CREATE TABLE bill_entries (
        template_id INTEGER NOT NULL REFERENCES bill_templates (id) ON DELETE CASCADE,
        month INTEGER NOT NULL,
        due_date INTEGER,
        paid_at INTEGER,
        PRIMARY KEY (template_id, month)
      )''');
    await db.execute('INSERT INTO bill_entries (template_id, month, paid_at) SELECT template_id, month, paid_at FROM bill_payments');
    await db.execute('DROP TABLE bill_payments');
  }),
  Migration(5, (db) => db.execute('ALTER TABLE bill_templates ADD COLUMN due_day INTEGER')),
];
