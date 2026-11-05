import 'package:flutter/widgets.dart';

import '../testing/test_id.dart';
import '../theme/app_colors.dart';

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({super.key, required this.titleId, required this.title, this.leading, this.trailing});

  final String titleId;
  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    spacing: AppSpacing.sm,
    children: [
      ?leading,
      Expanded(
        child: Text(
          title,
          style: const TextStyle(color: AppColors.text, fontSize: AppFontSize.xxl, fontWeight: FontWeight.w600),
        ).testId(titleId),
      ),
      ?trailing,
    ],
  );
}
