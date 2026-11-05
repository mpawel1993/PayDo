import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/core/db/app_database.dart';
import 'package:paydo/features/bills/data/sqlite_bills_repository.dart';
import 'package:paydo/features/bills/domain/bill_category.dart';
import 'package:paydo/features/bills/domain/bill_template.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../support/open_test_database.dart';

void main() {
  late AppDatabase db;
  late SqliteBillsRepository repository;
  final nov = YearMonth(2026, 11);
  final dec = YearMonth(2026, 12);

  setUp(() async {
    db = await openTestDatabase();
    repository = SqliteBillsRepository(db);
  });
  tearDown(() async => db.close());

  Future<BillTemplate> insert(String name, {BillCategory category = BillCategory.personal, YearMonth? start}) =>
      repository.insertTemplate(name: name, category: category, startMonth: start ?? nov);

  group('templates', () {
    test('starts empty', () async {
      expect(await repository.templates(), isEmpty);
    });

    test('insertTemplate() assigns an id and round-trips all fields', () async {
      final rent = await insert('Rent');
      final zus = await insert('ZUS', category: BillCategory.company, start: dec);

      expect(rent.id, isNot(zus.id));
      expect(rent, BillTemplate(id: rent.id, name: 'Rent', category: BillCategory.personal, startMonth: nov));
      expect(await repository.templates(), [rent, zus]);
    });

    test('stores category as TEXT and months as yyyymm INTEGER', () async {
      await insert('ZUS', category: BillCategory.company);
      final row = (await db.db.query(SqliteBillsRepository.templatesTable)).single;

      expect(row['category'], 'company');
      expect(row['start_month'], 202611);
      expect(row['end_month'], isNull);
      expect(row['created_at'], isA<int>());
    });

    test('archiveTemplate() sets the end month', () async {
      final rent = await insert('Rent');
      await repository.archiveTemplate(rent.id, dec);
      expect((await repository.templates()).single, rent.copyWith(endMonth: dec));
    });

    test('deleteTemplate() removes the template and its payments', () async {
      final rent = await insert('Rent');
      final gas = await insert('Gas');
      await repository.setPaid(rent.id, nov, paid: true, at: DateTime.utc(2026, 11, 6));

      await repository.deleteTemplate(rent.id);

      expect(await repository.templates(), [gas]);
      expect(await db.db.query(SqliteBillsRepository.paymentsTable), isEmpty);
    });
  });

  group('payments', () {
    test('nothing is paid initially', () async {
      await insert('Rent');
      expect(await repository.paidTemplateIds(nov), isEmpty);
    });

    test('setPaid(true) marks the bill paid only in that month', () async {
      final rent = await insert('Rent');
      final gas = await insert('Gas');

      await repository.setPaid(rent.id, nov, paid: true, at: DateTime.utc(2026, 11, 6, 12));

      expect(await repository.paidTemplateIds(nov), {rent.id});
      expect(await repository.paidTemplateIds(dec), isEmpty);
      expect(await repository.paidTemplateIds(nov), isNot(contains(gas.id)));
      final row = (await db.db.query(SqliteBillsRepository.paymentsTable)).single;
      expect(row, {'template_id': rent.id, 'month': 202611, 'paid_at': DateTime.utc(2026, 11, 6, 12).millisecondsSinceEpoch});
    });

    test('setPaid(true) twice keeps a single row', () async {
      final rent = await insert('Rent');
      await repository.setPaid(rent.id, nov, paid: true, at: DateTime.utc(2026, 11, 1));
      await repository.setPaid(rent.id, nov, paid: true, at: DateTime.utc(2026, 11, 2));
      expect(await db.db.query(SqliteBillsRepository.paymentsTable), hasLength(1));
    });

    test('setPaid(false) removes the payment', () async {
      final rent = await insert('Rent');
      await repository.setPaid(rent.id, nov, paid: true, at: DateTime.utc(2026, 11, 1));
      await repository.setPaid(rent.id, nov, paid: false, at: DateTime.utc(2026, 11, 2));
      expect(await repository.paidTemplateIds(nov), isEmpty);
    });

    test('a payment for an unknown template violates the foreign key', () async {
      expect(() => repository.setPaid(999, nov, paid: true, at: DateTime.utc(2026)), throwsA(anything));
    });
  });
}
