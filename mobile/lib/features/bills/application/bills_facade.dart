import '../domain/bill_category.dart';
import '../domain/bill_template.dart';
import '../domain/bills_repository.dart';
import '../domain/month_bills.dart';
import '../domain/year_month.dart';

final class BillsFacade {
  const BillsFacade(this._repository, this._now);

  final BillsRepository _repository;
  final DateTime Function() _now;

  YearMonth get currentMonth => YearMonth.fromDate(_now());

  Future<List<BillTemplate>> templates() => _repository.templates();

  Future<BillTemplate> addTemplate(String name, BillCategory category) async =>
      _repository.insertTemplate(name: BillTemplate.validateName(name), category: category, startMonth: currentMonth);

  /// Templates billed before the current month are archived (history kept); others are deleted.
  Future<void> removeTemplate(BillTemplate template) {
    final current = currentMonth;
    return template.startMonth.isBefore(current)
        ? _repository.archiveTemplate(template.id, current)
        : _repository.deleteTemplate(template.id);
  }

  Future<MonthBills> monthBills(YearMonth month, List<BillTemplate> templates) async =>
      MonthBills.build(month, templates, await _repository.paidTemplateIds(month));

  Future<void> setPaid(int templateId, YearMonth month, {required bool paid}) =>
      _repository.setPaid(templateId, month, paid: paid, at: _now().toUtc());
}
