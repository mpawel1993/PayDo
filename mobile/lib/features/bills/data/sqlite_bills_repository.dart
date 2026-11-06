import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import '../domain/bill.dart';
import '../domain/bill_category.dart';
import '../domain/bill_template.dart';
import '../domain/bills_repository.dart';
import '../domain/calendar_date.dart';
import '../domain/year_month.dart';
import 'bill_template_row.dart';

final class SqliteBillsRepository implements BillsRepository {
  const SqliteBillsRepository(this._database);

  static const templatesTable = 'bill_templates';
  static const entriesTable = 'bill_entries';

  final AppDatabase _database;

  Database get _db => _database.db;

  @override
  Future<List<BillTemplate>> templates() async => [
    for (final row in await _db.query(templatesTable, orderBy: 'id')) BillTemplateRow.fromRow(row).toDomain(),
  ];

  @override
  Future<BillTemplate> insertTemplate({
    required String name,
    required BillCategory category,
    required YearMonth startMonth,
    int? dueDay,
  }) async {
    final row = BillTemplateRow(
      id: null,
      name: name,
      category: category.name,
      startMonth: startMonth.key,
      endMonth: null,
      dueDay: dueDay,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    final id = await _db.insert(templatesTable, row.toRow());
    return BillTemplate(id: id, name: name, category: category, startMonth: startMonth, dueDay: dueDay);
  }

  @override
  Future<void> deleteTemplate(int id) => _db.delete(templatesTable, where: 'id = ?', whereArgs: [id]);

  @override
  Future<void> archiveTemplate(int id, YearMonth endMonth) =>
      _db.update(templatesTable, {'end_month': endMonth.key}, where: 'id = ?', whereArgs: [id]);

  @override
  Future<Map<int, BillEntry>> entries(YearMonth month) async => {
    for (final row in await _db.query(entriesTable, where: 'month = ?', whereArgs: [month.key])) row['template_id']! as int: _entry(row),
  };

  @override
  Future<void> setPaidAt(int templateId, YearMonth month, DateTime? paidAt) =>
      _upsert(templateId, month, 'paid_at', paidAt?.toUtc().millisecondsSinceEpoch);

  @override
  Future<void> setDueDate(int templateId, YearMonth month, CalendarDate? dueDate) =>
      _upsert(templateId, month, 'due_date', dueDate?.toUtcMillis());

  @override
  Future<Map<(int, YearMonth), BillEntry>> entriesBetween(YearMonth from, YearMonth to) async => {
    for (final row in await _db.query(entriesTable, where: 'month >= ? AND month <= ?', whereArgs: [from.key, to.key]))
      (row['template_id']! as int, YearMonth.fromKey(row['month']! as int)): _entry(row),
  };

  @override
  Future<void> updateTemplate(int id, {required String name, required int? dueDay}) =>
      _db.update(templatesTable, {'name': name, 'due_day': dueDay}, where: 'id = ?', whereArgs: [id]);

  static BillEntry _entry(Map<String, Object?> row) => BillEntry(
    dueDate: switch (row['due_date']) {
      final int millis => CalendarDate.fromUtcMillis(millis),
      _ => null,
    },
    paidAt: switch (row['paid_at']) {
      final int millis => DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true),
      _ => null,
    },
  );

  // Column names are internal constants, never user input.
  Future<void> _upsert(int templateId, YearMonth month, String column, int? value) => _database.transaction((txn) async {
    await txn.rawInsert(
      'INSERT INTO $entriesTable (template_id, month, $column) VALUES (?, ?, ?) '
      'ON CONFLICT (template_id, month) DO UPDATE SET $column = excluded.$column',
      [templateId, month.key, value],
    );
    await txn.delete(
      entriesTable,
      where: 'template_id = ? AND month = ? AND due_date IS NULL AND paid_at IS NULL',
      whereArgs: [templateId, month.key],
    );
  });
}
