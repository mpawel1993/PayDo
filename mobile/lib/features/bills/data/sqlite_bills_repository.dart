import 'package:sqflite/sqflite.dart';

import '../../../core/db/app_database.dart';
import '../domain/bill_category.dart';
import '../domain/bill_template.dart';
import '../domain/bills_repository.dart';
import '../domain/year_month.dart';
import 'bill_template_row.dart';

final class SqliteBillsRepository implements BillsRepository {
  const SqliteBillsRepository(this._database);

  static const templatesTable = 'bill_templates';
  static const paymentsTable = 'bill_payments';

  final AppDatabase _database;

  Database get _db => _database.db;

  @override
  Future<List<BillTemplate>> templates() async => [
    for (final row in await _db.query(templatesTable, orderBy: 'id')) BillTemplateRow.fromRow(row).toDomain(),
  ];

  @override
  Future<BillTemplate> insertTemplate({required String name, required BillCategory category, required YearMonth startMonth}) async {
    final row = BillTemplateRow(
      id: null,
      name: name,
      category: category.name,
      startMonth: startMonth.key,
      endMonth: null,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    final id = await _db.insert(templatesTable, row.toRow());
    return BillTemplate(id: id, name: name, category: category, startMonth: startMonth);
  }

  @override
  Future<void> deleteTemplate(int id) => _db.delete(templatesTable, where: 'id = ?', whereArgs: [id]);

  @override
  Future<void> archiveTemplate(int id, YearMonth endMonth) =>
      _db.update(templatesTable, {'end_month': endMonth.key}, where: 'id = ?', whereArgs: [id]);

  @override
  Future<Set<int>> paidTemplateIds(YearMonth month) async => {
    for (final row in await _db.query(paymentsTable, columns: ['template_id'], where: 'month = ?', whereArgs: [month.key]))
      row['template_id']! as int,
  };

  @override
  Future<void> setPaid(int templateId, YearMonth month, {required bool paid, required DateTime at}) => paid
      ? _db.insert(paymentsTable, {
          'template_id': templateId,
          'month': month.key,
          'paid_at': at.millisecondsSinceEpoch,
        }, conflictAlgorithm: ConflictAlgorithm.ignore)
      : _db.delete(paymentsTable, where: 'template_id = ? AND month = ?', whereArgs: [templateId, month.key]);
}
