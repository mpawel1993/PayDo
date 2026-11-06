import 'year_month.dart';

/// A day in the calendar, without time or time zone.
final class CalendarDate implements Comparable<CalendarDate> {
  const CalendarDate._(this.year, this.month, this.day);

  factory CalendarDate(int year, int month, int day) {
    final utc = DateTime.utc(year, month, day);
    if (utc.year != year || utc.month != month || utc.day != day) throw ArgumentError('Invalid date $year-$month-$day');
    return CalendarDate._(year, month, day);
  }

  factory CalendarDate._fromUtc(DateTime utc) => CalendarDate._(utc.year, utc.month, utc.day);

  factory CalendarDate.fromDateTime(DateTime dateTime) => CalendarDate._(dateTime.year, dateTime.month, dateTime.day);

  /// Inverse of [toUtcMillis]: UTC midnight of the day.
  factory CalendarDate.fromUtcMillis(int millis) => CalendarDate._fromUtc(DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true));

  final int year;
  final int month;
  final int day;

  YearMonth get yearMonth => YearMonth(year, month);

  int toUtcMillis() => DateTime.utc(year, month, day).millisecondsSinceEpoch;

  CalendarDate addDays(int days) => CalendarDate._fromUtc(DateTime.utc(year, month, day + days));

  /// Local date-time of this day at [minuteOfDay] minutes after midnight.
  DateTime atMinute(int minuteOfDay) => DateTime(year, month, day, 0, minuteOfDay);

  bool isBefore(CalendarDate other) => compareTo(other) < 0;

  bool isAfter(CalendarDate other) => compareTo(other) > 0;

  @override
  int compareTo(CalendarDate other) => _key.compareTo(other._key);

  int get _key => year * 10000 + month * 100 + day;

  @override
  bool operator ==(Object other) => other is CalendarDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => 'CalendarDate($year-$month-$day)';
}
