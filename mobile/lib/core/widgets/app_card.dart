import 'package:flutter/widgets.dart';

import '../testing/test_id.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.id, required this.titleId, required this.title, this.subtitle, this.aside, required this.child});

  final String id;
  final String titleId;
  final String title;
  final String? subtitle;
  final Widget? aside;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.xl),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.lg,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.text, fontSize: AppFontSize.xl, fontWeight: FontWeight.w500),
                ).testId(titleId),
                if (subtitle case final subtitle?)
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: AppFontSize.base),
                  ),
              ],
            ),
            ?aside,
          ],
        ),
        child,
      ],
    ),
  ).testId(id);
}
