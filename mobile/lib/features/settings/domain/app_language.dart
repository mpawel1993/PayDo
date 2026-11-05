enum AppLanguage {
  pl('pl'),
  en('en');

  const AppLanguage(this.code);

  final String code;

  static const fallback = AppLanguage.pl;

  static AppLanguage? fromCode(String? code) => values.where((l) => l.code == code).firstOrNull;
}
