import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/bills/domain/bill.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../support/builders/bill_template_builder.dart';

void main() {
  final current = YearMonth(2026, 11);
  Bill bill(YearMonth month, {bool paid = false}) => Bill(template: BillTemplateBuilder().build(), month: month, paid: paid);

  test('a paid bill is paid in any month', () {
    expect(bill(YearMonth(2026, 1), paid: true).statusAt(current), BillStatus.paid);
    expect(bill(YearMonth(2027, 1), paid: true).statusAt(current), BillStatus.paid);
  });

  test('an unpaid bill from a past month is overdue', () {
    expect(bill(YearMonth(2026, 10)).statusAt(current), BillStatus.overdue);
  });

  test('an unpaid bill of the current or a future month is due', () {
    expect(bill(current).statusAt(current), BillStatus.due);
    expect(bill(YearMonth(2026, 12)).statusAt(current), BillStatus.due);
  });

  test('copyWith(paid:) toggles the payment', () {
    expect(bill(current).copyWith(paid: true), bill(current, paid: true));
  });
}
