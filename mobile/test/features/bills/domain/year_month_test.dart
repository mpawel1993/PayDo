import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

void main() {
  test('rejects months outside 1..12', () {
    expect(() => YearMonth(2026, 0), throwsArgumentError);
    expect(() => YearMonth(2026, 13), throwsArgumentError);
  });

  test('fromDate() takes the year and month of the date', () {
    expect(YearMonth.fromDate(DateTime(2026, 9, 30, 23, 59)), YearMonth(2026, 9));
  });

  test('key is yyyymm and round-trips through fromKey()', () {
    expect(YearMonth(2026, 9).key, 202609);
    expect(YearMonth.fromKey(202612), YearMonth(2026, 12));
    expect(() => YearMonth.fromKey(202613), throwsArgumentError);
  });

  test('addMonths() crosses year boundaries in both directions', () {
    expect(YearMonth(2026, 11).addMonths(2), YearMonth(2027, 1));
    expect(YearMonth(2026, 1).addMonths(-1), YearMonth(2025, 12));
    expect(YearMonth(2026, 6).addMonths(-18), YearMonth(2024, 12));
    expect(YearMonth(2026, 6).addMonths(0), YearMonth(2026, 6));
  });

  test('monthsUntil() counts months between two values', () {
    expect(YearMonth(2026, 11).monthsUntil(YearMonth(2027, 2)), 3);
    expect(YearMonth(2026, 11).monthsUntil(YearMonth(2025, 11)), -12);
  });

  test('orders chronologically', () {
    final a = YearMonth(2025, 12);
    final b = YearMonth(2026, 1);
    expect(a.compareTo(b), lessThan(0));
    expect(b.compareTo(a), greaterThan(0));
    expect(a.compareTo(YearMonth(2025, 12)), 0);
    expect(a.isBefore(b), isTrue);
    expect(b.isAfter(a), isTrue);
    expect(a.isAfter(a), isFalse);
  });

  test('has value equality', () {
    expect(YearMonth(2026, 3), YearMonth(2026, 3));
    expect(YearMonth(2026, 3).hashCode, YearMonth(2026, 3).hashCode);
    expect(YearMonth(2026, 3), isNot(YearMonth(2026, 4)));
  });
}
