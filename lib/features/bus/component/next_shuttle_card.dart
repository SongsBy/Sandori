import 'package:flutter/material.dart';

import 'package:handori/features/bus/domain/model/shuttle_schedule.dart';

// ─── Color tokens ──────────────────────────────────────────────────────────
const Color _kPrimary = Color(0xFF00C4F9);
const Color _kBgBase = Colors.white;
const Color _kBorderSoft = Color(0xFFF0F0F8);
const Color _kTextPrimary = Color(0xFF1A1A1A);
const Color _kTextMuted = Color(0xFF8A8F98);

const TextStyle _kBusSubLabel = TextStyle(
  fontSize: 12.5,
  fontWeight: FontWeight.w500,
  color: _kTextMuted,
  letterSpacing: -0.1,
);

/// 다음 셔틀 정보를 강조해 보여주는 공용 히어로 카드.
///
/// [NextShuttleCalculator] 결과([next])만으로 렌더링하는 순수 presentation 위젯.
/// 홈 화면·버스 상세 화면이 동일한 [nextShuttleProvider] 데이터로 이 카드를
/// 재사용해 표시 시간이 항상 일치하도록 한다.
class NextShuttleCard extends StatelessWidget {
  /// 임박 강조 기준(분).
  static const int _imminentThreshold = 15;

  /// 노선/방면 라벨(예: '정왕역(셔틀)행').
  final String route;

  /// 현재 시각 기준 다음 셔틀 계산 결과.
  final NextShuttle next;

  const NextShuttleCard({super.key, required this.route, required this.next});

  @override
  Widget build(BuildContext context) {
    final remain = next.remainMinutes;
    final showsMinutes = next.showsMinutes && remain != null && remain > 0;
    final isImminent = showsMinutes && remain <= _imminentThreshold;
    final subText = next.subText;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isImminent
              ? [
                  _kPrimary.withValues(alpha: 0.16),
                  _kPrimary.withValues(alpha: 0.04),
                ]
              : [_kBgBase, _kBgBase],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isImminent ? _kPrimary.withValues(alpha: 0.30) : _kBorderSoft,
        ),
        boxShadow: [
          BoxShadow(
            color: isImminent
                ? _kPrimary.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _kPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.airport_shuttle_rounded,
                  color: _kPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '다음 셔틀',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _kTextMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      route,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _kTextPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // 메인 표시 — 분 카운트다운 또는 상태 라벨.
          _HeroValue(
            next: next,
            showsMinutes: showsMinutes,
            remain: remain,
            isImminent: isImminent,
          ),
          if (subText != null && subText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subText,
              style: _kBusSubLabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroValue extends StatelessWidget {
  final NextShuttle next;
  final bool showsMinutes;
  final int? remain;
  final bool isImminent;

  const _HeroValue({
    required this.next,
    required this.showsMinutes,
    required this.remain,
    required this.isImminent,
  });

  @override
  Widget build(BuildContext context) {
    if (showsMinutes && remain != null) {
      final color = isImminent ? _kPrimary : _kTextPrimary;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '$remain',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -1.5,
              height: 1.0,
            ),
          ),
          const SizedBox(width: 4),
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              '분 후 출발',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kTextMuted,
              ),
            ),
          ),
        ],
      );
    }

    // 정각 출발 직전 → "곧 도착", 그 외는 상태 라벨.
    final label = (next.status == ShuttleStatus.upcoming)
        ? '곧 도착'
        : (next.statusLabel ?? '-');
    final emphasize = next.status == ShuttleStatus.upcoming ||
        next.status == ShuttleStatus.flexible ||
        next.status == ShuttleStatus.arrivalBoarding;

    return Text(
      label,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: emphasize ? _kPrimary : _kTextMuted,
        letterSpacing: -0.6,
        height: 1.1,
      ),
    );
  }
}
