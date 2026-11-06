import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/bills/data/bill_template_row.dart';
import 'package:paydo/features/bills/domain/bill_category.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../support/builders/bill_template_builder.dart';

void main() {
  final createdAt = DateTime.utc(2026, 11, 6);

  test('maps a domain template to a row and back', () {
    final template = BillTemplateBuilder()
        .withId(7)
        .withName('ZUS')
        .inCategory(BillCategory.company)
        .startingAt(YearMonth(2026, 3))
        .endingAt(YearMonth(2026, 11))
        .withDueDay(10)
        .build();

    final row = BillTemplateRow.fromDomain(template, createdAt: createdAt).toRow();

    expect(row, {
      'id': 7,
      'name': 'ZUS',
      'category': 'company',
      'start_month': 202603,
      'end_month': 202611,
      'due_day': 10,
      'created_at': createdAt.millisecondsSinceEpoch,
    });
    expect(BillTemplateRow.fromRow(row).toDomain(), template);
  });

  test('a null end month means an active template', () {
    final row = BillTemplateRow.fromRow({
      'id': 1,
      'name': 'Rent',
      'category': 'personal',
      'start_month': 202611,
      'end_month': null,
      'created_at': 0,
    });
    expect(row.toDomain().endMonth, isNull);
  });

  test('an unknown category is a data error', () {
    final row = BillTemplateRow.fromRow({
      'id': 1,
      'name': 'Rent',
      'category': 'x',
      'start_month': 202611,
      'end_month': null,
      'created_at': 0,
    });
    expect(row.toDomain, throwsStateError);
  });
}
