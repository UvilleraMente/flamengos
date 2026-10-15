import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/errors.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../premium/data/premium.dart';
import '../domain/couple.dart';
import '../data/couple_presence.dart';
import '../data/couple_repository.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({super.key, required this.matchId, required this.me});

  final String matchId;
  final String me;

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  /// Último mensaje del otro que ya marcamos como leído.
  DateTime? _readUpTo;

  @override
  void initState() {
    super.initState();
    _input.addListener(
      () => ref
          .read(couplePresenceProvider(widget.matchId).notifier)
          .onTyping(_input.text),
    );
    ref.listenManual(messagesProvider(widget.matchId), (before, next) {
      _markRead(next.value);
      // Al llegar un mensaje nuevo (mío o de mi pareja), baja hasta verlo.
      final last = next.value?.lastOrNull;
      if (last != null && last.id != before?.value?.lastOrNull?.id) {
        _scrollToBottom();
      }
    }, fireImmediately: true);
  }

  /// La lista está invertida: el final del chat es la posición 0.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        0,
        duration: FlamMotion.medium,
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _markRead(List<ChatMessage>? messages) {
    final last = messages?.where((m) => m.senderId != widget.me).lastOrNull;
    if (last == null) return;
    final upTo = _readUpTo;
    if (upTo != null && !last.createdAt.isAfter(upTo)) return;
    _readUpTo = last.createdAt;
    // Si falla, se reintenta con el próximo mensaje.
    ref.read(coupleRepositoryProvider).markRead(widget.matchId).ignore();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(coupleRepositoryProvider)
          .sendMessage(widget.matchId, body);
      _input.clear();
      _scrollToBottom();
      ref.read(couplePresenceProvider(widget.matchId).notifier).stopTyping();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider(widget.matchId));
    final premium = ref.watch(isPremiumProvider);
    // Solo premium: el servidor no envía la lectura del otro a cuentas gratis.
    final partnerReadAt = premium
        ? ref
              .watch(chatReadsProvider(widget.matchId))
              .value
              ?.entries
              .where((e) => e.key != widget.me)
              .firstOrNull
              ?.value
        : null;
    final typing =
        premium && ref.watch(couplePresenceProvider(widget.matchId)).typing;
    // El aviso de lectura va bajo mi último mensaje.
    final lastMine =
        messages.value?.lastIndexWhere((m) => m.senderId == widget.me) ?? -1;

    return Column(
      children: [
        Expanded(
          child: messages.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState(
              icon: Icons.cloud_off_rounded,
              title: context.l10n.chatLoadError,
              message: describeError(context, e),
            ),
            data: (list) => list.isEmpty && !typing
                ? EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: context.l10n.chatEmptyTitle,
                    message: context.l10n.chatEmptyMessage,
                  )
                : ListView.builder(
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: list.length + (typing ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (typing) {
                        if (i == 0) return const _TypingBubble();
                        i--;
                      }
                      final index = list.length - 1 - i;
                      final m = list[index];
                      final next = index + 1 < list.length
                          ? list[index + 1]
                          : null;
                      return _Bubble(
                        message: m,
                        mine: m.senderId == widget.me,
                        // Agrupa mensajes seguidos del mismo autor.
                        tail: next == null || next.senderId != m.senderId,
                        receipt: premium && index == lastMine
                            ? partnerReadAt != null &&
                                      !partnerReadAt.isBefore(m.createdAt)
                                  ? context.l10n.chatSeen(
                                      DateFormat.Hm(
                                        context.localeTag,
                                      ).format(partnerReadAt.toLocal()),
                                    )
                                  : context.l10n.chatSent
                            : null,
                      );
                    },
                  ),
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Glass(
                blur: true,
                radius: FlamRadius.pill,
                padding: const EdgeInsets.fromLTRB(18, 4, 4, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        decoration: InputDecoration(
                          hintText: context.l10n.chatHint,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: 2000,
                        buildCounter:
                            (
                              _, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => null,
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FlamIconButton(
                      icon: const Icon(Icons.arrow_upward_rounded),
                      variant: FlamVariant.primary,
                      size: 44,
                      tooltip: context.l10n.chatSend,
                      onPressed: _sending ? null : _send,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.mine,
    required this.tail,
    this.receipt,
  });

  final ChatMessage message;
  final bool mine;
  final bool tail;

  /// "Visto 10:42" / "Enviado" bajo mi último mensaje (solo premium).
  final String? receipt;

  @override
  Widget build(BuildContext context) {
    const r = Radius.circular(FlamRadius.lg);
    const small = Radius.circular(6);
    final bubble = Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: EdgeInsets.only(bottom: receipt != null ? 2 : (tail ? 10 : 3)),
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 7),
        decoration: BoxDecoration(
          gradient: mine ? FlamGradients.primary : FlamGradients.glass,
          border: mine ? null : Border.all(color: FlamColors.glassBorder),
          borderRadius: BorderRadius.only(
            topLeft: r,
            topRight: r,
            bottomLeft: mine || !tail ? r : small,
            bottomRight: !mine || !tail ? r : small,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.body,
              style: TextStyle(
                fontSize: 15.5,
                height: 1.3,
                color: mine ? FlamColors.onAccent : FlamColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat.Hm(
                context.localeTag,
              ).format(message.createdAt.toLocal()),
              style: TextStyle(
                fontSize: 11,
                color: mine ? FlamColors.onPhotoMuted : FlamColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
    if (receipt == null) return bubble;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        bubble,
        Padding(
          padding: const EdgeInsets.only(right: 6, bottom: 10),
          child: Text(
            receipt!,
            style: TextStyle(fontSize: 11.5, color: FlamColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        gradient: FlamGradients.glass,
        border: Border.all(color: FlamColors.glassBorder),
        borderRadius: BorderRadius.circular(FlamRadius.lg),
      ),
      child: Text(
        context.l10n.chatTyping,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: FlamColors.textMuted,
        ),
      ),
    ),
  );
}
