import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/env.dart';
import '../../profile/data/profile_repository.dart';

/// El servidor es quien decide (is_premium en SQL); esto solo adapta la UI.
final isPremiumProvider = Provider<bool>(
  (ref) =>
      ref.watch(myProfileProvider.select((p) => p.value?.isPremium ?? false)),
);

final requestLimitProvider = Provider<int>(
  (ref) => ref.watch(isPremiumProvider)
      ? Env.premiumMaxActiveRequests
      : Env.maxActiveRequests,
);
