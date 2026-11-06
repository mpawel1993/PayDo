import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:paydo/features/bills/application/bills_state.dart';
import 'package:paydo/features/bills/domain/bill.dart';
import 'package:paydo/features/bills/domain/bill_category.dart';
import 'package:paydo/features/bills/domain/calendar_date.dart';
import 'package:paydo/features/bills/domain/billing_window.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../support/builders/bill_template_builder.dart';
import '../../../support/fakes/in_memory_bills_repository.dart';
import '../../../support/fakes/in_memory_settings_repository.dart';
import '../../../support/fakes/recording_notification_scheduler.dart';
import '../../../support/overrides.dart';

final _now = DateTime(2026, 11, 6);
final _nov = YearMonth(2026, 11);

ProviderContainer _container([InMemoryBillsRepository? repository]) =>
    ProviderContainer.test(overrides: [...billsOverrides(repository ?? InMemoryBillsRepository()), clockOverride(_now)]);

void main() {
  setUpAll(initializeDateFormatting);

  group('month atoms', () {
    test('currentMonthState and the window follow the clock', () {
      final container = _container();
      expect(container.read(currentMonthState), _nov);
      expect(container.read(billingWindowState), BillingWindow(_nov));
    });

    test('selectedMonthState starts at the current month', () {
      expect(_container().read(selectedMonthState), _nov);
    });

    test('previous() / next() move by one month and stop at the window bounds', () {
      final container = _container();
      final notifier = container.read(selectedMonthState.notifier);

      notifier.previous();
      expect(container.read(selectedMonthState), YearMonth(2026, 10));
      notifier.next();
      notifier.next();
      expect(container.read(selectedMonthState), YearMonth(2026, 12));

      for (var i = 0; i < 30; i++) {
        notifier.next();
      }
      expect(container.read(selectedMonthState), YearMonth(2027, 11));
      for (var i = 0; i < 30; i++) {
        notifier.previous();
      }
      expect(container.read(selectedMonthState), YearMonth(2025, 11));
    });

    test('select() ignores months outside the window', () {
      final container = _container();
      container.read(selectedMonthState.notifier).select(YearMonth(2027, 2));
      expect(container.read(selectedMonthState), YearMonth(2027, 2));
      container.read(selectedMonthState.notifier).select(YearMonth(2030, 1));
      expect(container.read(selectedMonthState), YearMonth(2027, 2));
    });
  });

  group('billTemplatesState', () {
    test('loads all templates and exposes the active ones', () async {
      final active = BillTemplateBuilder().withId(1).withName('Rent').build();
      final archived = BillTemplateBuilder().withId(2).withName('Old').endingAt(_nov).build();
      final container = _container(InMemoryBillsRepository(templates: [active, archived]));

      expect(await container.read(billTemplatesState.future), [active, archived]);
      expect(container.read(activeBillTemplatesState).value, [active]);
    });

    test('add() persists and updates the state', () async {
      final repository = InMemoryBillsRepository();
      final container = _container(repository);
      await container.read(billTemplatesState.future);

      await container.read(billTemplatesState.notifier).add('Rent', BillCategory.company);

      final templates = container.read(billTemplatesState).value!;
      expect(templates.single.name, 'Rent');
      expect(templates.single.category, BillCategory.company);
      expect(templates.single.startMonth, _nov);
      expect(repository.storedTemplates, templates);
    });

    test('remove() deletes or archives through the facade', () async {
      final old = BillTemplateBuilder().withId(1).startingAt(YearMonth(2026, 1)).build();
      final fresh = BillTemplateBuilder().withId(2).startingAt(_nov).build();
      final container = _container(InMemoryBillsRepository(templates: [old, fresh]));
      await container.read(billTemplatesState.future);

      await container.read(billTemplatesState.notifier).remove(old);
      await container.read(billTemplatesState.notifier).remove(fresh);

      expect(container.read(billTemplatesState).value, [old.copyWith(endMonth: _nov)]);
      expect(container.read(activeBillTemplatesState).value, isEmpty);
    });
  });

  test('todayState follows the clock', () {
    expect(_container().read(todayState), CalendarDate(2026, 11, 6));
  });

  group('monthBillsState', () {
    test('loads the bills of the given month', () async {
      final rent = BillTemplateBuilder().withId(1).withName('Rent').build();
      final container = _container(
        InMemoryBillsRepository(
          templates: [rent],
          entries: {(1, _nov): BillEntry(paidAt: DateTime.utc(2026, 11, 2))},
        ),
      );

      final nov = await container.read(monthBillsState(_nov).future);
      final dec = await container.read(monthBillsState(YearMonth(2026, 12)).future);

      expect(nov.bills.single.paid, isTrue);
      expect(dec.bills.single.paid, isFalse);
    });

    test('togglePaid() saves the payment moment and flips only that month', () async {
      final repository = InMemoryBillsRepository(templates: [BillTemplateBuilder().withId(1).build()]);
      final container = _container(repository);
      await container.read(monthBillsState(_nov).future);

      await container.read(monthBillsState(_nov).notifier).togglePaid(1);
      expect(container.read(monthBillsState(_nov)).value!.bills.single.paidAt, _now.toUtc());
      expect(repository.entryOf(1, _nov).paidAt, _now.toUtc());

      await container.read(monthBillsState(_nov).notifier).togglePaid(1);
      expect(container.read(monthBillsState(_nov)).value!.bills.single.paid, isFalse);
      expect(repository.paidIn(_nov), isEmpty);
    });

    test('setDueDate() persists and updates the bill', () async {
      final repository = InMemoryBillsRepository(templates: [BillTemplateBuilder().withId(1).build()]);
      final container = _container(repository);
      await container.read(monthBillsState(_nov).future);

      await container.read(monthBillsState(_nov).notifier).setDueDate(1, CalendarDate(2026, 11, 20));

      expect(container.read(monthBillsState(_nov)).value!.bills.single.dueDate, CalendarDate(2026, 11, 20));
      expect(repository.entryOf(1, _nov).dueDate, CalendarDate(2026, 11, 20));
    });

    test('reloads when templates change', () async {
      final container = _container();
      final sub = container.listen(monthBillsState(_nov), (_, _) {});
      addTearDown(sub.close);
      expect((await container.read(monthBillsState(_nov).future)).bills, isEmpty);

      await container.read(billTemplatesState.notifier).add('Rent', BillCategory.personal);

      expect((await container.read(monthBillsState(_nov).future)).bills.single.template.name, 'Rent');
    });
  });

  group('template editing', () {
    test('add() passes the due day; edit() updates name and due day', () async {
      final repository = InMemoryBillsRepository();
      final container = _container(repository);
      await container.read(billTemplatesState.future);

      await container.read(billTemplatesState.notifier).add('Rent', BillCategory.personal, dueDay: 10);
      final added = container.read(billTemplatesState).value!.single;
      expect(added.dueDay, 10);

      await container.read(billTemplatesState.notifier).edit(added, name: 'Czynsz', dueDay: 15);
      expect(container.read(billTemplatesState).value!.single, added.copyWith(name: 'Czynsz').withDueDay(15));
      expect(repository.storedTemplates.single.dueDay, 15);
    });
  });

  group('reminderSyncState', () {
    ProviderContainer container(InMemoryBillsRepository repository, RecordingNotificationScheduler scheduler) {
      final c = ProviderContainer.test(
        overrides: [
          ...billsOverrides(repository, scheduler: scheduler),
          ...settingsOverrides(InMemorySettingsRepository()),
          clockOverride(_now),
        ],
      );
      c.listen(reminderSyncState, (_, _) {});
      return c;
    }

    test('schedules Polish reminders for overdue bills on start', () async {
      final scheduler = RecordingNotificationScheduler();
      final c = container(
        InMemoryBillsRepository(
          templates: [BillTemplateBuilder().withId(1).withName('Czynsz').build()],
          entries: {(1, _nov): BillEntry(dueDate: CalendarDate(2026, 11, 5))},
        ),
        scheduler,
      );

      await c.read(reminderSyncState.future);

      expect(scheduler.scheduled, isNotEmpty);
      expect(scheduler.scheduled.first.title, 'Nieopłacony rachunek');
      expect(scheduler.scheduled.every((n) => n.at.isAfter(_now)), isTrue);
    });

    test('marking the bill paid cancels its reminders; setting a past due date creates them', () async {
      final scheduler = RecordingNotificationScheduler();
      final c = container(InMemoryBillsRepository(templates: [BillTemplateBuilder().withId(1).build()]), scheduler);
      await c.read(reminderSyncState.future);
      expect(scheduler.scheduled, isEmpty);
      await c.read(monthBillsState(_nov).future);

      await c.read(monthBillsState(_nov).notifier).setDueDate(1, CalendarDate(2026, 11, 1));
      await c.read(reminderSyncState.future);
      expect(scheduler.scheduled, isNotEmpty);

      await c.read(monthBillsState(_nov).notifier).togglePaid(1);
      await c.read(reminderSyncState.future);
      expect(scheduler.scheduled, isEmpty);
    });

    test('editing the template due day re-plans reminders', () async {
      final scheduler = RecordingNotificationScheduler();
      final rent = BillTemplateBuilder().withId(1).startingAt(_nov).build();
      final c = container(InMemoryBillsRepository(templates: [rent]), scheduler);
      await c.read(reminderSyncState.future);
      await c.read(billTemplatesState.future);
      expect(scheduler.scheduled, isEmpty);

      await c.read(billTemplatesState.notifier).edit(rent, name: rent.name, dueDay: 1);
      await c.read(reminderSyncState.future);

      expect(scheduler.scheduled, isNotEmpty);
    });

    test('removing a template re-plans reminders', () async {
      final scheduler = RecordingNotificationScheduler();
      final old = BillTemplateBuilder().withId(1).startingAt(YearMonth(2026, 1)).build();
      final c = container(
        InMemoryBillsRepository(
          templates: [old],
          entries: {(1, _nov): BillEntry(dueDate: CalendarDate(2026, 11, 1))},
        ),
        scheduler,
      );
      await c.read(reminderSyncState.future);
      await c.read(billTemplatesState.future);
      expect(scheduler.scheduled, isNotEmpty);

      await c.read(billTemplatesState.notifier).remove(old);
      await c.read(reminderSyncState.future);

      expect(scheduler.scheduled, isEmpty);
    });
  });
}
