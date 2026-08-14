import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_colors.dart';

import 'package:handori/core/constants/app_text_styles.dart';
import 'package:handori/features/bus/domain/model/shuttle_schedule.dart';

// ─── Color tokens ──────────────────────────────────────────────────────────
const Color _kPrimary = AppColors.primary;
const Color _kBgBase = AppColors.surface;
const Color _kBorderSoft = AppColors.divider;
const Color _kTextPrimary = AppColors.textPrimary;
const Color _kTextMuted = AppColors.textMuted;

final TextStyle _kBusSubLabel = AppTextStyles.caption04.copyWith(
  color: _kTextMuted,
  letterSpacing: -0.1,
);

/// 다음 셔틀 정보를 강조해 보여주는 공용 히어로 카드.
///
/// [NextShuttleCalculator] 결과([next])만으로 렌더링하는 순수 presentation 위젯.
/// 홈 화면·버스 상세 화면이 동일한 [nextShuttleProvider] 데이터로 이 카드를
/// 재사용해 표시 시간이 항상 일치하도록 한다.
class NextShuttleCard extends StatelessWidget {
  /// 노선/방면 라벨(예: '정왕역(셔틀)행').
  final String route;

  /// 현재 시각 기준 다음 셔틀 계산 결과.
  final NextShuttle next;

  const NextShuttleCard({super.key, required this.route, required this.next});

  @override
  Widget build(BuildContext context) {
    final remain = next.remainMinutes;
    // 카운트다운이 보이는 구간(15분 이내)이 곧 임박 구간이다.
    final isImminent = next.showsMinutes && remain != null && remain > 0;
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
                    Text(
                      '다음 셔틀',
                      style: AppTextStyles.caption04.copyWith(
                        color: _kTextMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      route,
                      style: AppTextStyles.caption01.copyWith(
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
            showsMinutes: isImminent,
            remain: remain,
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

  const _HeroValue({
    required this.next,
    required this.showsMinutes,
    required this.remain,
  });

  @override
  Widget build(BuildContext context) {
    if (showsMinutes && remain != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '$remain',
            style: AppTextStyles.display01.copyWith(
              color: _kPrimary,
              letterSpacing: -1.5,
              height: 1.0,
            ),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '분 후 출발',
              style: AppTextStyles.caption01.copyWith(color: _kTextMuted),
            ),
          ),
        ],
      );
    }

    // 15분보다 멀면 분 숫자를 신뢰할 수 없어 안내하지 않는다.
    // 그 외에는 정각 출발 직전이면 "곧 도착", 나머지는 상태 라벨.
    final label = next.isBeyondCountdown
        ? '도착정보없음'
        : (next.status == ShuttleStatus.upcoming)
            ? '곧 도착'
            : (next.statusLabel ?? '-');

    // 도착정보없음은 알릴 내용이 없는 상태라 강조하지 않는다.
    final emphasize = !next.isBeyondCountdown &&
        (next.status == ShuttleStatus.upcoming ||
            next.status == ShuttleStatus.flexible ||
            next.status == ShuttleStatus.arrivalBoarding);

    return Text(
      label,
      style: AppTextStyles.display02.copyWith(
        color: emphasize ? _kPrimary : _kTextMuted,
        letterSpacing: -0.6,
        height: 1.1,
      ),
    );
  }
}
