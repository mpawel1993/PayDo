import 'bill_template.dart';
import 'year_month.dart';

enum BillStatus { paid, due, overdue }

final class Bill {
  const Bill({required this.template, required this.month, required this.paid});

  final BillTemplate template;
  final YearMonth month;
  final bool paid;

  BillStatus statusAt(YearMonth current) => paid
      ? BillStatus.paid
      : month.isBefore(current)
      ? BillStatus.overdue
      : BillStatus.due;

  Bill copyWith({bool? paid}) => Bill(template: template, month: month, paid: paid ?? this.paid);

  @override
  bool operator ==(Object other) => other is Bill && other.template == template && other.month == month && other.paid == paid;

  @override
  int get hashCode => Object.hash(template, month, paid);
}
