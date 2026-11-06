import 'package:collection/collection.dart';

import 'bill.dart';
import 'bill_category.dart';
import 'bill_template.dart';
import 'year_month.dart';

final class MonthBills {
  const MonthBills(this.month, this.bills);

  factory MonthBills.build(YearMonth month, Iterable<BillTemplate> templates, Map<int, BillEntry> entries) => MonthBills(month, [
    for (final t in templates.where((t) => t.isActiveIn(month)).sorted(_byName))
      Bill(template: t, month: month, entry: entries[t.id] ?? BillEntry.empty),
  ]);

  static int _byName(BillTemplate a, BillTemplate b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());

  final YearMonth month;
  final List<Bill> bills;

  Bill? byTemplateId(int templateId) => bills.firstWhereOrNull((b) => b.template.id == templateId);

  List<Bill> inCategory(BillCategory category) => [...bills.where((b) => b.template.category == category)];

  MonthBills updated(int templateId, Bill Function(Bill bill) update) =>
      MonthBills(month, [for (final b in bills) b.template.id == templateId ? update(b) : b]);

  @override
  bool operator ==(Object other) => other is MonthBills && other.month == month && const ListEquality<Bill>().equals(other.bills, bills);

  @override
  int get hashCode => Object.hash(month, Object.hashAll(bills));
}
