import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/env.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initializeDateFormatting(),
    Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    ),
    // Solo para notificaciones push; si falla, la app funciona igual.
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then<void>((_) {}, onError: (Object e) => debugPrint('Firebase: $e')),
  ]);
  runApp(const ProviderScope(child: FlamengosApp()));
}
