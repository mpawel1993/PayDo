import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('pl')];

  /// Bottom navigation: bills tab label and page title
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get navBills;

  /// Bottom navigation: todo tab label and page title
  ///
  /// In en, this message translates to:
  /// **'Todo'**
  String get navTodo;

  /// Bottom navigation: settings tab label and page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Settings: language section label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language option: Polish
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get languagePolish;

  /// Language option: English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Bills page: button opening the bill templates page
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get billsTemplatesButton;

  /// Bill templates page title
  ///
  /// In en, this message translates to:
  /// **'Bill templates'**
  String get billTemplatesTitle;

  /// Bill category: personal
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get billCategoryPersonal;

  /// Bill category: company
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get billCategoryCompany;

  /// Bills page: empty category section
  ///
  /// In en, this message translates to:
  /// **'No bills. Add a template.'**
  String get billsEmpty;

  /// Bill templates page: empty category section
  ///
  /// In en, this message translates to:
  /// **'No templates'**
  String get billTemplatesEmpty;

  /// Bill templates page: new template name placeholder
  ///
  /// In en, this message translates to:
  /// **'Bill name'**
  String get billTemplateNameHint;

  /// Bill templates page: add template button (accessibility label)
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get billTemplateAdd;

  /// Bill templates page: delete template button (accessibility label)
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String billTemplateDelete(String name);

  /// Back button (accessibility label)
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Bills page: previous month button (accessibility label)
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// Bills page: next month button (accessibility label)
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// Generic data loading error
  ///
  /// In en, this message translates to:
  /// **'Could not load data'**
  String get loadError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
