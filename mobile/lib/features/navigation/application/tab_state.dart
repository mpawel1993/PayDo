import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_tab.dart';

final tabState = NotifierProvider<TabNotifier, AppTab>(TabNotifier.new);

class TabNotifier extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.initial;

  void select(AppTab tab) => state = tab;
}
