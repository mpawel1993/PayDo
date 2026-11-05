import 'package:flutter/material.dart';

import '../../../core/testing/test_id.dart';
import '../../../core/testing/test_ids.dart';
import '../../../core/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Center(
      child: const Text(
        'hello',
        style: TextStyle(color: AppColors.text, fontSize: AppFontSize.base, fontWeight: FontWeight.w400),
      ).testId(TestIds.homeHelloText),
    ),
  ).testId(TestIds.homePage);
}
