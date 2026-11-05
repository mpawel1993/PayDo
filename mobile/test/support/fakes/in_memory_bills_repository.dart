import 'package:paydo/features/bills/domain/bill_category.dart';
import 'package:paydo/features/bills/domain/bill_template.dart';
import 'package:paydo/features/bills/domain/bills_repository.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

final class InMemoryBillsRepository implements BillsRepository {
  InMemoryBillsRepository({List<BillTemplate> templates = const [], Map<YearMonth, Set<int>> paid = const {}})
    : _templates = [...templates],
      _paid = {
        for (final e in paid.entries) e.key: {...e.value},
      },
      _nextId = templates.fold(0, (max, t) => t.id > max ? t.id : max) + 1;

  final List<BillTemplate> _templates;
  final Map<YearMonth, Set<int>> _paid;
  int _nextId;

  List<BillTemplate> get storedTemplates => List.unmodifiable(_templates);

  Set<int> paidIn(YearMonth month) => {...?_paid[month]};

  @override
  Future<List<BillTemplate>> templates() async => [..._templates];

  @override
  Future<BillTemplate> insertTemplate({required String name, required BillCategory category, required YearMonth startMonth}) async {
    final template = BillTemplate(id: _nextId++, name: name, category: category, startMonth: startMonth);
    _templates.add(template);
    return template;
  }

  @override
  Future<void> deleteTemplate(int id) async {
    _templates.removeWhere((t) => t.id == id);
    for (final ids in _paid.values) {
      ids.remove(id);
    }
  }

  @override
  Future<void> archiveTemplate(int id, YearMonth endMonth) async {
    final i = _templates.indexWhere((t) => t.id == id);
    _templates[i] = _templates[i].copyWith(endMonth: endMonth);
  }

  @override
  Future<Set<int>> paidTemplateIds(YearMonth month) async => paidIn(month);

  @override
  Future<void> setPaid(int templateId, YearMonth month, {required bool paid, required DateTime at}) async {
    final ids = _paid.putIfAbsent(month, () => {});
    paid ? ids.add(templateId) : ids.remove(templateId);
  }
}
