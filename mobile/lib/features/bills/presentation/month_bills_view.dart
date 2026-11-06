import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/testing/test_id.dart';
import '../../../core/testing/test_ids.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_page.dart';
import '../application/bills_state.dart';
import '../domain/bill.dart';
import '../domain/bill_category.dart';
import '../domain/calendar_date.dart';
import '../domain/month_bills.dart';
import '../domain/year_month.dart';
import 'bills_l10n.dart';

class MonthBillsView extends ConsumerWidget {
  const MonthBillsView({super.key, required this.month});

  final YearMonth month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = appPagePadding(context);
    final child = switch (ref.watch(monthBillsState(month))) {
      AsyncValue(:final value?) => _Sections(bills: value),
      AsyncError() => Center(
        child: Text(
          AppLocalizations.of(context).loadError,
          style: const TextStyle(color: AppColors.danger),
        ).testId(TestIds.billsMonthError(month.key)),
      ),
      _ => const Center(child: CircularProgressIndicator()).testId(TestIds.billsMonthLoading(month.key)),
    };
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padding, AppSpacing.sm, padding, padding),
      child: child,
    ).testId(TestIds.billsMonth(month.key));
  }
}

class _Sections extends StatelessWidget {
  const _Sections({required this.bills});

  final MonthBills bills;

  @override
  Widget build(BuildContext context) {
    final sections = [
      for (final category in BillCategory.values) _BillSection(month: bills.month, category: category, bills: bills.inCategory(category)),
    ];
    return MediaQuery.sizeOf(context).width >= Breakpoints.md
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.lg,
            children: [for (final s in sections) Expanded(child: s)],
          )
        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: AppSpacing.lg, children: sections);
  }
}

class _BillSection extends StatelessWidget {
  const _BillSection({required this.month, required this.category, required this.bills});

  final YearMonth month;
  final BillCategory category;
  final List<Bill> bills;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      id: TestIds.billsSection(month.key, category.name),
      titleId: TestIds.billsSectionTitle(month.key, category.name),
      title: category.label(l10n),
      child: bills.isEmpty
          ? Text(
              l10n.billsEmpty,
              style: const TextStyle(color: AppColors.textMuted, fontSize: AppFontSize.base),
            ).testId(TestIds.billsSectionEmpty(month.key, category.name))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.sm,
              children: [for (final b in bills) _BillRow(bill: b)],
            ),
    );
  }
}

class _BillRow extends ConsumerWidget {
  const _BillRow({required this.bill});

  final Bill bill;

  static DateTime _day(CalendarDate d) => DateTime(d.year, d.month, d.day);

  Future<void> _pickDueDate(BuildContext context, WidgetRef ref, CalendarDate today) async {
    final initial = bill.dueDate ?? (bill.month == today.yearMonth ? today : CalendarDate(bill.month.year, bill.month.month, 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _day(initial),
      firstDate: DateTime(bill.month.year - 1),
      lastDate: DateTime(bill.month.year + 2, 12, 31),
    );
    if (picked != null) {
      await ref.read(monthBillsState(bill.month).notifier).setDueDate(bill.template.id, CalendarDate.fromDateTime(picked));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayState);
    final status = bill.statusAt(today);
    final id = bill.template.id;
    final key = bill.month.key;
    final details = [
      if (bill.dueDate case final due?) l10n.billDueDate(_day(due)),
      if (bill.paidAt case final paidAt?) l10n.billPaidOn(paidAt.toLocal()),
    ];
    void toggle() => ref.read(monthBillsState(bill.month).notifier).togglePaid(id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: toggle,
      child: Container(
        padding: const EdgeInsets.only(left: AppSpacing.md, right: 2, top: 2, bottom: 2),
        decoration: BoxDecoration(
          border: Border.all(color: status == BillStatus.overdue ? AppColors.danger : AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
        child: Row(
          spacing: 2,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.template.name,
                    style: switch (status) {
                      BillStatus.paid => const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: AppFontSize.base,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.textMuted,
                      ),
                      BillStatus.overdue => const TextStyle(color: AppColors.danger, fontSize: AppFontSize.base),
                      BillStatus.due => const TextStyle(color: AppColors.text, fontSize: AppFontSize.base),
                    },
                  ).testId(TestIds.billsRowName(key, id)),
                  if (details.isNotEmpty)
                    Text(
                      details.join(' · '),
                      style: TextStyle(
                        color: status == BillStatus.overdue ? AppColors.danger : AppColors.textMuted,
                        fontSize: AppFontSize.xs,
                      ),
                    ).testId(TestIds.billsRowDetails(key, id)),
                ],
              ),
            ),
            Semantics(
              label: l10n.billSetDueDate(bill.template.name),
              button: true,
              child: TextButton(
                onPressed: () => _pickDueDate(context, ref, today),
                child: AppIcon(
                  PrimeIcon.calendar,
                  color: bill.dueDate == null ? AppColors.textMuted : AppColors.primary,
                ).testId(TestIds.billsRowDueDateIcon(key, id)),
              ),
            ).testId(TestIds.billsRowDueDate(key, id)),
            AppCheckbox(id: TestIds.billsRowCheckbox(key, id), value: bill.paid, onChanged: (_) => toggle(), label: bill.template.name),
          ],
        ),
      ),
    ).testId(TestIds.billsRow(key, id));
  }
}
