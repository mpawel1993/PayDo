import 'package:sqflite/sqflite.dart';

final class Migration {
  const Migration(this.version, this.up);

  final int version;
  final Future<void> Function(DatabaseExecutor db) up;

  static void validate(List<Migration> migrations) {
    if (migrations.isEmpty) throw ArgumentError.value(migrations, 'migrations', 'must not be empty');
    for (final (i, m) in migrations.indexed) {
      if (m.version != i + 1) throw ArgumentError.value(m.version, 'migrations[$i].version', 'expected ${i + 1}');
    }
  }
}
