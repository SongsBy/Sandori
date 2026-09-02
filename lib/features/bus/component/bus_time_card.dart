import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/core/constants/app_text_styles.dart';
import 'package:handori/features/bus/domain/model/shuttle_schedule.dart';
import 'package:handori/features/bus/presentation/provider/next_shuttle_provider.dart';

const _primary = AppColors.primary;
const _subtleBg = AppColors.subtleBg;
const _border = AppColors.cardBorder;

class Bustimescreen extends ConsumerStatefulWidget {
  final VoidCallback? onTap;
  final bool showHeader;
  const Bustimescreen({this.onTap, this.showHeader = true, super.key});

  @override
  ConsumerState<Bustimescreen> createState() => _BustimescreenState();
}

class _BustimescreenState extends ConsumerState<Bustimescreen> {
  bool _isReverse = false; // false: 학교→정왕역 / true: 정왕역→학교

  /// 상세 화면과 동일한 [nextShuttleProvider] 결과를 홈 카드용 한 줄 텍스트로 변환.
  String _arrivalText(NextShuttle next) {
    final remain = next.remainMinutes;
    if (next.showsMinutes && remain != null && remain > 0) {
      return '$remain분 후 출발';
    }
    // 15분보다 멀면 분 숫자를 신뢰할 수 없어 안내하지 않는다.
    if (next.isBeyondCountdown) return '도착정보없음';
    if (next.status == ShuttleStatus.upcoming) return '곧 도착';
    return next.statusLabel ?? '운행 정보 없음';
  }

  @override
  Widget build(BuildContext context) {
    final String from = _isReverse ? '정왕역' : '학교';
    final String to = _isReverse ? '학교' : '정왕역';
    final String stopName = _isReverse ? '정왕역 버스정류장' : '정문 버스정류장';
    final String destination = _isReverse ? '학교 방면' : '정왕역 방면';

    // 상세 화면과 동일한 방향 매핑 → 동일한 다음 셔틀 결과.
    final direction = _isReverse
        ? ShuttleDirection.jeongwangToSchool
        : ShuttleDirection.schoolToJeongwang;
    final nextShuttle = ref.watch(
      nextShuttleProvider(
        route: ShuttleRoute.route1,
        direction: direction,
      ),
    );

    final List<Map<String, dynamic>> nextBus = [
      {
        'busNumber': '33',
        'goTo': destination,
        'time': '2분',
      },
      {
        'busNumber': '20-1',
        'goTo': destination,
        'time': '5분',
      },
    ];

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: .06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showHeader) ...[
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: _subtleBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.directions_bus_rounded,
                        color: _primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '셔틀버스',
                        style: AppTextStyles.title03,
                      ),
                    ),
                    _Badge(
                      text: '운행 중',
                      bg: AppColors.primaryLight,
                      fg: _primary,
                      borderColor: AppColors.primaryBorder,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              // 방향 표시 + 토글
              Row(
                children: [
                  _DirectionChip(label: from, isOrigin: true),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: Colors.black38,
                  ),
                  const SizedBox(width: 6),
                  _DirectionChip(label: to, isOrigin: false),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _isReverse = !_isReverse),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _subtleBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.swap_horiz_rounded,
                            size: 16,
                            color: _primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '반대 방면',
                            style: AppTextStyles.caption04.copyWith(
                              color: _primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _arrivalText(nextShuttle),
                    style: AppTextStyles.caption01.copyWith(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: _border),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.directions_bus_rounded,
                    size: 18,
                    color: _primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    stopName,
                    style: AppTextStyles.caption01,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 실시간 시내버스 도착 — 공공 API 연동 전까지 블러 + 준비 중 안내.
              _ComingSoonBlur(
                child: Column(
                  children: [
                    for (final item in nextBus)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: _BusTile(
                          number: item['busNumber'] as String,
                          destination: item['goTo'] as String,
                          etaText: item['time'] as String,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _subtleBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: _primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '도착 시간은 교통 상황에 따라 달라질 수 있어요.',
                        style: AppTextStyles.caption04.copyWith(
                          color: const Color(0xFF5A6B7A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 준비 중 섹션 처리 — 내용을 은은하게 블러하고 중앙에 알림 필을 띄운다.
///
/// 실시간 시내버스 도착(공공 API) 연동 전까지의 임시 상태. 내용은 미리보기로
/// 흐릿하게 남겨 기대감을 주되, 터치·접근성에서는 완전히 제외한다.
class _ComingSoonBlur extends StatelessWidget {
  final Widget child;

  const _ComingSoonBlur({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 미리보기 내용 — 블러 + 살짝 투명. 조작 불가.
          ExcludeSemantics(
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Opacity(opacity: 0.8, child: child),
              ),
            ),
          ),
          // 흰 베일 — 가운데가 살짝 더 밝아 필이 자연스럽게 떠 보인다.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0.55),
                    Colors.white.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),
          // 중앙 알림 필.
          Container(
            padding: const EdgeInsets.fromLTRB(10, 7, 14, 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    size: 13,
                    color: _primary,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  '주변 마을버스 도착정보 준비중이에요',
                  style: AppTextStyles.caption04.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionChip extends StatelessWidget {
  final String label;
  final bool isOrigin;
  const _DirectionChip({required this.label, required this.isOrigin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOrigin ? _primary : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption02.copyWith(
          color: isOrigin ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final Color borderColor;

  const _Badge({
    required this.text,
    required this.bg,
    required this.fg,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption04.copyWith(color: fg),
      ),
    );
  }
}

class _BusTile extends StatelessWidget {
  final String number;
  final String destination;
  final String etaText;

  const _BusTile({
    required this.number,
    required this.destination,
    required this.etaText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 바텀 네비게이션과 같은 글리프. 시내버스는 상태색(초록)으로 구분한다.
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF9F0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCFEAD2)),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.directions_bus_rounded,
            size: 22,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF9F0),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCFEAD2)),
                ),
                child: Text(
                  number,
                  style: AppTextStyles.caption02.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  destination,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption03.copyWith(
                    color: const Color(0xFF6B7A89),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFD1D1)),
          ),
          child: Text(
            etaText,
            style: AppTextStyles.caption02.copyWith(
              color: AppColors.danger,
            ),
          ),
        ),
      ],
    );
  }
}
