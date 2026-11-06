import 'bill_category.dart';
import 'bills_error.dart';
import 'calendar_date.dart';
import 'year_month.dart';

final class BillTemplate {
  const BillTemplate({required this.id, required this.name, required this.category, required this.startMonth, this.endMonth, this.dueDay});

  static const maxNameLength = 60;

  final int id;
  final String name;
  final BillCategory category;
  final YearMonth startMonth;

  /// Exclusive: the template is not billed in [endMonth] and later.
  final YearMonth? endMonth;

  /// Optional default day of the month the bill is due (1..31, clamped to the month length).
  final int? dueDay;

  static String validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const EmptyBillName();
    if (trimmed.length > maxNameLength) throw const BillNameTooLong(maxNameLength);
    return trimmed;
  }

  static int? validateDueDay(int? dueDay) {
    if (dueDay != null && (dueDay < 1 || dueDay > 31)) throw InvalidDueDay(dueDay);
    return dueDay;
  }

  bool get isArchived => endMonth != null;

  bool isActiveIn(YearMonth month) => !month.isBefore(startMonth) && (endMonth == null || month.isBefore(endMonth!));

  /// Default due date in [month], or null without a [dueDay].
  CalendarDate? dueDateIn(YearMonth month) {
    final day = dueDay;
    if (day == null) return null;
    final lastDay = DateTime.utc(month.year, month.month + 1, 0).day;
    return CalendarDate(month.year, month.month, day < lastDay ? day : lastDay);
  }

  BillTemplate copyWith({String? name, BillCategory? category, YearMonth? startMonth, YearMonth? endMonth}) => BillTemplate(
    id: id,
    name: name ?? this.name,
    category: category ?? this.category,
    startMonth: startMonth ?? this.startMonth,
    endMonth: endMonth ?? this.endMonth,
    dueDay: dueDay,
  );

  BillTemplate withDueDay(int? dueDay) =>
      BillTemplate(id: id, name: name, category: category, startMonth: startMonth, endMonth: endMonth, dueDay: dueDay);

  @override
  bool operator ==(Object other) =>
      other is BillTemplate &&
      other.id == id &&
      other.name == name &&
      other.category == category &&
      other.startMonth == startMonth &&
      other.endMonth == endMonth &&
      other.dueDay == dueDay;

  @override
  int get hashCode => Object.hash(id, name, category, startMonth, endMonth, dueDay);

  @override
  String toString() => 'BillTemplate($id, $name, ${category.name}, $startMonth, $endMonth, day: $dueDay)';
}
