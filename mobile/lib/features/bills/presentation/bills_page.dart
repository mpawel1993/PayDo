import 'package:flutter/widgets.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/testing/test_ids.dart';
import '../../../core/widgets/app_page.dart';

class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      AppPage(id: TestIds.billsPage, titleId: TestIds.billsTitle, title: AppLocalizations.of(context).navBills);
}
