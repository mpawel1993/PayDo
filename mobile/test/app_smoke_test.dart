import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/main.dart';

void main() {
  testWidgets('shows hello', (tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('hello'), findsOneWidget);
  });
}
