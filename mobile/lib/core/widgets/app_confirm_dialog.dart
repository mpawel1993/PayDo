import 'package:flutter/material.dart';

import '../testing/test_id.dart';
import '../testing/test_ids.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum ConfirmSeverity { primary, warning, danger }

ButtonStyle _confirmStyle(ConfirmSeverity severity) {
  final color = switch (severity) {
    ConfirmSeverity.primary => AppColors.primary,
    ConfirmSeverity.warning => AppColors.yellow400,
    ConfirmSeverity.danger => AppColors.danger,
  };
  return ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered) ? Color.lerp(color, AppColors.text, 0.25) : color,
    ),
    foregroundColor: const WidgetStatePropertyAll(AppColors.primaryContrast),
  );
}

/// Simple yes/no dialog; resolves to true only when the user confirms.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  ConfirmSeverity severity = ConfirmSeverity.primary,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.xl,
            children: [
              Text(
                message,
                style: const TextStyle(color: AppColors.text, fontSize: AppFontSize.base),
              ).testId(TestIds.confirmDialogMessage),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: AppSpacing.sm,
                children: [
                  TextButton(
                    style: textButtonSeverity(AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancelLabel),
                  ).testId(TestIds.confirmDialogNo),
                  FilledButton(
                    style: _confirmStyle(severity),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(confirmLabel),
                  ).testId(TestIds.confirmDialogYes),
                ],
              ),
            ],
          ),
        ),
      ).testId(TestIds.confirmDialog),
    ) ??
    false;
