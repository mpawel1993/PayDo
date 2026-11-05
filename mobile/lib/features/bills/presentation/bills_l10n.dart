import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../domain/bill_category.dart';
import '../domain/year_month.dart';

extension BillCategoryL10n on BillCategory {
  String label(AppLocalizations l10n) => switch (this) {
    BillCategory.personal => l10n.billCategoryPersonal,
    BillCategory.company => l10n.billCategoryCompany,
  };
}

String monthLabel(BuildContext context, YearMonth month) {
  final text = DateFormat.yMMMM(Localizations.localeOf(context).toLanguageTag()).format(DateTime(month.year, month.month));
  return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
