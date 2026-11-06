import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:paydo/core/db/app_database.dart';
import 'package:paydo/core/db/migrations.dart';
import 'package:paydo/features/bills/data/sqlite_bills_repository.dart';
import 'package:paydo/features/bills/domain/bill.dart';
import 'package:paydo/features/bills/domain/bill_category.dart';
import 'package:paydo/features/bills/domain/bill_template.dart';
import 'package:paydo/features/bills/domain/calendar_date.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../support/open_test_database.dart';

void main() {
  late AppDatabase db;
  late SqliteBillsRepository repository;
  final nov = YearMonth(2026, 11);
  final dec = YearMonth(2026, 12);
  final paidAt = DateTime.utc(2026, 11, 6, 12);
  final due = CalendarDate(2026, 11, 20);
  final now = DateTime.utc(2026, 11, 6, 9);

  setUp(() async {
    db = await openTestDatabase();
    repository = SqliteBillsRepository(db, now: () => now);
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
      expect(row['created_at'], now.millisecondsSinceEpoch);
    });

    test('archiveTemplate() sets the end month', () async {
      final rent = await insert('Rent');
      await repository.archiveTemplate(rent.id, dec);
      expect((await repository.templates()).single, rent.copyWith(endMonth: dec));
    });

    test('deleteTemplate() removes the template and its entries', () async {
      final rent = await insert('Rent');
      final gas = await insert('Gas');
      await repository.setPaidAt(rent.id, nov, paidAt);

      await repository.deleteTemplate(rent.id);

      expect(await repository.templates(), [gas]);
      expect(await db.db.query(SqliteBillsRepository.entriesTable), isEmpty);
    });
  });

  group('entries', () {
    test('no entries initially', () async {
      await insert('Rent');
      expect(await repository.entries(nov), isEmpty);
    });

    test('setPaidAt() stores the payment instant only in that month', () async {
      final rent = await insert('Rent');

      await repository.setPaidAt(rent.id, nov, paidAt);

      expect(await repository.entries(nov), {rent.id: BillEntry(paidAt: paidAt)});
      expect(await repository.entries(dec), isEmpty);
      expect((await db.db.query(SqliteBillsRepository.entriesTable)).single, {
        'template_id': rent.id,
        'month': 202611,
        'due_date': null,
        'paid_at': paidAt.millisecondsSinceEpoch,
      });
    });

    test('paidAt is returned as UTC', () async {
      final rent = await insert('Rent');
      await repository.setPaidAt(rent.id, nov, paidAt);
      expect((await repository.entries(nov))[rent.id]!.paidAt!.isUtc, isTrue);
    });

    test('setDueDate() stores UTC midnight of the day and keeps the payment', () async {
      final rent = await insert('Rent');
      await repository.setPaidAt(rent.id, nov, paidAt);

      await repository.setDueDate(rent.id, nov, due);

      expect(await repository.entries(nov), {rent.id: BillEntry(dueDate: due, paidAt: paidAt)});
      expect((await db.db.query(SqliteBillsRepository.entriesTable)).single['due_date'], DateTime.utc(2026, 11, 20).millisecondsSinceEpoch);
    });

    test('null values clear the payment or the due date in a single row', () async {
      final rent = await insert('Rent');
      await repository.setDueDate(rent.id, nov, due);
      await repository.setPaidAt(rent.id, nov, paidAt);

      await repository.setPaidAt(rent.id, nov, null);
      expect(await repository.entries(nov), {rent.id: BillEntry(dueDate: due)});

      await repository.setDueDate(rent.id, nov, null);
      expect((await repository.entries(nov))[rent.id], anyOf(isNull, BillEntry.empty));
      expect(await db.db.query(SqliteBillsRepository.entriesTable), hasLength(lessThanOrEqualTo(1)));
    });

    test('an entry for an unknown template violates the foreign key', () async {
      expect(() => repository.setPaidAt(999, nov, paidAt), throwsA(anything));
    });
  });

  test('migration 4 keeps payments made before due dates existed', () async {
    final dir = await Directory.systemTemp.createTemp('paydo_bills_migration');
    addTearDown(() => dir.delete(recursive: true));
    final path = p.join(dir.path, 'bills.db');

    final v3 = await openTestDatabase(path: path, migrations: appMigrations.sublist(0, 3));
    await v3.db.insert('bill_templates', {'id': 1, 'name': 'Rent', 'category': 'personal', 'start_month': 202611, 'created_at': 0});
    await v3.db.insert('bill_payments', {'template_id': 1, 'month': 202611, 'paid_at': paidAt.millisecondsSinceEpoch});
    await v3.close();

    final v4 = await openTestDatabase(path: path);
    addTearDown(v4.close);

    expect(await SqliteBillsRepository(v4).entries(nov), {1: BillEntry(paidAt: paidAt)});
    expect(await v4.db.query('sqlite_master', where: 'name = ?', whereArgs: ['bill_payments']), isEmpty);
  });

  group('template due day and editing', () {
    test('insertTemplate() stores an optional due day', () async {
      final rent = await repository.insertTemplate(name: 'Rent', category: BillCategory.personal, startMonth: nov, dueDay: 10);
      expect(rent.dueDay, 10);
      expect((await repository.templates()).single, rent);
      expect((await db.db.query(SqliteBillsRepository.templatesTable)).single['due_day'], 10);
    });

    test('updateTemplate() changes the name and due day only', () async {
      final rent = await repository.insertTemplate(name: 'Rent', category: BillCategory.personal, startMonth: nov, dueDay: 10);

      await repository.updateTemplate(rent.id, name: 'Czynsz', dueDay: null);
      expect((await repository.templates()).single, rent.copyWith(name: 'Czynsz').withDueDay(null));

      await repository.updateTemplate(rent.id, name: 'Czynsz', dueDay: 15);
      expect((await repository.templates()).single.dueDay, 15);
    });
  });

  test('entriesBetween() returns entries of the inclusive month range', () async {
    final rent = await insert('Rent', start: YearMonth(2026, 9));
    await repository.setPaidAt(rent.id, YearMonth(2026, 9), paidAt);
    await repository.setDueDate(rent.id, nov, due);
    await repository.setPaidAt(rent.id, dec, paidAt);

    expect(await repository.entriesBetween(YearMonth(2026, 10), nov), {(rent.id, nov): BillEntry(dueDate: due)});
    expect(await repository.entriesBetween(YearMonth(2026, 9), dec), hasLength(3));
  });

  test('migration 5 adds an empty due day to existing templates', () async {
    final dir = await Directory.systemTemp.createTemp('paydo_bills_migration5');
    addTearDown(() => dir.delete(recursive: true));
    final path = p.join(dir.path, 'bills.db');

    final v4 = await openTestDatabase(path: path, migrations: appMigrations.sublist(0, 4));
    await v4.db.insert('bill_templates', {'id': 1, 'name': 'Rent', 'category': 'personal', 'start_month': 202611, 'created_at': 0});
    await v4.close();

    final v5 = await openTestDatabase(path: path);
    addTearDown(v5.close);

    expect((await SqliteBillsRepository(v5).templates()).single.dueDay, isNull);
  });
}
