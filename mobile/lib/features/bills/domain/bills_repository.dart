import 'bill_category.dart';
import 'bill_template.dart';
import 'year_month.dart';

abstract interface class BillsRepository {
  Future<List<BillTemplate>> templates();

  Future<BillTemplate> insertTemplate({required String name, required BillCategory category, required YearMonth startMonth});

  Future<void> deleteTemplate(int id);

  Future<void> archiveTemplate(int id, YearMonth endMonth);

  Future<Set<int>> paidTemplateIds(YearMonth month);

  Future<void> setPaid(int templateId, YearMonth month, {required bool paid, required DateTime at});
}
