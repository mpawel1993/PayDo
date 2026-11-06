import 'package:flutter/widgets.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/testing/test_ids.dart';
import '../../../core/widgets/app_page.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({super.key});

  @override
  Widget build(BuildContext context) =>
      AppPage(id: TestIds.shoppingPage, titleId: TestIds.shoppingTitle, title: AppLocalizations.of(context).navShopping);
}
