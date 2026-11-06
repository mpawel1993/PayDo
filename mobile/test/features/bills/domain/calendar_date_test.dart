import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/bills/domain/calendar_date.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

void main() {
  test('rejects invalid dates', () {
    expect(() => CalendarDate(2026, 2, 29), throwsArgumentError);
    expect(() => CalendarDate(2026, 13, 1), throwsArgumentError);
    expect(() => CalendarDate(2026, 1, 0), throwsArgumentError);
    expect(CalendarDate(2028, 2, 29).day, 29);
  });

  test('fromDateTime() takes the local calendar day', () {
    expect(CalendarDate.fromDateTime(DateTime(2026, 9, 20, 23, 59)), CalendarDate(2026, 9, 20));
  });

  test('round-trips through UTC midnight millis', () {
    final date = CalendarDate(2026, 9, 20);
    expect(date.toUtcMillis(), DateTime.utc(2026, 9, 20).millisecondsSinceEpoch);
    expect(CalendarDate.fromUtcMillis(date.toUtcMillis()), date);
  });

  test('addDays() crosses month and year boundaries', () {
    expect(CalendarDate(2026, 9, 30).addDays(1), CalendarDate(2026, 10, 1));
    expect(CalendarDate(2026, 12, 31).addDays(1), CalendarDate(2027, 1, 1));
    expect(CalendarDate(2026, 3, 1).addDays(-1), CalendarDate(2026, 2, 28));
    expect(CalendarDate(2026, 3, 28).addDays(3), CalendarDate(2026, 3, 31));
  });

  test('atMinute() builds a local date-time', () {
    expect(CalendarDate(2026, 9, 21).atMinute(9 * 60 + 15), DateTime(2026, 9, 21, 9, 15));
  });

  test('orders chronologically and exposes its month', () {
    final a = CalendarDate(2026, 9, 20);
    final b = CalendarDate(2026, 9, 21);
    expect(a.isBefore(b), isTrue);
    expect(b.isAfter(a), isTrue);
    expect(a.compareTo(CalendarDate(2026, 9, 20)), 0);
    expect(CalendarDate(2025, 12, 31).isBefore(CalendarDate(2026, 1, 1)), isTrue);
    expect(a.yearMonth, YearMonth(2026, 9));
  });
}
