import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../core/state/clock_state.dart';
import '../data/sqlite_bills_repository.dart';
import '../domain/bills_repository.dart';
import 'bills_facade.dart';

final billsRepositoryProvider = FutureProvider<BillsRepository>(
  (ref) async => SqliteBillsRepository(await ref.watch(appDatabaseProvider.future)),
);

final billsFacadeProvider = FutureProvider<BillsFacade>(
  (ref) async => BillsFacade(await ref.watch(billsRepositoryProvider.future), ref.watch(clockState)),
);
