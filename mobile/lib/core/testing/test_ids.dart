abstract final class TestIds {
  static const appLoading = 'app.loading';

  static const navigationShell = 'navigation.shell';
  static const navigationBar = 'navigation.bar';
  static const navigationTabBills = 'navigation.tab_bills';
  static const navigationTabBillsIcon = 'navigation.tab_bills_icon';
  static const navigationTabTodo = 'navigation.tab_todo';
  static const navigationTabTodoIcon = 'navigation.tab_todo_icon';
  static const navigationTabShopping = 'navigation.tab_shopping';
  static const navigationTabShoppingIcon = 'navigation.tab_shopping_icon';
  static const navigationTabSettings = 'navigation.tab_settings';
  static const navigationTabSettingsIcon = 'navigation.tab_settings_icon';

  static const billsPage = 'bills.page';
  static const billsTitle = 'bills.title';
  static const billsTemplatesButton = 'bills.templates_button';
  static const billsMonthLabel = 'bills.month_label';
  static const billsPreviousMonth = 'bills.previous_month';
  static const billsPreviousMonthIcon = 'bills.previous_month_icon';
  static const billsNextMonth = 'bills.next_month';
  static const billsNextMonthIcon = 'bills.next_month_icon';
  static const billsPager = 'bills.pager';
  static String billsMonth(int monthKey) => 'bills.month.$monthKey';
  static String billsMonthLoading(int monthKey) => 'bills.month.$monthKey.loading';
  static String billsMonthError(int monthKey) => 'bills.month.$monthKey.error';
  static String billsSection(int monthKey, String category) => 'bills.month.$monthKey.section.$category';
  static String billsSectionTitle(int monthKey, String category) => 'bills.month.$monthKey.section.$category.title';
  static String billsSectionEmpty(int monthKey, String category) => 'bills.month.$monthKey.section.$category.empty';
  static String billsRow(int monthKey, int templateId) => 'bills.month.$monthKey.row.$templateId';
  static String billsRowName(int monthKey, int templateId) => 'bills.month.$monthKey.row.$templateId.name';
  static String billsRowCheckbox(int monthKey, int templateId) => 'bills.month.$monthKey.row.$templateId.checkbox';
  static String billsRowDetails(int monthKey, int templateId) => 'bills.month.$monthKey.row.$templateId.details';
  static String billsRowDueDate(int monthKey, int templateId) => 'bills.month.$monthKey.row.$templateId.due_date';
  static String billsRowDueDateIcon(int monthKey, int templateId) => 'bills.month.$monthKey.row.$templateId.due_date_icon';

  static const billTemplatesPage = 'bill_templates.page';
  static const billTemplatesTitle = 'bill_templates.title';
  static const billTemplatesBack = 'bill_templates.back';
  static const billTemplatesBackIcon = 'bill_templates.back_icon';
  static const billTemplatesLoading = 'bill_templates.loading';
  static const billTemplatesError = 'bill_templates.error';
  static String billTemplatesSection(String category) => 'bill_templates.section.$category';
  static String billTemplatesSectionTitle(String category) => 'bill_templates.section.$category.title';
  static String billTemplatesEmpty(String category) => 'bill_templates.section.$category.empty';
  static String billTemplatesInput(String category) => 'bill_templates.section.$category.input';
  static String billTemplatesAdd(String category) => 'bill_templates.section.$category.add';
  static String billTemplatesAddIcon(String category) => 'bill_templates.section.$category.add_icon';
  static String billTemplatesRow(int id) => 'bill_templates.row.$id';
  static String billTemplatesRowName(int id) => 'bill_templates.row.$id.name';
  static String billTemplatesRowDelete(int id) => 'bill_templates.row.$id.delete';
  static String billTemplatesRowDeleteIcon(int id) => 'bill_templates.row.$id.delete_icon';
  static String billTemplatesRowDetails(int id) => 'bill_templates.row.$id.details';
  static String billTemplatesRowEdit(int id) => 'bill_templates.row.$id.edit';
  static String billTemplatesRowEditIcon(int id) => 'bill_templates.row.$id.edit_icon';
  static String billTemplatesDueDayInput(String category) => 'bill_templates.section.$category.due_day_input';
  static const billTemplatesEditDialog = 'bill_templates.edit_dialog';
  static const billTemplatesEditTitle = 'bill_templates.edit_dialog.title';
  static const billTemplatesEditName = 'bill_templates.edit_dialog.name';
  static const billTemplatesEditDueDay = 'bill_templates.edit_dialog.due_day';
  static const billTemplatesEditSave = 'bill_templates.edit_dialog.save';
  static const billTemplatesEditCancel = 'bill_templates.edit_dialog.cancel';

  static const confirmDialog = 'dialog.confirm';
  static const confirmDialogMessage = 'dialog.confirm.message';
  static const confirmDialogYes = 'dialog.confirm.yes';
  static const confirmDialogNo = 'dialog.confirm.no';

  static const dayPicker = 'dialog.day_picker';
  static const dayPickerTitle = 'dialog.day_picker.title';
  static const dayPickerClear = 'dialog.day_picker.clear';
  static const dayPickerCancel = 'dialog.day_picker.cancel';
  static String dayPickerDay(int day) => 'dialog.day_picker.day_$day';

  static const todoPage = 'todo.page';
  static const todoTitle = 'todo.title';

  static const shoppingPage = 'shopping.page';
  static const shoppingTitle = 'shopping.title';

  static const settingsPage = 'settings.page';
  static const settingsTitle = 'settings.title';
  static const settingsLanguageLabel = 'settings.language_label';
  static const settingsLanguageOptions = 'settings.language_options';
  static const settingsLanguageOptionPl = 'settings.language_option_pl';
  static const settingsLanguageOptionEn = 'settings.language_option_en';

  static const all = <String>[
    appLoading,
    navigationShell,
    navigationBar,
    navigationTabBills,
    navigationTabBillsIcon,
    navigationTabTodo,
    navigationTabTodoIcon,
    navigationTabShopping,
    navigationTabShoppingIcon,
    navigationTabSettings,
    navigationTabSettingsIcon,
    billsPage,
    billsTitle,
    billsTemplatesButton,
    billsMonthLabel,
    billsPreviousMonth,
    billsPreviousMonthIcon,
    billsNextMonth,
    billsNextMonthIcon,
    billsPager,
    billTemplatesPage,
    billTemplatesTitle,
    billTemplatesBack,
    billTemplatesBackIcon,
    billTemplatesLoading,
    billTemplatesError,
    billTemplatesEditDialog,
    billTemplatesEditTitle,
    billTemplatesEditName,
    billTemplatesEditDueDay,
    billTemplatesEditSave,
    billTemplatesEditCancel,
    confirmDialog,
    confirmDialogMessage,
    confirmDialogYes,
    confirmDialogNo,
    dayPicker,
    dayPickerTitle,
    dayPickerClear,
    dayPickerCancel,
    todoPage,
    todoTitle,
    shoppingPage,
    shoppingTitle,
    settingsPage,
    settingsTitle,
    settingsLanguageLabel,
    settingsLanguageOptions,
    settingsLanguageOptionPl,
    settingsLanguageOptionEn,
  ];
}
