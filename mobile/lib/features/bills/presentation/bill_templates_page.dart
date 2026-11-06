import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/testing/test_id.dart';
import '../../../core/testing/test_ids.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/app_day_picker.dart';
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

bool _isValid(String name) => name.trim().isNotEmpty;

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.id, this.onSubmitted});

  final TextEditingController controller;
  final String id;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    style: const TextStyle(fontSize: AppFontSize.base, color: AppColors.text),
    decoration: InputDecoration(hintText: AppLocalizations.of(context).billTemplateNameHint),
    inputFormatters: [LengthLimitingTextInputFormatter(BillTemplate.maxNameLength)],
    textInputAction: TextInputAction.done,
    onSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
  ).testId(id);
}

/// Field-styled button showing the optional due day; opens the day-of-month calendar.
class _DueDayButton extends StatelessWidget {
  const _DueDayButton({required this.day, required this.onChanged, required this.id});

  final int? day;
  final ValueChanged<int?> onChanged;
  final String id;

  Future<void> _pick(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showAppDayOfMonthPicker(
      context,
      title: l10n.billTemplateDueDayPickerTitle,
      clearLabel: l10n.billTemplateNoDueDay,
      cancelLabel: l10n.cancel,
      initialDay: day,
    );
    if (picked != null) onChanged(picked.day);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.billTemplateDueDayPickerTitle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _pick(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            border: Border.all(color: AppColors.fieldBorder),
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              AppIcon(PrimeIcon.calendar, color: day == null ? AppColors.placeholder : AppColors.primary),
              Text(
                day?.toString() ?? l10n.billTemplateDueDayHint,
                style: TextStyle(color: day == null ? AppColors.placeholder : AppColors.text, fontSize: AppFontSize.base),
              ),
            ],
          ),
        ),
      ),
    ).testId(id);
  }
}

class _TemplateRow extends ConsumerWidget {
  const _TemplateRow({required this.template});

  final BillTemplate template;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      message: l10n.confirmDeleteTemplate(template.name),
      confirmLabel: l10n.yes,
      cancelLabel: l10n.no,
      severity: ConfirmSeverity.danger,
    );
    if (confirmed) await ref.read(billTemplatesState.notifier).remove(template);
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final changes = await showDialog<({String name, int? dueDay})>(
      context: context,
      builder: (_) => _EditTemplateDialog(template: template),
    );
    if (changes == null || !context.mounted) return;
    final confirmed = await showAppConfirmDialog(
      context,
      message: l10n.confirmEditTemplate(template.name),
      confirmLabel: l10n.yes,
      cancelLabel: l10n.no,
      severity: ConfirmSeverity.warning,
    );
    if (confirmed) await ref.read(billTemplatesState.notifier).edit(template, name: changes.name, dueDay: changes.dueDay);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.only(left: AppSpacing.md, right: 2, top: 2, bottom: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Row(
        spacing: 2,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: const TextStyle(color: AppColors.text, fontSize: AppFontSize.base),
                ).testId(TestIds.billTemplatesRowName(template.id)),
                if (template.dueDay case final day?)
                  Text(
                    l10n.billTemplateDueDay(day),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: AppFontSize.xs),
                  ).testId(TestIds.billTemplatesRowDetails(template.id)),
              ],
            ),
          ),
          Semantics(
            label: l10n.billTemplateEdit(template.name),
            button: true,
            child: TextButton(
              onPressed: () => _edit(context, ref),
              child: const AppIcon(PrimeIcon.pencil, color: AppColors.primary).testId(TestIds.billTemplatesRowEditIcon(template.id)),
            ),
          ).testId(TestIds.billTemplatesRowEdit(template.id)),
          Semantics(
            label: l10n.billTemplateDelete(template.name),
            button: true,
            child: TextButton(
              style: textButtonSeverity(AppColors.danger),
              onPressed: () => _delete(context, ref),
              child: const AppIcon(PrimeIcon.trash, color: AppColors.danger).testId(TestIds.billTemplatesRowDeleteIcon(template.id)),
            ),
          ).testId(TestIds.billTemplatesRowDelete(template.id)),
        ],
      ),
    ).testId(TestIds.billTemplatesRow(template.id));
  }
}

class _EditTemplateDialog extends StatefulWidget {
  const _EditTemplateDialog({required this.template});

  final BillTemplate template;

  @override
  State<_EditTemplateDialog> createState() => _EditTemplateDialogState();
}

class _EditTemplateDialogState extends State<_EditTemplateDialog> {
  late final _name = TextEditingController(text: widget.template.name);
  late int? _dueDay = widget.template.dueDay;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_isValid(_name.text)) return;
    Navigator.of(context).pop((name: _name.text, dueDay: _dueDay));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.lg,
          children: [
            Text(
              l10n.billTemplateEditTitle,
              style: const TextStyle(color: AppColors.text, fontSize: AppFontSize.xl, fontWeight: FontWeight.w500),
            ).testId(TestIds.billTemplatesEditTitle),
            Row(
              spacing: AppSpacing.sm,
              children: [
                Expanded(
                  child: _NameField(controller: _name, id: TestIds.billTemplatesEditName, onSubmitted: _save),
                ),
                _DueDayButton(day: _dueDay, onChanged: (day) => setState(() => _dueDay = day), id: TestIds.billTemplatesEditDueDay),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: AppSpacing.sm,
              children: [
                TextButton(
                  style: textButtonSeverity(AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ).testId(TestIds.billTemplatesEditCancel),
                ListenableBuilder(
                  listenable: _name,
                  builder: (_, _) => FilledButton(onPressed: _isValid(_name.text) ? _save : null, child: Text(l10n.save)),
                ).testId(TestIds.billTemplatesEditSave),
              ],
            ),
          ],
        ),
      ),
    ).testId(TestIds.billTemplatesEditDialog);
  }
}

class _AddTemplateField extends ConsumerStatefulWidget {
  const _AddTemplateField({required this.category});

  final BillCategory category;

  @override
  ConsumerState<_AddTemplateField> createState() => _AddTemplateFieldState();
}

class _AddTemplateFieldState extends ConsumerState<_AddTemplateField> {
  final _name = TextEditingController();
  int? _dueDay;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isValid(_name.text)) return;
    await ref.read(billTemplatesState.notifier).add(_name.text, widget.category, dueDay: _dueDay);
    _name.clear();
    if (mounted) setState(() => _dueDay = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final category = widget.category.name;
    return Row(
      spacing: AppSpacing.sm,
      children: [
        Expanded(
          child: _NameField(controller: _name, id: TestIds.billTemplatesInput(category), onSubmitted: _submit),
        ),
        _DueDayButton(day: _dueDay, onChanged: (day) => setState(() => _dueDay = day), id: TestIds.billTemplatesDueDayInput(category)),
        Semantics(
          label: l10n.billTemplateAdd,
          button: true,
          child: ListenableBuilder(
            listenable: _name,
            builder: (_, _) => FilledButton(
              onPressed: _isValid(_name.text) ? _submit : null,
              child: const AppIcon(PrimeIcon.plus, color: AppColors.primaryContrast).testId(TestIds.billTemplatesAddIcon(category)),
            ),
          ),
        ).testId(TestIds.billTemplatesAdd(category)),
      ],
    );
  }
}
