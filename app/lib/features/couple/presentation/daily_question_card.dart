import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/tokens.dart';
import '../../../shared/feedback.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/couple_daily.dart';
import 'daily_questions.dart';

/// Racha de la pareja (días seguidos activos). Se ve apagada si hoy aún no
/// cuenta, para invitar a escribir.
class StreakPill extends ConsumerWidget {
  const StreakPill({super.key, required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final daily = ref.watch(coupleDailyProvider(matchId)).value;
    if (daily == null || daily.streak == 0) return const SizedBox.shrink();
    const flame = Color(0xFFFF9500);
    return GestureDetector(
      onTap: () => showInfo(
        context,
        daily.todayActive ? t.streakHint : t.streakTodayPending,
      ),
      child: GlassPill(
        color: daily.todayActive ? flame : FlamColors.textMuted,
        leading: Icon(
          Icons.local_fire_department_rounded,
          size: 16,
          color: daily.todayActive ? flame : FlamColors.textMuted,
        ),
        child: Text(t.streakDays(daily.streak)),
      ),
    );
  }
}

/// Pregunta del día: cada uno responde y luego ve la respuesta del otro.
/// Se pliega para no quitarle espacio al chat.
class DailyQuestionCard extends ConsumerStatefulWidget {
  const DailyQuestionCard({
    super.key,
    required this.matchId,
    required this.partnerName,
  });

  final String matchId;
  final String partnerName;

  @override
  ConsumerState<DailyQuestionCard> createState() => _DailyQuestionCardState();
}

class _DailyQuestionCardState extends ConsumerState<DailyQuestionCard> {
  final _answer = TextEditingController();
  bool? _open;
  bool _sending = false;

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _answer.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await answerDailyQuestion(ref, text);
      _answer.clear();
      ref.invalidate(coupleDailyProvider(widget.matchId));
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final daily = ref.watch(coupleDailyProvider(widget.matchId)).value;
    if (daily == null) return const SizedBox.shrink();
    final answered = daily.myAnswer != null;
    // Abierta mientras falte mi respuesta; luego se pliega sola.
    final open = _open ?? !answered;

    return Glass(
      padding: EdgeInsets.zero,
      radius: FlamRadius.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(FlamRadius.md),
            onTap: () => setState(() => _open = !open),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
              child: Row(
                children: [
                  Icon(Icons.forum_rounded, size: 20, color: FlamColors.pink),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      open
                          ? t.dailyQuestionTitle
                          : dailyQuestion(t, daily.question),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (!answered && daily.partnerAnswered)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: FlamColors.pink,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Icon(
                    open
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: FlamColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: FlamMotion.medium,
            alignment: Alignment.topCenter,
            child: !open
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          dailyQuestion(t, daily.question),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (!answered) ...[
                          if (daily.partnerAnswered)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                t.dailyQuestionPartnerAnswered(
                                  widget.partnerName,
                                ),
                                style: TextStyle(color: FlamColors.textMuted),
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _answer,
                                  maxLength: 300,
                                  minLines: 1,
                                  maxLines: 3,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                    hintText: t.dailyQuestionHint,
                                    counterText: '',
                                    isDense: true,
                                  ),
                                  onSubmitted: (_) => _send(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              FlamIconButton(
                                icon: const Icon(Icons.arrow_upward_rounded),
                                variant: FlamVariant.primary,
                                size: 44,
                                tooltip: t.dailyQuestionSend,
                                onPressed: _sending ? null : _send,
                              ),
                            ],
                          ),
                        ] else ...[
                          _Answer(who: t.chatYou, text: daily.myAnswer!),
                          const SizedBox(height: 8),
                          daily.partnerAnswer == null
                              ? Text(
                                  t.dailyQuestionWaiting(widget.partnerName),
                                  style: TextStyle(color: FlamColors.textMuted),
                                )
                              : _Answer(
                                  who: widget.partnerName,
                                  text: daily.partnerAnswer!,
                                ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Answer extends StatelessWidget {
  const _Answer({required this.who, required this.text});

  final String who;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
    decoration: BoxDecoration(
      color: FlamColors.glassFill,
      borderRadius: BorderRadius.circular(FlamRadius.sm),
      border: Border(left: BorderSide(color: FlamColors.pink, width: 3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          who,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: FlamColors.pink,
          ),
        ),
        const SizedBox(height: 2),
        Text(text, style: const TextStyle(fontSize: 15.5)),
      ],
    ),
  );
}
