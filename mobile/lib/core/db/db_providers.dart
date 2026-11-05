import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' show DatabaseFactory;

import 'app_database.dart';
import 'database_factory.dart';

final appDatabaseFactoryProvider = Provider<DatabaseFactory>((ref) => AppDatabaseFactory.create());

final appDatabasePathProvider = Provider<String?>((ref) => null);

final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final db = await AppDatabase.open(factory: ref.watch(appDatabaseFactoryProvider), path: ref.watch(appDatabasePathProvider));
  ref.onDispose(db.close);
  return db;
});
