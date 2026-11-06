import 'bill.dart';
import 'bill_template.dart';
import 'year_month.dart';

/// Unpaid bills with a due date (own or the template default) of every month in [from]..[to] where the template is active.
List<Bill> unpaidBillsWithDueDate({
  required Iterable<BillTemplate> templates,
  required Map<(int, YearMonth), BillEntry> entries,
  required YearMonth from,
  required YearMonth to,
}) => [
  for (final template in templates)
    for (var month = from; !month.isAfter(to); month = month.addMonths(1))
      if (template.isActiveIn(month))
        if (Bill(template: template, month: month, entry: entries[(template.id, month)] ?? BillEntry.empty) case final bill
            when !bill.paid && bill.dueDate != null)
          bill,
];
