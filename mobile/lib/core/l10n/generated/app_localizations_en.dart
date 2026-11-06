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

  @override
  String get navShopping => 'Shopping';

  @override
  String billDueDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Due: $dateString';
  }

  @override
  String billPaidOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Paid: $dateString';
  }

  @override
  String billSetDueDate(String name) {
    return 'Set due date of $name';
  }

  @override
  String get reminderTitle => 'Unpaid bill';

  @override
  String reminderBody(String name, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$name – payment was due $dateString. Mark the bill as paid.';
  }

  @override
  String get reminderChannelName => 'Bill reminders';

  @override
  String get billTemplateDueDayHint => 'Day';

  @override
  String get billTemplateDueDayPickerTitle => 'Due day of the month';

  @override
  String get billTemplateNoDueDay => 'No due day';

  @override
  String billTemplateDueDay(int day) {
    return 'Due on day $day';
  }

  @override
  String billTemplateEdit(String name) {
    return 'Edit $name';
  }

  @override
  String get billTemplateEditTitle => 'Edit template';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String confirmDeleteTemplate(String name) {
    return 'Are you sure you want to delete the template “$name”?';
  }

  @override
  String confirmEditTemplate(String name) {
    return 'Are you sure you want to save changes to the template “$name”?';
  }
}
