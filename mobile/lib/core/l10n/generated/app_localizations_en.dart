// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navBills => 'Bills';

  @override
  String get navTodo => 'Todo';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languagePolish => 'Polish';

  @override
  String get languageEnglish => 'English';

  @override
  String get billsTemplatesButton => 'Templates';

  @override
  String get billTemplatesTitle => 'Bill templates';

  @override
  String get billCategoryPersonal => 'Personal';

  @override
  String get billCategoryCompany => 'Company';

  @override
  String get billsEmpty => 'No bills. Add a template.';

  @override
  String get billTemplatesEmpty => 'No templates';

  @override
  String get billTemplateNameHint => 'Bill name';

  @override
  String get billTemplateAdd => 'Add';

  @override
  String billTemplateDelete(String name) {
    return 'Delete $name';
  }

  @override
  String get back => 'Back';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get loadError => 'Could not load data';
}
