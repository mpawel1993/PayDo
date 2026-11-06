import 'bill_template.dart';
import 'calendar_date.dart';
import 'year_month.dart';

enum BillStatus { paid, due, overdue }

/// Per-month state of a bill: when it is due and when it was paid.
final class BillEntry {
  const BillEntry({this.dueDate, this.paidAt});

  static const empty = BillEntry();

  final CalendarDate? dueDate;

  /// UTC instant of the payment.
  final DateTime? paidAt;

  @override
  bool operator ==(Object other) => other is BillEntry && other.dueDate == dueDate && other.paidAt == paidAt;

  @override
  int get hashCode => Object.hash(dueDate, paidAt);
}

final class Bill {
  const Bill({required this.template, required this.month, this.entry = BillEntry.empty});

  final BillTemplate template;
  final YearMonth month;
  final BillEntry entry;

  /// The due date set for this month, otherwise the template default.
  CalendarDate? get dueDate => entry.dueDate ?? template.dueDateIn(month);

  DateTime? get paidAt => entry.paidAt;

  bool get paid => paidAt != null;

  /// Overdue from the day after the due date; without a due date, once the bill's month has passed.
  BillStatus statusAt(CalendarDate today) => switch (dueDate) {
    _ when paid => BillStatus.paid,
    final due? => today.isAfter(due) ? BillStatus.overdue : BillStatus.due,
    null => month.isBefore(today.yearMonth) ? BillStatus.overdue : BillStatus.due,
  };

  Bill markedPaid(DateTime at) => _withEntry(BillEntry(dueDate: dueDate, paidAt: at));

  Bill markedUnpaid() => _withEntry(BillEntry(dueDate: dueDate));

  Bill withDueDate(CalendarDate? dueDate) => _withEntry(BillEntry(dueDate: dueDate, paidAt: paidAt));

  Bill _withEntry(BillEntry entry) => Bill(template: template, month: month, entry: entry);

  @override
  bool operator ==(Object other) => other is Bill && other.template == template && other.month == month && other.entry == entry;

  @override
  int get hashCode => Object.hash(template, month, entry);

  @override
  String toString() => 'Bill(${template.id}, $month, due: $dueDate, paid: $paidAt)';
}
