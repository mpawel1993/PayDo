import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/bills/domain/bill.dart';
import 'package:paydo/features/bills/domain/bill_category.dart';
import 'package:paydo/features/bills/domain/calendar_date.dart';
import 'package:paydo/features/bills/domain/month_bills.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../support/builders/bill_template_builder.dart';

void main() {
  final month = YearMonth(2026, 11);
  final paid = BillEntry(paidAt: DateTime.utc(2026, 11, 2));
  final rent = BillTemplateBuilder().withId(1).withName('Rent').build();
  final zus = BillTemplateBuilder().withId(2).withName('ZUS').inCategory(BillCategory.company).build();
  final internet = BillTemplateBuilder().withId(3).withName('Internet').build();
  final future = BillTemplateBuilder().withId(4).startingAt(YearMonth(2026, 12)).build();
  final archived = BillTemplateBuilder().withId(5).endingAt(month).build();

  test('build() keeps only templates active in the month, sorted by name, with their entries', () {
    final bills = MonthBills.build(month, [rent, zus, internet, future, archived], {1: paid, 5: paid});

    expect(bills.month, month);
    expect(bills.bills, [
      Bill(template: internet, month: month),
      Bill(template: rent, month: month, entry: paid),
      Bill(template: zus, month: month),
    ]);
  });

  test('build() sorts names case-insensitively', () {
    final a = BillTemplateBuilder().withId(1).withName('b').build();
    final b = BillTemplateBuilder().withId(2).withName('A').build();
    expect(MonthBills.build(month, [a, b], {}).bills.map((b) => b.template.name), ['A', 'b']);
  });

  test('inCategory() and byTemplateId()', () {
    final bills = MonthBills.build(month, [rent, zus, internet], {});
    expect(bills.inCategory(BillCategory.personal).map((b) => b.template.id), [3, 1]);
    expect(bills.inCategory(BillCategory.company).map((b) => b.template.id), [2]);
    expect(bills.byTemplateId(2)?.template, zus);
    expect(bills.byTemplateId(99), isNull);
  });

  test('updated() returns a copy with one bill changed', () {
    final bills = MonthBills.build(month, [rent, zus], {});
    final due = CalendarDate(2026, 11, 20);
    final updated = bills.updated(2, (b) => b.withDueDate(due));

    expect(updated.byTemplateId(2)?.dueDate, due);
    expect(updated.byTemplateId(1)?.dueDate, isNull);
    expect(bills.byTemplateId(2)?.dueDate, isNull);
  });

  test('has value equality', () {
    expect(MonthBills.build(month, [rent], {1: paid}), MonthBills.build(month, [rent], {1: paid}));
    expect(MonthBills.build(month, [rent], {1: paid}), isNot(MonthBills.build(month, [rent], {})));
  });
}
