import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/db/app_database.dart';
import 'package:paydo/features/bills/application/bills_facade.dart';
import 'package:paydo/features/bills/data/sqlite_bills_repository.dart';
import 'package:paydo/features/bills/domain/bill_category.dart';
import 'package:paydo/features/bills/domain/bills_error.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../support/open_test_database.dart';

void main() {
  late AppDatabase db;
  late SqliteBillsRepository repository;
  late DateTime now;
  late BillsFacade facade;
  final oct = YearMonth(2026, 10);
  final nov = YearMonth(2026, 11);
  final dec = YearMonth(2026, 12);

  setUp(() async {
    db = await openTestDatabase();
    repository = SqliteBillsRepository(db);
    now = DateTime(2026, 11, 6, 10);
    facade = BillsFacade(repository, () => now);
  });
  tearDown(() async => db.close());

  test('currentMonth follows the clock', () {
    expect(facade.currentMonth, nov);
    now = DateTime(2027, 1, 1);
    expect(facade.currentMonth, YearMonth(2027, 1));
  });

  group('addTemplate()', () {
    test('stores a trimmed template starting in the current month', () async {
      final t = await facade.addTemplate('  Rent ', BillCategory.personal);

      expect(t.name, 'Rent');
      expect(t.category, BillCategory.personal);
      expect(t.startMonth, nov);
      expect(await facade.templates(), [t]);
    });

    test('rejects an invalid name without writing', () async {
      await expectLater(facade.addTemplate('  ', BillCategory.company), throwsA(isA<EmptyBillName>()));
      expect(await facade.templates(), isEmpty);
    });
  });

  group('removeTemplate()', () {
    test('deletes a template that started in the current month', () async {
      final t = await facade.addTemplate('Rent', BillCategory.personal);
      await facade.removeTemplate(t);
      expect(await facade.templates(), isEmpty);
    });

    test('archives a template that started earlier, keeping its history', () async {
      now = DateTime(2026, 10, 1);
      final t = await facade.addTemplate('Rent', BillCategory.personal);
      await facade.setPaid(t.id, oct, paid: true);
      now = DateTime(2026, 11, 6);

      await facade.removeTemplate(t);

      final templates = await facade.templates();
      expect(templates.single.endMonth, nov);
      expect((await facade.monthBills(oct, templates)).bills.single.paid, isTrue);
      expect((await facade.monthBills(nov, templates)).bills, isEmpty);
    });
  });

  group('monthBills() and setPaid()', () {
    test('lists the month bills with their payments', () async {
      final rent = await facade.addTemplate('Rent', BillCategory.personal);
      final zus = await facade.addTemplate('ZUS', BillCategory.company);
      await facade.setPaid(zus.id, nov, paid: true);

      final templates = await facade.templates();
      final bills = await facade.monthBills(nov, templates);

      expect(bills.month, nov);
      expect(bills.bills.map((b) => (b.template.id, b.paid)), [(rent.id, false), (zus.id, true)]);
      expect((await facade.monthBills(dec, templates)).bills.every((b) => !b.paid), isTrue);
      expect((await facade.monthBills(oct, templates)).bills, isEmpty);
    });

    test('setPaid(false) clears the payment', () async {
      final rent = await facade.addTemplate('Rent', BillCategory.personal);
      await facade.setPaid(rent.id, nov, paid: true);
      await facade.setPaid(rent.id, nov, paid: false);
      expect((await facade.monthBills(nov, await facade.templates())).bills.single.paid, isFalse);
    });
  });
}
