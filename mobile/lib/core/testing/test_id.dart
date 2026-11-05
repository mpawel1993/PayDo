import 'package:flutter/widgets.dart';

extension TestIdX on Widget {
  Widget testId(String id) => Semantics(
    identifier: id,
    container: true,
    child: KeyedSubtree(key: ValueKey<String>(id), child: this),
  );
}
