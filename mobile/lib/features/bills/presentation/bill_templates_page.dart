import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/testing/test_id.dart';
import '../../../core/testing/test_ids.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_page.dart';
import '../application/bills_state.dart';
import '../domain/bill_category.dart';
import '../domain/bill_template.dart';
import 'bills_l10n.dart';

class BillTemplatesPage extends ConsumerWidget {
  const BillTemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final templates = ref.watch(activeBillTemplatesState);
    return Scaffold(
      body: AppPage(
        id: TestIds.billTemplatesPage,
        titleId: TestIds.billTemplatesTitle,
        title: l10n.billTemplatesTitle,
        leading: Semantics(
          label: l10n.back,
          button: true,
          child: TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const AppIcon(PrimeIcon.arrowLeft, color: AppColors.primary, size: 20).testId(TestIds.billTemplatesBackIcon),
          ),
        ).testId(TestIds.billTemplatesBack),
        children: switch (templates) {
          AsyncValue(:final value?) => [
            for (final category in BillCategory.values)
              _TemplateSection(category: category, templates: [...value.where((t) => t.category == category)]),
          ],
          AsyncError() => [Text(l10n.loadError, style: const TextStyle(color: AppColors.danger)).testId(TestIds.billTemplatesError)],
          _ => [const Center(child: CircularProgressIndicator()).testId(TestIds.billTemplatesLoading)],
        },
      ),
    );
  }
}

class _TemplateSection extends StatelessWidget {
  const _TemplateSection({required this.category, required this.templates});

  final BillCategory category;
  final List<BillTemplate> templates;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      id: TestIds.billTemplatesSection(category.name),
      titleId: TestIds.billTemplatesSectionTitle(category.name),
      title: category.label(l10n),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          if (templates.isEmpty)
            Text(
              l10n.billTemplatesEmpty,
              style: const TextStyle(color: AppColors.textMuted, fontSize: AppFontSize.base),
            ).testId(TestIds.billTemplatesEmpty(category.name)),
          for (final t in templates) _TemplateRow(template: t),
          _AddTemplateField(category: category),
        ],
      ),
    );
  }
}

class _TemplateRow extends ConsumerWidget {
  const _TemplateRow({required this.template});

  final BillTemplate template;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.only(left: AppSpacing.md, right: 2, top: 2, bottom: 2),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppRadius.field),
    ),
    child: Row(
      spacing: 6,
      children: [
        Expanded(
          child: Text(
            template.name,
            style: const TextStyle(color: AppColors.text, fontSize: AppFontSize.base),
          ).testId(TestIds.billTemplatesRowName(template.id)),
        ),
        Semantics(
          label: AppLocalizations.of(context).billTemplateDelete(template.name),
          button: true,
          child: TextButton(
            style: textButtonSeverity(AppColors.danger),
            onPressed: () => ref.read(billTemplatesState.notifier).remove(template),
            child: const AppIcon(PrimeIcon.trash, color: AppColors.danger).testId(TestIds.billTemplatesRowDeleteIcon(template.id)),
          ),
        ).testId(TestIds.billTemplatesRowDelete(template.id)),
      ],
    ),
  ).testId(TestIds.billTemplatesRow(template.id));
}

class _AddTemplateField extends ConsumerStatefulWidget {
  const _AddTemplateField({required this.category});

  final BillCategory category;

  @override
  ConsumerState<_AddTemplateField> createState() => _AddTemplateFieldState();
}

class _AddTemplateFieldState extends ConsumerState<_AddTemplateField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text;
    if (name.trim().isEmpty) return;
    await ref.read(billTemplatesState.notifier).add(name, widget.category);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = widget.category.name;
    return Row(
      spacing: AppSpacing.sm,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: const TextStyle(fontSize: AppFontSize.base, color: AppColors.text),
            decoration: InputDecoration(hintText: l10n.billTemplateNameHint),
            inputFormatters: [LengthLimitingTextInputFormatter(BillTemplate.maxNameLength)],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ).testId(TestIds.billTemplatesInput(category)),
        ),
        Semantics(
          label: l10n.billTemplateAdd,
          button: true,
          child: ValueListenableBuilder(
            valueListenable: _controller,
            builder: (_, value, _) => FilledButton(
              onPressed: value.text.trim().isEmpty ? null : _submit,
              child: const AppIcon(PrimeIcon.plus, color: AppColors.primaryContrast).testId(TestIds.billTemplatesAddIcon(category)),
            ),
          ),
        ).testId(TestIds.billTemplatesAdd(category)),
      ],
    );
  }
}
