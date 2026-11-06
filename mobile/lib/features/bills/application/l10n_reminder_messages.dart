import '../../../core/l10n/generated/app_localizations.dart';
import '../domain/reminders/reminder_planner.dart';
import 'bill_reminders_service.dart';

final class L10nReminderMessages implements ReminderMessages {
  const L10nReminderMessages(this._l10n);

  final AppLocalizations _l10n;

  @override
  String title(BillReminder reminder) => _l10n.reminderTitle;

  @override
  String body(BillReminder reminder) {
    final due = reminder.bill.dueDate!;
    return _l10n.reminderBody(reminder.bill.template.name, DateTime(due.year, due.month, due.day));
  }
}
