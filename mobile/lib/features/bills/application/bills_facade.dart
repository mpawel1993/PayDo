import '../domain/bill_category.dart';
import '../domain/bill_template.dart';
import '../domain/bills_repository.dart';
import '../domain/calendar_date.dart';
import '../domain/month_bills.dart';
import '../domain/year_month.dart';

final class BillsFacade {
  const BillsFacade(this._repository, this._now);

  final BillsRepository _repository;
  final DateTime Function() _now;

  YearMonth get currentMonth => YearMonth.fromDate(_now());

  CalendarDate get today => CalendarDate.fromDateTime(_now());

  Future<List<BillTemplate>> templates() => _repository.templates();

  Future<BillTemplate> addTemplate(String name, BillCategory category, {int? dueDay}) async => _repository.insertTemplate(
    name: BillTemplate.validateName(name),
    category: category,
    startMonth: currentMonth,
    dueDay: BillTemplate.validateDueDay(dueDay),
  );

  Future<void> updateTemplate(BillTemplate template, {required String name, required int? dueDay}) async =>
      _repository.updateTemplate(template.id, name: BillTemplate.validateName(name), dueDay: BillTemplate.validateDueDay(dueDay));

  /// Templates billed before the current month are archived (history kept); others are deleted.
  Future<void> removeTemplate(BillTemplate template) {
    final current = currentMonth;
    return template.startMonth.isBefore(current)
        ? _repository.archiveTemplate(template.id, current)
        : _repository.deleteTemplate(template.id);
  }

  Future<MonthBills> monthBills(YearMonth month, List<BillTemplate> templates) async =>
      MonthBills.build(month, templates, await _repository.entries(month));

  /// Returns the stored payment instant (UTC), or null when marked unpaid.
  Future<DateTime?> setPaid(int templateId, YearMonth month, {required bool paid}) async {
    final paidAt = paid ? _now().toUtc() : null;
    await _repository.setPaidAt(templateId, month, paidAt);
    return paidAt;
  }

  Future<void> setDueDate(int templateId, YearMonth month, CalendarDate? dueDate) => _repository.setDueDate(templateId, month, dueDate);
}
