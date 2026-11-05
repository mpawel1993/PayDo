import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/bills/application/bills_state.dart';
import 'package:paydo/features/bills/domain/bill_category.dart';
import 'package:paydo/features/bills/domain/billing_window.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../support/builders/bill_template_builder.dart';
import '../../../support/fakes/in_memory_bills_repository.dart';
import '../../../support/overrides.dart';

final _now = DateTime(2026, 11, 6);
final _nov = YearMonth(2026, 11);

ProviderContainer _container([InMemoryBillsRepository? repository]) =>
    ProviderContainer.test(overrides: [...billsOverrides(repository ?? InMemoryBillsRepository()), clockOverride(_now)]);

void main() {
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

  group('monthBillsState', () {
    test('loads the bills of the given month', () async {
      final rent = BillTemplateBuilder().withId(1).withName('Rent').build();
      final container = _container(
        InMemoryBillsRepository(
          templates: [rent],
          paid: {
            _nov: {1},
          },
        ),
      );

      final nov = await container.read(monthBillsState(_nov).future);
      final dec = await container.read(monthBillsState(YearMonth(2026, 12)).future);

      expect(nov.bills.single.paid, isTrue);
      expect(dec.bills.single.paid, isFalse);
    });

    test('togglePaid() persists and flips only that month', () async {
      final repository = InMemoryBillsRepository(templates: [BillTemplateBuilder().withId(1).build()]);
      final container = _container(repository);
      await container.read(monthBillsState(_nov).future);

      await container.read(monthBillsState(_nov).notifier).togglePaid(1);
      expect(container.read(monthBillsState(_nov)).value!.bills.single.paid, isTrue);
      expect(repository.paidIn(_nov), {1});

      await container.read(monthBillsState(_nov).notifier).togglePaid(1);
      expect(container.read(monthBillsState(_nov)).value!.bills.single.paid, isFalse);
      expect(repository.paidIn(_nov), isEmpty);
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
}
