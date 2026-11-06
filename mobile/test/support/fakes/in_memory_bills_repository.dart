import 'package:paydo/features/bills/domain/bill.dart';
import 'package:paydo/features/bills/domain/bill_category.dart';
import 'package:paydo/features/bills/domain/bill_template.dart';
import 'package:paydo/features/bills/domain/bills_repository.dart';
import 'package:paydo/features/bills/domain/calendar_date.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

final class InMemoryBillsRepository implements BillsRepository {
  InMemoryBillsRepository({List<BillTemplate> templates = const [], Map<(int, YearMonth), BillEntry> entries = const {}})
    : _templates = [...templates],
      _entries = {...entries},
      _nextId = templates.fold(0, (max, t) => t.id > max ? t.id : max) + 1;

  final List<BillTemplate> _templates;
  final Map<(int, YearMonth), BillEntry> _entries;
  int _nextId;

  List<BillTemplate> get storedTemplates => List.unmodifiable(_templates);

  BillEntry entryOf(int templateId, YearMonth month) => _entries[(templateId, month)] ?? BillEntry.empty;

  Set<int> paidIn(YearMonth month) => {
    for (final MapEntry(key: (id, m), :value) in _entries.entries)
      if (m == month && value.paidAt != null) id,
  };

  @override
  Future<List<BillTemplate>> templates() async => [..._templates];

  @override
  Future<BillTemplate> insertTemplate({
    required String name,
    required BillCategory category,
    required YearMonth startMonth,
    int? dueDay,
  }) async {
    final template = BillTemplate(id: _nextId++, name: name, category: category, startMonth: startMonth, dueDay: dueDay);
    _templates.add(template);
    return template;
  }

  @override
  Future<void> deleteTemplate(int id) async {
    _templates.removeWhere((t) => t.id == id);
    _entries.removeWhere((key, _) => key.$1 == id);
  }

  @override
  Future<void> archiveTemplate(int id, YearMonth endMonth) async {
    final i = _templates.indexWhere((t) => t.id == id);
    _templates[i] = _templates[i].copyWith(endMonth: endMonth);
  }

  @override
  Future<Map<int, BillEntry>> entries(YearMonth month) async => {
    for (final MapEntry(key: (id, m), :value) in _entries.entries)
      if (m == month) id: value,
  };

  @override
  Future<void> setPaidAt(int templateId, YearMonth month, DateTime? paidAt) async =>
      _entries[(templateId, month)] = BillEntry(dueDate: entryOf(templateId, month).dueDate, paidAt: paidAt);

  @override
  Future<void> setDueDate(int templateId, YearMonth month, CalendarDate? dueDate) async =>
      _entries[(templateId, month)] = BillEntry(dueDate: dueDate, paidAt: entryOf(templateId, month).paidAt);

  @override
  Future<void> updateTemplate(int id, {required String name, required int? dueDay}) async {
    final i = _templates.indexWhere((t) => t.id == id);
    _templates[i] = _templates[i].copyWith(name: name).withDueDay(dueDay);
  }

  @override
  Future<Map<(int, YearMonth), BillEntry>> entriesBetween(YearMonth from, YearMonth to) async => {
    for (final e in _entries.entries)
      if (!e.key.$2.isBefore(from) && !e.key.$2.isAfter(to)) e.key: e.value,
  };
}
