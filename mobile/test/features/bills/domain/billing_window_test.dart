import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/bills/domain/billing_window.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

void main() {
  final window = BillingWindow(YearMonth(2026, 9));

  test('spans 12 months back and 12 months ahead by default', () {
    expect(window.first, YearMonth(2025, 9));
    expect(window.last, YearMonth(2027, 9));
    expect(window.length, 25);
    expect(window.currentIndex, 12);
  });

  test('monthAt() and indexOf() are inverse', () {
    expect(window.monthAt(0), YearMonth(2025, 9));
    expect(window.monthAt(12), YearMonth(2026, 9));
    expect(window.monthAt(24), YearMonth(2027, 9));
    for (var i = 0; i < window.length; i++) {
      expect(window.indexOf(window.monthAt(i)), i);
    }
  });

  test('monthAt() rejects indexes outside the window', () {
    expect(() => window.monthAt(-1), throwsRangeError);
    expect(() => window.monthAt(25), throwsRangeError);
  });

  test('contains() checks the bounds', () {
    expect(window.contains(YearMonth(2025, 9)), isTrue);
    expect(window.contains(YearMonth(2025, 8)), isFalse);
    expect(window.contains(YearMonth(2027, 9)), isTrue);
    expect(window.contains(YearMonth(2027, 10)), isFalse);
  });

  test('supports custom sizes', () {
    final w = BillingWindow(YearMonth(2026, 1), monthsBack: 1, monthsAhead: 2);
    expect(w.first, YearMonth(2025, 12));
    expect(w.last, YearMonth(2026, 3));
    expect(w.length, 4);
    expect(w.currentIndex, 1);
  });
}
