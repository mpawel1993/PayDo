import 'package:flutter/widgets.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/testing/test_ids.dart';
import '../../../core/widgets/app_page.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) =>
      AppPage(id: TestIds.todoPage, titleId: TestIds.todoTitle, title: AppLocalizations.of(context).navTodo);
}
