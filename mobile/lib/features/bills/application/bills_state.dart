import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/clock_state.dart';
import '../domain/bill_category.dart';
import '../domain/bill_template.dart';
import '../domain/billing_window.dart';
import '../domain/calendar_date.dart';
import '../domain/month_bills.dart';
import '../domain/reminders/notification_scheduler.dart';
import '../domain/year_month.dart';
import 'bills_providers.dart';

final currentMonthState = Provider<YearMonth>((ref) => YearMonth.fromDate(ref.watch(clockState)()));

final todayState = Provider<CalendarDate>((ref) => CalendarDate.fromDateTime(ref.watch(clockState)()));

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

  Future<void> edit(BillTemplate template, {required String name, required int? dueDay}) async {
    final facade = await ref.read(billsFacadeProvider.future);
    await facade.updateTemplate(template, name: name, dueDay: dueDay);
    state = AsyncData(await facade.templates());
    ref.invalidate(reminderSyncState);
  }

  Future<void> add(String name, BillCategory category, {int? dueDay}) async {
    final facade = await ref.read(billsFacadeProvider.future);
    await facade.addTemplate(name, category, dueDay: dueDay);
    state = AsyncData(await facade.templates());
    ref.invalidate(reminderSyncState);
  }

  Future<void> remove(BillTemplate template) async {
    final facade = await ref.read(billsFacadeProvider.future);
    await facade.removeTemplate(template);
    state = AsyncData(await facade.templates());
    ref.invalidate(reminderSyncState);
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

  Future<void> setDueDate(int templateId, CalendarDate? dueDate) async {
    final current = await future;
    await (await ref.read(billsFacadeProvider.future)).setDueDate(templateId, month, dueDate);
    state = AsyncData(current.updated(templateId, (b) => b.withDueDate(dueDate)));
    ref.invalidate(reminderSyncState);
  }

  Future<void> togglePaid(int templateId) async {
    final current = await future;
    final paid = current.byTemplateId(templateId)?.paid ?? false;
    final paidAt = await (await ref.read(billsFacadeProvider.future)).setPaid(templateId, month, paid: !paid);
    state = AsyncData(current.updated(templateId, (b) => paidAt == null ? b.markedUnpaid() : b.markedPaid(paidAt)));
    ref.invalidate(reminderSyncState);
  }
}

/// Re-plans overdue notifications; invalidated after every change of bills. Watched by the app shell.
final reminderSyncState = FutureProvider<List<ScheduledNotification>>(
  (ref) async => (await ref.watch(billRemindersServiceProvider.future)).reschedule(),
);
