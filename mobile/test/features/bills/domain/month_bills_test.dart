import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/bills/domain/bill.dart';
import 'package:paydo/features/bills/domain/bill_category.dart';
import 'package:paydo/features/bills/domain/month_bills.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../support/builders/bill_template_builder.dart';

void main() {
  final month = YearMonth(2026, 11);
  final rent = BillTemplateBuilder().withId(1).withName('Rent').build();
  final zus = BillTemplateBuilder().withId(2).withName('ZUS').inCategory(BillCategory.company).build();
  final internet = BillTemplateBuilder().withId(3).withName('Internet').build();
  final future = BillTemplateBuilder().withId(4).startingAt(YearMonth(2026, 12)).build();
  final archived = BillTemplateBuilder().withId(5).endingAt(month).build();

  test('build() keeps only templates active in the month, sorted by name, with their payment', () {
    final bills = MonthBills.build(month, [rent, zus, internet, future, archived], {1});

    expect(bills.month, month);
    expect(bills.bills, [
      Bill(template: internet, month: month, paid: false),
      Bill(template: rent, month: month, paid: true),
      Bill(template: zus, month: month, paid: false),
    ]);
  });

  test('build() sorts names case-insensitively', () {
    final a = BillTemplateBuilder().withId(1).withName('b').build();
    final b = BillTemplateBuilder().withId(2).withName('A').build();
    expect(MonthBills.build(month, [a, b], {}).bills.map((b) => b.template.name), ['A', 'b']);
  });

  test('inCategory() filters bills by category', () {
    final bills = MonthBills.build(month, [rent, zus, internet], {});
    expect(bills.inCategory(BillCategory.personal).map((b) => b.template.id), [3, 1]);
    expect(bills.inCategory(BillCategory.company).map((b) => b.template.id), [2]);
  });

  test('withPaid() returns a copy with one bill toggled', () {
    final bills = MonthBills.build(month, [rent, zus], {});
    final updated = bills.withPaid(2, paid: true);

    expect(updated.bills.firstWhere((b) => b.template.id == 2).paid, isTrue);
    expect(updated.bills.firstWhere((b) => b.template.id == 1).paid, isFalse);
    expect(bills.bills.every((b) => !b.paid), isTrue);
  });

  test('has value equality', () {
    expect(MonthBills.build(month, [rent], {1}), MonthBills.build(month, [rent], {1}));
    expect(MonthBills.build(month, [rent], {1}), isNot(MonthBills.build(month, [rent], {})));
  });
}
