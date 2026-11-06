import 'package:flutter/material.dart';

import '../testing/test_id.dart';
import '../testing/test_ids.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Result of the day-of-month picker; [day] null means "no day" (cleared).
typedef DayPick = ({int? day});

/// Calendar grid with days 1..31. Resolves to null when cancelled.
Future<DayPick?> showAppDayOfMonthPicker(
  BuildContext context, {
  required String title,
  required String clearLabel,
  required String cancelLabel,
  int? initialDay,
}) => showDialog<DayPick>(
  context: context,
  builder: (context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.lg,
          children: [
            Text(
              title,
              style: const TextStyle(color: AppColors.text, fontSize: AppFontSize.xl, fontWeight: FontWeight.w500),
            ).testId(TestIds.dayPickerTitle),
            Column(
              spacing: AppSpacing.xs,
              children: [
                for (var week = 0; week < 5; week++)
                  Row(
                    spacing: AppSpacing.xs,
                    children: [
                      for (var i = 1; i <= 7; i++)
                        Expanded(
                          child: switch (week * 7 + i) {
                            final day when day <= 31 => _DayCell(day: day, selected: day == initialDay),
                            _ => const SizedBox.shrink(),
                          },
                        ),
                    ],
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: textButtonSeverity(AppColors.danger),
                  onPressed: () => Navigator.of(context).pop<DayPick>((day: null)),
                  child: Text(clearLabel),
                ).testId(TestIds.dayPickerClear),
                TextButton(
                  style: textButtonSeverity(AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(cancelLabel),
                ).testId(TestIds.dayPickerCancel),
              ],
            ),
          ],
        ),
      ),
    ),
  ).testId(TestIds.dayPicker),
);

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.selected});

  final int day;
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop<DayPick>((day: day)),
      child: SizedBox(
        height: 40,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceHover,
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          child: Text(
            '$day',
            style: TextStyle(
              color: selected ? AppColors.primaryContrast : AppColors.text,
              fontSize: AppFontSize.base,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    ),
  ).testId(TestIds.dayPickerDay(day));
}
