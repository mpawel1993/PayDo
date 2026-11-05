import 'package:flutter/material.dart';

import '../testing/test_id.dart';
import '../theme/app_colors.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.id, required this.titleId, required this.title, this.children = const []});

  final String id;
  final String titleId;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width >= Breakpoints.md ? AppSpacing.xxxl : AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.lg,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.text, fontSize: AppFontSize.xxl, fontWeight: FontWeight.w600),
          ).testId(titleId),
          ...children,
        ],
      ),
    ),
  ).testId(id);
}
