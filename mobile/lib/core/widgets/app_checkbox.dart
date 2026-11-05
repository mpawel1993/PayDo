import 'package:flutter/widgets.dart';

import '../testing/test_id.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, required this.id, required this.value, required this.onChanged, required this.label});

  final String id;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final onTap = onChanged == null ? null : () => onChanged(!value);
    return Semantics(
      checked: value,
      enabled: onChanged != null,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : AppColors.fieldBackground,
              border: Border.all(color: value ? AppColors.primary : AppColors.fieldBorder),
              borderRadius: BorderRadius.circular(AppRadius.checkbox),
            ),
            child: value ? const AppIcon(PrimeIcon.check, color: AppColors.primaryContrast, size: 14) : null,
          ),
        ),
      ),
    ).testId(id);
  }
}
