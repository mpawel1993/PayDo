import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/bills/domain/bill_template.dart';
import 'package:paydo/features/bills/domain/bills_error.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../support/builders/bill_template_builder.dart';

void main() {
  group('validateName()', () {
    test('trims the name', () {
      expect(BillTemplate.validateName('  Rent  '), 'Rent');
    });

    test('rejects blank names', () {
      expect(() => BillTemplate.validateName(''), throwsA(isA<EmptyBillName>()));
      expect(() => BillTemplate.validateName('   '), throwsA(isA<EmptyBillName>()));
    });

    test('rejects names longer than maxNameLength', () {
      expect(BillTemplate.validateName('a' * BillTemplate.maxNameLength), hasLength(BillTemplate.maxNameLength));
      expect(() => BillTemplate.validateName('a' * (BillTemplate.maxNameLength + 1)), throwsA(isA<BillNameTooLong>()));
    });
  });

  group('isActiveIn()', () {
    test('is active from the start month onwards when not archived', () {
      final t = BillTemplateBuilder().startingAt(YearMonth(2026, 5)).build();
      expect(t.isActiveIn(YearMonth(2026, 4)), isFalse);
      expect(t.isActiveIn(YearMonth(2026, 5)), isTrue);
      expect(t.isActiveIn(YearMonth(2030, 1)), isTrue);
      expect(t.isArchived, isFalse);
    });

    test('is not active from the end month onwards when archived', () {
      final t = BillTemplateBuilder().startingAt(YearMonth(2026, 5)).endingAt(YearMonth(2026, 8)).build();
      expect(t.isActiveIn(YearMonth(2026, 7)), isTrue);
      expect(t.isActiveIn(YearMonth(2026, 8)), isFalse);
      expect(t.isArchived, isTrue);
    });
  });

  test('copyWith() and value equality', () {
    final t = BillTemplateBuilder().withName('Gas').build();
    expect(t.copyWith(), t);
    expect(t.copyWith(name: 'Water'), BillTemplateBuilder().withName('Water').build());
    expect(t.copyWith(name: 'Water'), isNot(t));
  });
}
