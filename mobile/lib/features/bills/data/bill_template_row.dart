import '../domain/bill_category.dart';
import '../domain/bill_template.dart';
import '../domain/year_month.dart';

final class BillTemplateRow {
  const BillTemplateRow({
    required this.id,
    required this.name,
    required this.category,
    required this.startMonth,
    required this.endMonth,
    required this.createdAt,
  });

  factory BillTemplateRow.fromRow(Map<String, Object?> row) => BillTemplateRow(
    id: row['id'] as int?,
    name: row['name']! as String,
    category: row['category']! as String,
    startMonth: row['start_month']! as int,
    endMonth: row['end_month'] as int?,
    createdAt: row['created_at']! as int,
  );

  factory BillTemplateRow.fromDomain(BillTemplate template, {required DateTime createdAt}) => BillTemplateRow(
    id: template.id,
    name: template.name,
    category: template.category.name,
    startMonth: template.startMonth.key,
    endMonth: template.endMonth?.key,
    createdAt: createdAt.millisecondsSinceEpoch,
  );

  final int? id;
  final String name;
  final String category;
  final int startMonth;
  final int? endMonth;
  final int createdAt;

  Map<String, Object?> toRow() => {
    'id': ?id,
    'name': name,
    'category': category,
    'start_month': startMonth,
    'end_month': endMonth,
    'created_at': createdAt,
  };

  BillTemplate toDomain() => BillTemplate(
    id: id!,
    name: name,
    category: BillCategory.fromName(category) ?? (throw StateError('Unknown bill category "$category"')),
    startMonth: YearMonth.fromKey(startMonth),
    endMonth: endMonth == null ? null : YearMonth.fromKey(endMonth!),
  );
}
