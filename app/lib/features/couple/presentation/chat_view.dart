import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  const ChatView({
    super.key,
    required this.matchId,
    required this.me,
    this.partnerName,
  });

  final String matchId;
  final String me;
  final String? partnerName;

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  bool _sending = false;

  /// Mensaje al que se está respondiendo, o que se está editando.
  ChatMessage? _replyTo;
  ChatMessage? _editing;

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
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _startReply(ChatMessage m) {
    HapticFeedback.selectionClick();
    setState(() {
      _editing = null;
      _replyTo = m;
    });
    _focus.requestFocus();
  }

  void _startEdit(ChatMessage m) {
    setState(() {
      _replyTo = null;
      _editing = m;
    });
    _input.text = m.body;
    _input.selection = TextSelection.collapsed(offset: m.body.length);
    _focus.requestFocus();
  }

  void _cancelCompose() {
    if (_editing != null) _input.clear();
    setState(() {
      _replyTo = null;
      _editing = null;
    });
  }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    final repo = ref.read(coupleRepositoryProvider);
    try {
      final editing = _editing;
      if (editing != null) {
        await repo.editMessage(editing.id, body);
      } else {
        await repo.sendMessage(widget.matchId, body, replyTo: _replyTo?.id);
        _scrollToBottom();
      }
      _input.clear();
      setState(() {
        _replyTo = null;
        _editing = null;
      });
      ref.read(couplePresenceProvider(widget.matchId).notifier).stopTyping();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _showActions(ChatMessage m) async {
    final t = context.l10n;
    final mine = m.senderId == widget.me;
    HapticFeedback.mediumImpact();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) {
        Widget action(IconData icon, String label, VoidCallback onTap) =>
            ListTile(
              leading: Icon(icon, color: FlamColors.pink),
              title: Text(label),
              onTap: () {
                Navigator.pop(sheet);
                onTap();
              },
            );
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              action(Icons.reply_rounded, t.chatReply, () => _startReply(m)),
              if (mine && m.canEdit(DateTime.now()))
                action(Icons.edit_rounded, t.chatEdit, () => _startEdit(m)),
              action(Icons.copy_rounded, t.chatCopy, () {
                Clipboard.setData(ClipboardData(text: m.body));
                showInfo(context, t.chatCopied);
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  String _authorOf(ChatMessage m) => m.senderId == widget.me
      ? context.l10n.chatYou
      : widget.partnerName ?? context.l10n.someone;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
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
    final byId = {for (final m in messages.value ?? <ChatMessage>[]) m.id: m};

    final composing = _editing ?? _replyTo;

    return Column(
      children: [
        Expanded(
          child: messages.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState(
              icon: Icons.cloud_off_rounded,
              title: t.chatLoadError,
              message: describeError(context, e),
            ),
            data: (list) => list.isEmpty && !typing
                ? EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: t.chatEmptyTitle,
                    message: t.chatEmptyMessage,
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
                      final quoted = m.replyTo == null ? null : byId[m.replyTo];
                      return _SwipeToReply(
                        key: ValueKey(m.id),
                        onReply: () => _startReply(m),
                        child: GestureDetector(
                          onLongPress: () => _showActions(m),
                          // Clic derecho en la web / escritorio.
                          onSecondaryTap: () => _showActions(m),
                          child: _Bubble(
                            message: m,
                            mine: m.senderId == widget.me,
                            // Agrupa mensajes seguidos del mismo autor.
                            tail: next == null || next.senderId != m.senderId,
                            quote: m.replyTo == null
                                ? null
                                : quoted == null
                                ? (null, t.chatMessageUnavailable)
                                : (_authorOf(quoted), quoted.body),
                            receipt: premium && index == lastMine
                                ? partnerReadAt != null &&
                                          !partnerReadAt.isBefore(m.createdAt)
                                      ? t.chatSeen(
                                          DateFormat.Hm(
                                            context.localeTag,
                                          ).format(partnerReadAt.toLocal()),
                                        )
                                      : t.chatSent
                                : null,
                          ),
                        ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSize(
                    duration: FlamMotion.fast,
                    child: composing == null
                        ? const SizedBox(width: double.infinity)
                        : _ComposeBanner(
                            icon: _editing != null
                                ? Icons.edit_rounded
                                : Icons.reply_rounded,
                            title: _editing != null
                                ? t.chatEditing
                                : t.chatReplyingTo(_authorOf(composing)),
                            body: composing.body,
                            onCancel: _cancelCompose,
                          ),
                  ),
                  Glass(
                    blur: true,
                    radius: FlamRadius.pill,
                    padding: const EdgeInsets.fromLTRB(18, 4, 4, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _input,
                            focusNode: _focus,
                            decoration: InputDecoration(
                              hintText: t.chatHint,
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
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
                          icon: Icon(
                            _editing != null
                                ? Icons.check_rounded
                                : Icons.arrow_upward_rounded,
                          ),
                          variant: FlamVariant.primary,
                          size: 44,
                          tooltip: t.chatSend,
                          onPressed: _sending ? null : _send,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Deslizar un mensaje a la derecha para responderlo.
class _SwipeToReply extends StatefulWidget {
  const _SwipeToReply({super.key, required this.child, required this.onReply});

  final Widget child;
  final VoidCallback onReply;

  @override
  State<_SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<_SwipeToReply> {
  static const _trigger = 56.0;
  double _dx = 0;

  @override
  Widget build(BuildContext context) {
    final progress = (_dx / _trigger).clamp(0.0, 1.0);
    return GestureDetector(
      onHorizontalDragUpdate: (d) =>
          setState(() => _dx = (_dx + d.delta.dx).clamp(0, 80)),
      onHorizontalDragEnd: (_) {
        if (_dx >= _trigger) widget.onReply();
        setState(() => _dx = 0);
      },
      onHorizontalDragCancel: () => setState(() => _dx = 0),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Opacity(
            opacity: progress,
            child: Icon(Icons.reply_rounded, color: FlamColors.pink),
          ),
          AnimatedContainer(
            duration: _dx == 0 ? FlamMotion.fast : Duration.zero,
            transform: Matrix4.translationValues(_dx, 0, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

/// Barra sobre el campo de texto: "Respondiendo a…" o "Editando mensaje".
class _ComposeBanner extends StatelessWidget {
  const _ComposeBanner({
    required this.icon,
    required this.title,
    required this.body,
    required this.onCancel,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Glass(
      blur: true,
      radius: FlamRadius.md,
      padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: FlamColors.pink),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: FlamColors.pink,
                  ),
                ),
                Text(
                  body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: FlamColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCancel,
            icon: Icon(Icons.close_rounded, color: FlamColors.textMuted),
          ),
        ],
      ),
    ),
  );
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.mine,
    required this.tail,
    this.quote,
    this.receipt,
  });

  final ChatMessage message;
  final bool mine;
  final bool tail;

  /// Mensaje citado: (autor, texto). Autor null = ya no existe.
  final (String?, String)? quote;

  /// "Visto 10:42" / "Enviado" bajo mi último mensaje (solo premium).
  final String? receipt;

  @override
  Widget build(BuildContext context) {
    const r = Radius.circular(FlamRadius.lg);
    const small = Radius.circular(6);
    final fg = mine ? FlamColors.onAccent : FlamColors.text;
    final meta = mine
        ? FlamColors.onAccent.withValues(alpha: 0.75)
        : FlamColors.textMuted;
    final time = DateFormat.Hm(
      context.localeTag,
    ).format(message.createdAt.toLocal());

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
            if (quote case (final author, final text))
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                decoration: BoxDecoration(
                  color: fg.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border(
                    left: BorderSide(
                      color: mine ? fg : FlamColors.pink,
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (author != null)
                      Text(
                        author,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: mine ? fg : FlamColors.pink,
                        ),
                      ),
                    Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: meta,
                        fontStyle: author == null ? FontStyle.italic : null,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              message.body,
              style: TextStyle(fontSize: 15.5, height: 1.3, color: fg),
            ),
            const SizedBox(height: 2),
            Text(
              message.edited ? '${context.l10n.chatEdited} · $time' : time,
              style: TextStyle(fontSize: 11, color: meta),
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
