sealed class BillsError implements Exception {
  const BillsError();
}

final class EmptyBillName extends BillsError {
  const EmptyBillName();
}

final class BillNameTooLong extends BillsError {
  const BillNameTooLong(this.maxLength);

  final int maxLength;
}

final class BillTemplateNotFound extends BillsError {
  const BillTemplateNotFound(this.id);

  final int id;
}

final class InvalidDueDay extends BillsError {
  const InvalidDueDay(this.day);

  final int day;
}
