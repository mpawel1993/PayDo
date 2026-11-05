import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/navigation/application/tab_state.dart';
import 'package:paydo/features/navigation/domain/app_tab.dart';

void main() {
  test('tabs are ordered Bills, Todo, Settings and start on Bills', () {
    expect(AppTab.values, [AppTab.bills, AppTab.todo, AppTab.settings]);
    expect(AppTab.initial, AppTab.bills);
  });

  test('starts on the initial tab and select() switches it', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(tabState), AppTab.initial);
    container.read(tabState.notifier).select(AppTab.settings);
    expect(container.read(tabState), AppTab.settings);
  });
}
