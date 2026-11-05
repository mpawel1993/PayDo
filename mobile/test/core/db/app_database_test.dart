import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:paydo/core/db/app_database.dart';
import 'package:paydo/core/db/database_factory.dart';
import 'package:paydo/core/db/db_providers.dart';
import 'package:paydo/core/db/migration.dart';
import 'package:paydo/core/db/migrations.dart';
import 'package:sqflite/sqflite.dart' show databaseFactorySqflitePlugin;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/open_test_database.dart';

Future<int> _userVersion(AppDatabase db) async => (await db.db.rawQuery('PRAGMA user_version')).first.values.first! as int;

Future<bool> _tableExists(AppDatabase db, String table) async =>
    (await db.db.query('sqlite_master', where: 'type = ? AND name = ?', whereArgs: ['table', table])).isNotEmpty;

Migration _recording(int version, List<int> log) => Migration(version, (db) async {
  log.add(version);
  await db.execute('CREATE TABLE t$version (id INTEGER PRIMARY KEY)');
});

void main() {
  group('appMigrations', () {
    test('start at version 1 and are contiguous', () {
      expect(appMigrations.map((m) => m.version), List.generate(appMigrations.length, (i) => i + 1));
    });
  });

  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() async => db = await openTestDatabase());
    tearDown(() async => db.close());

    test('user_version equals the latest migration version', () async {
      expect(await _userVersion(db), appMigrations.last.version);
    });

    test('creates the app_meta table', () async {
      expect(await _tableExists(db, 'app_meta'), isTrue);
      await db.db.insert('app_meta', {'key': 'k', 'value': 'v'});
      expect(await db.db.query('app_meta', where: 'key = ?', whereArgs: ['k']), [
        {'key': 'k', 'value': 'v'},
      ]);
    });

    test('enables foreign keys', () async {
      expect((await db.db.rawQuery('PRAGMA foreign_keys')).first.values.first, 1);
    });

    test('transaction() rolls back on error', () async {
      await expectLater(
        db.transaction((txn) async {
          await txn.insert('app_meta', {'key': 'a', 'value': '1'});
          throw StateError('boom');
        }),
        throwsStateError,
      );
      expect(await db.db.query('app_meta'), isEmpty);
    });

    test('close() closes the underlying database', () async {
      await db.close();
      expect(db.isOpen, isFalse);
    });
  });

  group('AppDatabase migrations', () {
    test('runs all migrations in ascending order on create', () async {
      final log = <int>[];
      final db = await openTestDatabase(migrations: [_recording(1, log), _recording(2, log), _recording(3, log)]);
      addTearDown(db.close);

      expect(log, [1, 2, 3]);
      expect(await _userVersion(db), 3);
    });

    test('runs only the missing migrations on upgrade', () async {
      final dir = await Directory.systemTemp.createTemp('paydo_db_test');
      addTearDown(() => dir.delete(recursive: true));
      final path = p.join(dir.path, 'upgrade.db');
      final log = <int>[];

      final v1 = await openTestDatabase(path: path, migrations: [_recording(1, log)]);
      await v1.close();
      log.clear();

      final v3 = await openTestDatabase(path: path, migrations: [_recording(1, log), _recording(2, log), _recording(3, log)]);
      addTearDown(v3.close);

      expect(log, [2, 3]);
      expect(await _userVersion(v3), 3);
    });

    test('rejects migrations that are not contiguous from version 1', () async {
      final log = <int>[];
      expect(() => openTestDatabase(migrations: [_recording(2, log)]), throwsArgumentError);
      expect(() => openTestDatabase(migrations: [_recording(1, log), _recording(3, log)]), throwsArgumentError);
      expect(() => openTestDatabase(migrations: const []), throwsArgumentError);
      expect(log, isEmpty);
    });
  });

  group('AppDatabaseFactory', () {
    test('returns the sqflite plugin factory on mobile', () {
      expect(AppDatabaseFactory.create(), same(databaseFactorySqflitePlugin));
    });
  });

  group('appDatabaseProvider', () {
    test('opens the database lazily and closes it on dispose', () async {
      sqfliteFfiInit();
      final container = ProviderContainer(
        overrides: [
          appDatabaseFactoryProvider.overrideWithValue(databaseFactoryFfi),
          appDatabasePathProvider.overrideWithValue(inMemoryDatabasePath),
        ],
      );

      final db = await container.read(appDatabaseProvider.future);
      expect(db.isOpen, isTrue);

      container.dispose();
      await pumpEventQueue();
      expect(db.isOpen, isFalse);
    });
  });
}
