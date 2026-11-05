import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/clock_state.dart';
import '../domain/bill_category.dart';
import '../domain/bill_template.dart';
import '../domain/billing_window.dart';
import '../domain/month_bills.dart';
import '../domain/year_month.dart';
import 'bills_providers.dart';

final currentMonthState = Provider<YearMonth>((ref) => YearMonth.fromDate(ref.watch(clockState)()));

final billingWindowState = Provider<BillingWindow>((ref) => BillingWindow(ref.watch(currentMonthState)));

final selectedMonthState = NotifierProvider<SelectedMonthNotifier, YearMonth>(SelectedMonthNotifier.new);

class SelectedMonthNotifier extends Notifier<YearMonth> {
  @override
  YearMonth build() => ref.watch(currentMonthState);

  void select(YearMonth month) {
    if (ref.read(billingWindowState).contains(month)) state = month;
  }

  void previous() => select(state.addMonths(-1));

  void next() => select(state.addMonths(1));
}

final billTemplatesState = AsyncNotifierProvider<BillTemplatesNotifier, List<BillTemplate>>(BillTemplatesNotifier.new);

class BillTemplatesNotifier extends AsyncNotifier<List<BillTemplate>> {
  @override
  Future<List<BillTemplate>> build() async => (await ref.watch(billsFacadeProvider.future)).templates();

  Future<void> add(String name, BillCategory category) async {
    final facade = await ref.read(billsFacadeProvider.future);
    await facade.addTemplate(name, category);
    state = AsyncData(await facade.templates());
  }

  Future<void> remove(BillTemplate template) async {
    final facade = await ref.read(billsFacadeProvider.future);
    await facade.removeTemplate(template);
    state = AsyncData(await facade.templates());
  }
}

final activeBillTemplatesState = Provider<AsyncValue<List<BillTemplate>>>(
  (ref) => ref.watch(billTemplatesState).whenData((templates) => [...templates.where((t) => !t.isArchived)]),
);

final monthBillsState = AsyncNotifierProvider.family<MonthBillsNotifier, MonthBills, YearMonth>(MonthBillsNotifier.new);

class MonthBillsNotifier extends AsyncNotifier<MonthBills> {
  MonthBillsNotifier(this.month);

  final YearMonth month;

  @override
  Future<MonthBills> build() async {
    final templates = await ref.watch(billTemplatesState.future);
    return (await ref.watch(billsFacadeProvider.future)).monthBills(month, templates);
  }

  Future<void> togglePaid(int templateId) async {
    final current = await future;
    final paid = !current.bills.firstWhere((b) => b.template.id == templateId).paid;
    await (await ref.read(billsFacadeProvider.future)).setPaid(templateId, month, paid: paid);
    state = AsyncData(current.withPaid(templateId, paid: paid));
  }
}
