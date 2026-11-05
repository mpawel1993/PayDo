import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef Clock = DateTime Function();

final clockState = Provider<Clock>((ref) => DateTime.now);
