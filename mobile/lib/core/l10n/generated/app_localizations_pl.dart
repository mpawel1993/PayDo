// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get navBills => 'Rachunki';

  @override
  String get navTodo => 'Todo';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get languagePolish => 'Polski';

  @override
  String get languageEnglish => 'Angielski';

  @override
  String get billsTemplatesButton => 'Szablony';

  @override
  String get billTemplatesTitle => 'Szablony rachunków';

  @override
  String get billCategoryPersonal => 'Osobiste';

  @override
  String get billCategoryCompany => 'Firmowe';

  @override
  String get billsEmpty => 'Brak rachunków. Dodaj szablon.';

  @override
  String get billTemplatesEmpty => 'Brak szablonów';

  @override
  String get billTemplateNameHint => 'Nazwa rachunku';

  @override
  String get billTemplateAdd => 'Dodaj';

  @override
  String billTemplateDelete(String name) {
    return 'Usuń $name';
  }

  @override
  String get back => 'Wstecz';

  @override
  String get previousMonth => 'Poprzedni miesiąc';

  @override
  String get nextMonth => 'Następny miesiąc';

  @override
  String get loadError => 'Nie udało się wczytać danych';

  @override
  String get navShopping => 'Zakupy';

  @override
  String billDueDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Termin: $dateString';
  }

  @override
  String billPaidOn(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Zapłacono: $dateString';
  }

  @override
  String billSetDueDate(String name) {
    return 'Ustaw termin płatności: $name';
  }

  @override
  String get reminderTitle => 'Nieopłacony rachunek';

  @override
  String reminderBody(String name, DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$name – termin płatności minął $dateString. Oznacz rachunek jako opłacony.';
  }

  @override
  String get reminderChannelName => 'Przypomnienia o rachunkach';

  @override
  String get billTemplateDueDayHint => 'Dzień';

  @override
  String get billTemplateDueDayPickerTitle => 'Dzień terminu płatności';

  @override
  String get billTemplateNoDueDay => 'Bez terminu';

  @override
  String billTemplateDueDay(int day) {
    return 'Termin: $day. dzień miesiąca';
  }

  @override
  String billTemplateEdit(String name) {
    return 'Edytuj $name';
  }

  @override
  String get billTemplateEditTitle => 'Edytuj szablon';

  @override
  String get save => 'Zapisz';

  @override
  String get cancel => 'Anuluj';

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String confirmDeleteTemplate(String name) {
    return 'Czy na pewno usunąć szablon „$name”?';
  }

  @override
  String confirmEditTemplate(String name) {
    return 'Czy na pewno zapisać zmiany w szablonie „$name”?';
  }
}
