import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/testing/test_id.dart';
import '../../../core/testing/test_ids.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon.dart';
import '../../bills/application/bills_state.dart';
import '../../bills/presentation/bills_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../shopping/presentation/shopping_page.dart';
import '../../todo/presentation/todo_page.dart';
import '../application/tab_state.dart';
import '../domain/app_tab.dart';

extension on AppTab {
  PrimeIcon get icon => switch (this) {
    AppTab.bills => PrimeIcon.receipt,
    AppTab.todo => PrimeIcon.listCheck,
    AppTab.shopping => PrimeIcon.shoppingCart,
    AppTab.settings => PrimeIcon.cog,
  };

  String label(AppLocalizations l10n) => switch (this) {
    AppTab.bills => l10n.navBills,
    AppTab.todo => l10n.navTodo,
    AppTab.shopping => l10n.navShopping,
    AppTab.settings => l10n.navSettings,
  };

  String get id => switch (this) {
    AppTab.bills => TestIds.navigationTabBills,
    AppTab.todo => TestIds.navigationTabTodo,
    AppTab.shopping => TestIds.navigationTabShopping,
    AppTab.settings => TestIds.navigationTabSettings,
  };

  String get iconId => switch (this) {
    AppTab.bills => TestIds.navigationTabBillsIcon,
    AppTab.todo => TestIds.navigationTabTodoIcon,
    AppTab.shopping => TestIds.navigationTabShoppingIcon,
    AppTab.settings => TestIds.navigationTabSettingsIcon,
  };

  Widget get page => switch (this) {
    AppTab.bills => const BillsPage(),
    AppTab.todo => const TodoPage(),
    AppTab.shopping => const ShoppingPage(),
    AppTab.settings => const SettingsPage(),
  };
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tab = ref.watch(tabState);
    ref.watch(reminderSyncState);
    return Scaffold(
      body: tab.page,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.index,
        onDestinationSelected: (index) => ref.read(tabState.notifier).select(AppTab.values[index]),
        destinations: [
          for (final t in AppTab.values)
            NavigationDestination(
              icon: AppIcon(t.icon, color: AppColors.textMuted, size: 20).testId(t.iconId),
              selectedIcon: AppIcon(t.icon, color: AppColors.primary, size: 20).testId(t.iconId),
              label: t.label(l10n),
            ).testId(t.id),
        ],
      ).testId(TestIds.navigationBar),
    ).testId(TestIds.navigationShell);
  }
}
