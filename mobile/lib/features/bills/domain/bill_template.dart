import 'bill_category.dart';
import 'bills_error.dart';
import 'year_month.dart';

final class BillTemplate {
  const BillTemplate({required this.id, required this.name, required this.category, required this.startMonth, this.endMonth});

  static const maxNameLength = 60;

  final int id;
  final String name;
  final BillCategory category;
  final YearMonth startMonth;

  /// Exclusive: the template is not billed in [endMonth] and later.
  final YearMonth? endMonth;

  static String validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw const EmptyBillName();
    if (trimmed.length > maxNameLength) throw const BillNameTooLong(maxNameLength);
    return trimmed;
  }

  bool get isArchived => endMonth != null;

  bool isActiveIn(YearMonth month) => !month.isBefore(startMonth) && (endMonth == null || month.isBefore(endMonth!));

  BillTemplate copyWith({String? name, BillCategory? category, YearMonth? startMonth, YearMonth? endMonth}) => BillTemplate(
    id: id,
    name: name ?? this.name,
    category: category ?? this.category,
    startMonth: startMonth ?? this.startMonth,
    endMonth: endMonth ?? this.endMonth,
  );

  @override
  bool operator ==(Object other) =>
      other is BillTemplate &&
      other.id == id &&
      other.name == name &&
      other.category == category &&
      other.startMonth == startMonth &&
      other.endMonth == endMonth;

  @override
  int get hashCode => Object.hash(id, name, category, startMonth, endMonth);

  @override
  String toString() => 'BillTemplate($id, $name, ${category.name}, $startMonth, $endMonth)';
}
