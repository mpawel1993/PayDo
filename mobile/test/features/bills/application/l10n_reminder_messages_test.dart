import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:paydo/core/l10n/generated/app_localizations.dart';
import 'package:paydo/features/bills/application/l10n_reminder_messages.dart';
import 'package:paydo/features/bills/domain/bill.dart';
import 'package:paydo/features/bills/domain/calendar_date.dart';
import 'package:paydo/features/bills/domain/reminders/reminder_planner.dart';
import 'package:paydo/features/bills/domain/year_month.dart';

import '../../../support/builders/bill_template_builder.dart';

void main() {
  setUpAll(initializeDateFormatting);

  final reminder = BillReminder(
    bill: Bill(
      template: BillTemplateBuilder().withName('Czynsz').build(),
      month: YearMonth(2026, 9),
      entry: BillEntry(dueDate: CalendarDate(2026, 9, 20)),
    ),
    at: DateTime(2026, 9, 21, 9),
  );

  test('Polish texts', () {
    final messages = L10nReminderMessages(lookupAppLocalizations(const Locale('pl')));
    expect(messages.title(reminder), 'Nieopłacony rachunek');
    expect(messages.body(reminder), 'Czynsz – termin płatności minął 20.09.2026. Oznacz rachunek jako opłacony.');
  });

  test('English texts', () {
    final messages = L10nReminderMessages(lookupAppLocalizations(const Locale('en')));
    expect(messages.title(reminder), 'Unpaid bill');
    expect(messages.body(reminder), 'Czynsz – payment was due 9/20/2026. Mark the bill as paid.');
  });
}
