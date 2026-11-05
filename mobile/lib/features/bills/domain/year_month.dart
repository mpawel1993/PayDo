final class YearMonth implements Comparable<YearMonth> {
  const YearMonth._(this.year, this.month);

  factory YearMonth(int year, int month) {
    if (month < 1 || month > 12) throw ArgumentError.value(month, 'month', 'must be 1..12');
    return YearMonth._(year, month);
  }

  factory YearMonth.fromDate(DateTime date) => YearMonth._(date.year, date.month);

  factory YearMonth.fromKey(int key) => YearMonth(key ~/ 100, key % 100);

  final int year;
  final int month;

  int get key => year * 100 + month;

  int get _index => year * 12 + month - 1;

  YearMonth addMonths(int months) {
    final index = _index + months;
    return YearMonth._(index ~/ 12, index % 12 + 1);
  }

  int monthsUntil(YearMonth other) => other._index - _index;

  bool isBefore(YearMonth other) => compareTo(other) < 0;

  bool isAfter(YearMonth other) => compareTo(other) > 0;

  @override
  int compareTo(YearMonth other) => _index.compareTo(other._index);

  @override
  bool operator ==(Object other) => other is YearMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => 'YearMonth($year-$month)';
}
