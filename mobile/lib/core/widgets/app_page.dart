import 'package:flutter/material.dart';

import '../testing/test_id.dart';
import '../theme/app_colors.dart';
import 'app_page_header.dart';

double appPagePadding(BuildContext context) => MediaQuery.sizeOf(context).width >= Breakpoints.md ? AppSpacing.xxxl : AppSpacing.lg;

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.id,
    required this.titleId,
    required this.title,
    this.leading,
    this.trailing,
    this.children = const [],
  });

  final String id;
  final String titleId;
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(appPagePadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.lg,
        children: [
          AppPageHeader(titleId: titleId, title: title, leading: leading, trailing: trailing),
          ...children,
        ],
      ),
    ),
  ).testId(id);
}
