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
}
