import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/testing/test_id.dart';
import '../../../core/testing/test_ids.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/app_page_header.dart';
import '../application/bills_state.dart';
import 'bill_templates_page.dart';
import 'month_bills_view.dart';
import 'month_switcher.dart';

class BillsPage extends ConsumerStatefulWidget {
  const BillsPage({super.key});

  @override
  ConsumerState<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends ConsumerState<BillsPage> {
  late final PageController _controller = PageController(initialPage: ref.read(billingWindowState).indexOf(ref.read(selectedMonthState)));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMonth(int index) {
    if (!_controller.hasClients || _controller.page?.round() == index) return;
    _controller.animateToPage(index, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final window = ref.watch(billingWindowState);
    ref.listen(selectedMonthState, (_, month) => _showMonth(window.indexOf(month)));
    final padding = appPagePadding(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(padding, padding, padding, AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.lg,
              children: [
                AppPageHeader(
                  titleId: TestIds.billsTitle,
                  title: l10n.navBills,
                  trailing: FilledButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BillTemplatesPage())),
                    child: Text(l10n.billsTemplatesButton),
                  ).testId(TestIds.billsTemplatesButton),
                ),
                const MonthSwitcher(),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              reverse: true,
              itemCount: window.length,
              onPageChanged: (index) => ref.read(selectedMonthState.notifier).select(window.monthAt(index)),
              itemBuilder: (_, index) => MonthBillsView(month: window.monthAt(index)),
            ).testId(TestIds.billsPager),
          ),
        ],
      ),
    ).testId(TestIds.billsPage);
  }
}
