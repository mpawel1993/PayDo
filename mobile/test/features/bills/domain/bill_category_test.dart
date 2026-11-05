import 'package:flutter_test/flutter_test.dart';
import 'package:paydo/features/bills/domain/bill_category.dart';

void main() {
  test('fromName() maps stored names and rejects unknown ones', () {
    expect(BillCategory.fromName('personal'), BillCategory.personal);
    expect(BillCategory.fromName('company'), BillCategory.company);
    expect(BillCategory.fromName('other'), isNull);
    expect(BillCategory.fromName(null), isNull);
  });
}
