import 'package:paydo/features/bills/domain/bill_category.dart';
import 'package:paydo/features/bills/domain/bill_template.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

final class BillTemplateBuilder {
  int _id = 1;
  String _name = 'Electricity';
  BillCategory _category = BillCategory.personal;
  YearMonth _startMonth = YearMonth(2026, 1);
  YearMonth? _endMonth;
  int? _dueDay;

  BillTemplateBuilder withId(int id) => this.._id = id;

  BillTemplateBuilder withName(String name) => this.._name = name;

  BillTemplateBuilder inCategory(BillCategory category) => this.._category = category;

  BillTemplateBuilder startingAt(YearMonth month) => this.._startMonth = month;

  BillTemplateBuilder endingAt(YearMonth month) => this.._endMonth = month;

  BillTemplateBuilder withDueDay(int? day) => this.._dueDay = day;

  BillTemplate build() =>
      BillTemplate(id: _id, name: _name, category: _category, startMonth: _startMonth, endMonth: _endMonth, dueDay: _dueDay);
}
