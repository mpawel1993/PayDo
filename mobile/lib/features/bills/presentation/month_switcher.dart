import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/testing/test_id.dart';
import '../../../core/testing/test_ids.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../application/bills_state.dart';
import 'bills_l10n.dart';

class MonthSwitcher extends ConsumerWidget {
  const MonthSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final month = ref.watch(selectedMonthState);
    final window = ref.watch(billingWindowState);
    final notifier = ref.read(selectedMonthState.notifier);

    Widget arrow({required String id, required String iconId, required PrimeIcon icon, required String label, VoidCallback? onPressed}) =>
        Semantics(
          label: label,
          button: true,
          child: TextButton(
            onPressed: onPressed,
            child: AppIcon(icon, color: onPressed == null ? AppColors.placeholder : AppColors.primary, size: 20).testId(iconId),
          ),
        ).testId(id);

    return Row(
      spacing: AppSpacing.sm,
      children: [
        arrow(
          id: TestIds.billsPreviousMonth,
          iconId: TestIds.billsPreviousMonthIcon,
          icon: PrimeIcon.chevronLeft,
          label: l10n.previousMonth,
          onPressed: month == window.first ? null : notifier.previous,
        ),
        Expanded(
          child: Text(
            monthLabel(context, month),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.text, fontSize: AppFontSize.xl, fontWeight: FontWeight.w500),
          ).testId(TestIds.billsMonthLabel),
        ),
        arrow(
          id: TestIds.billsNextMonth,
          iconId: TestIds.billsNextMonthIcon,
          icon: PrimeIcon.chevronRight,
          label: l10n.nextMonth,
          onPressed: month == window.last ? null : notifier.next,
        ),
      ],
    );
  }
}
