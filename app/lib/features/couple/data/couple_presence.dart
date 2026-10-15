import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

class PartnerPresence {
  const PartnerPresence({this.online = false, this.typing = false});

  final bool online;
  final bool typing;
}

/// "En línea" y "escribiendo…" con Realtime Presence en un canal por pareja.
/// Cada uno publica su estado siempre; la app solo lo muestra a premium.
final couplePresenceProvider = NotifierProvider.autoDispose
    .family<CouplePresenceController, PartnerPresence, String>(
      CouplePresenceController.new,
    );

class CouplePresenceController extends Notifier<PartnerPresence> {
  CouplePresenceController(this.matchId);

  final String matchId;

  /// Si no llega otra pulsación en este tiempo, deja de "escribir".
  static const typingTimeout = Duration(seconds: 4);

  late RealtimeChannel _channel;
  late String _me;
  bool _visible = true;
  bool _typing = false;
  Timer? _typingTimer;

  @override
  PartnerPresence build() {
    final db = ref.watch(supabaseProvider);
    _me = db.myId;
    _channel = db
        .channel(
          'couple:$matchId',
          opts: RealtimeChannelConfig(key: _me, enabled: true),
        )
        .onPresenceSync((_) => _sync())
        .subscribe((status, _) {
          if (status == RealtimeSubscribeStatus.subscribed) _track();
        });

    // En segundo plano no cuenta como "en línea".
    final lifecycle = AppLifecycleListener(
      onShow: () {
        _visible = true;
        _track();
      },
      onHide: () {
        _visible = false;
        _typing = false;
        _channel.untrack();
      },
    );

    ref.onDispose(() {
      _typingTimer?.cancel();
      lifecycle.dispose();
      db.removeChannel(_channel);
    });
    return const PartnerPresence();
  }

  /// Llamar en cada cambio del texto del chat.
  void onTyping(String text) {
    _typingTimer?.cancel();
    final typing = text.trim().isNotEmpty;
    if (typing) _typingTimer = Timer(typingTimeout, () => _setTyping(false));
    _setTyping(typing);
  }

  void stopTyping() {
    _typingTimer?.cancel();
    _setTyping(false);
  }

  void _setTyping(bool typing) {
    if (typing == _typing) return;
    _typing = typing;
    _track();
  }

  void _track() {
    if (_visible) _channel.track({'typing': _typing});
  }

  void _sync() {
    final partner = _channel
        .presenceState()
        .where((s) => s.key != _me && s.presences.isNotEmpty)
        .firstOrNull;
    state = PartnerPresence(
      online: partner != null,
      typing:
          partner?.presences.any((p) => p.payload['typing'] == true) ?? false,
    );
  }
}
