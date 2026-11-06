import 'bill.dart';
import 'bill_category.dart';
import 'bill_template.dart';
import 'calendar_date.dart';
import 'year_month.dart';

abstract interface class BillsRepository {
  Future<List<BillTemplate>> templates();

  Future<BillTemplate> insertTemplate({required String name, required BillCategory category, required YearMonth startMonth, int? dueDay});

  Future<void> updateTemplate(int id, {required String name, required int? dueDay});

  Future<void> deleteTemplate(int id);

  Future<void> archiveTemplate(int id, YearMonth endMonth);

  /// Entries of [month] keyed by template id; templates without an entry are absent.
  Future<Map<int, BillEntry>> entries(YearMonth month);

  /// Entries of all months in [from]..[to] keyed by (template id, month).
  Future<Map<(int, YearMonth), BillEntry>> entriesBetween(YearMonth from, YearMonth to);

  /// [paidAt] null marks the bill unpaid.
  Future<void> setPaidAt(int templateId, YearMonth month, DateTime? paidAt);

  /// [dueDate] null clears the due date.
  Future<void> setDueDate(int templateId, YearMonth month, CalendarDate? dueDate);
}
