enum BillCategory {
  personal,
  company;

  static BillCategory? fromName(String? name) => values.where((c) => c.name == name).firstOrNull;
}
