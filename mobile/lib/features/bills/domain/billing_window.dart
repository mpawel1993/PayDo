import 'year_month.dart';

/// Months reachable from [current]: [monthsBack] before it and [monthsAhead] after it.
final class BillingWindow {
  const BillingWindow(this.current, {this.monthsBack = 12, this.monthsAhead = 12});

  final YearMonth current;
  final int monthsBack;
  final int monthsAhead;

  YearMonth get first => current.addMonths(-monthsBack);

  YearMonth get last => current.addMonths(monthsAhead);

  int get length => monthsBack + monthsAhead + 1;

  int get currentIndex => monthsBack;

  YearMonth monthAt(int index) => first.addMonths(RangeError.checkValidIndex(index, this, 'index', length));

  int indexOf(YearMonth month) => first.monthsUntil(month);

  bool contains(YearMonth month) => !month.isBefore(first) && !month.isAfter(last);

  @override
  bool operator ==(Object other) =>
      other is BillingWindow && other.current == current && other.monthsBack == monthsBack && other.monthsAhead == monthsAhead;

  @override
  int get hashCode => Object.hash(current, monthsBack, monthsAhead);
}
