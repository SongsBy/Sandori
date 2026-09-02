import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:handori/core/constants/app_colors.dart';

import 'package:handori/common/component/app_top_bar.dart';
import 'package:handori/common/component/coming_soon_snackbar.dart';
import 'package:handori/core/constants/app_text_styles.dart';
import 'package:handori/features/bus/data/data_source/shuttle_schedule_data.dart';
import 'package:handori/features/bus/domain/model/shuttle_schedule.dart';
import 'package:handori/features/bus/presentation/provider/next_shuttle_provider.dart';

// ─── Color tokens ──────────────────────────────────────────────────────────
const Color _kPrimary = AppColors.primary;
const Color _kBgBase = AppColors.surface;
const Color _kBgSoft = AppColors.background;
const Color _kTextPrimary = AppColors.textPrimary;
const Color _kTextMuted = AppColors.textMuted;

/// 시안 고정값 — 카드 테두리(#E5E5EC). 앱 토큰(cardBorder)보다 중립 회색이라
/// 시안 그대로 유지한다.
const Color _kBorder = Color(0xFFE5E5EC);

/// 시안 고정값 — 다음 버스 헤더·시간 칩의 옅은 파랑.
const Color _kPrimaryTint = Color(0xFFE1F2FB);

/// 시안 고정값 — 운행 종료 타이틀·스왑 아이콘의 진회색.
const Color _kTextStrong = Color(0xFF505050);

// ─── Layout tokens ─────────────────────────────────────────────────────────
const double _kCardRadius = 16.0;

/// 시안에서 추출한 단색 스트로크 SVG 아이콘. [color]로 전체를 틴트한다.
class _SvgIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color color;

  const _SvgIcon(this.asset, {required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/bus/$asset',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

class BusTimeDetailScreen extends ConsumerStatefulWidget {
  const BusTimeDetailScreen({super.key});

  @override
  ConsumerState<BusTimeDetailScreen> createState() =>
      _BusTimeDetailScreenState();
}

class _BusTimeDetailScreenState extends ConsumerState<BusTimeDetailScreen> {
  int _selectedDestination = 0; // 0: 정왕역 방면, 1: 학교 방면
  DateTime _lastUpdated = DateTime.now();

  // 출발·도착 스왑 — 기존 방면 토글을 스왑 버튼 하나로 대체했다.
  void _onSwapPressed() {
    setState(() => _selectedDestination = 1 - _selectedDestination);
  }

  void _onUserPressed() => showComingSoonSnackBar(context);

  // 당겨서 새로고침 — 셔틀 정보를 다시 불러온다.
  Future<void> _onRefresh() async {
    ref.invalidate(nextShuttleProvider);
    setState(() => _lastUpdated = DateTime.now());
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final isToStation = _selectedDestination == 0;

    // 방면별 라벨 / 데이터.
    final originLabel = isToStation ? '한국공학대 정문' : '정왕역';
    final destinationLabel = isToStation ? '정왕역' : '한국공학대 정문';

    // 화면 스왑 → 노선1(정왕역↔본교) 방향 매핑.
    final direction = isToStation
        ? ShuttleDirection.schoolToJeongwang
        : ShuttleDirection.jeongwangToSchool;
    final nextShuttle = ref.watch(
      nextShuttleProvider(
        route: ShuttleRoute.route1,
        direction: direction,
      ),
    );

    final now = DateTime.now();
    final timetable = ShuttleScheduleData.timetableFor(
      route: ShuttleRoute.route1,
      direction: direction,
      dayType: ShuttleScheduleData.dayTypeOf(now),
    );

    return Scaffold(
      backgroundColor: _kBgSoft,
      appBar: AppTopBar(
        title: '버스조회',
        onUser: _onUserPressed,
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: _kPrimary,
          backgroundColor: _kBgBase,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 64),
            children: [
              _RouteCard(
                origin: originLabel,
                destination: destinationLabel,
                onSwap: _onSwapPressed,
              ),
              const SizedBox(height: 16),
              _NextBusCard(next: nextShuttle),
              const SizedBox(height: 24),
              _TimetableSectionHeader(
                routeLabel: '$originLabel → $destinationLabel',
              ),
              const SizedBox(height: 10),
              _TimetableCard(
                timetable: timetable,
                nowMinutes: now.hour * 60 + now.minute,
              ),
              const SizedBox(height: 20),
              _FooterNote(lastUpdated: _lastUpdated),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Route card — 출발/도착 + 스왑 버튼
// ───────────────────────────────────────────────────────────────────────────

class _RouteCard extends StatelessWidget {
  final String origin;
  final String destination;
  final VoidCallback onSwap;

  const _RouteCard({
    required this.origin,
    required this.destination,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kBgBase,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _endpoint(
                  icon: 'ic_pin.svg',
                  iconColor: _kPrimary,
                  label: '출발',
                  value: origin,
                ),
                // 출발·도착 사이 점선 — 핀 아이콘 중심(왼쪽 9px)에 맞춘다.
                const Padding(
                  padding: EdgeInsets.only(left: 8.5, top: 6, bottom: 6),
                  child: CustomPaint(
                    size: Size(1, 16),
                    painter: _DashedLinePainter(_kBorder),
                  ),
                ),
                _endpoint(
                  icon: 'ic_flag.svg',
                  iconColor: _kTextMuted,
                  label: '도착',
                  value: destination,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _SwapButton(onTap: onSwap),
        ],
      ),
    );
  }

  Widget _endpoint({
    required String icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        _SvgIcon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption04.copyWith(color: _kTextMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption01.copyWith(
                  color: _kTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwapButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SwapButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kBgBase,
      shape: const CircleBorder(side: BorderSide(color: _kBorder)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: _SvgIcon('ic_swap.svg', size: 20, color: _kTextStrong),
          ),
        ),
      ),
    );
  }
}

/// 출발·도착 사이 세로 점선.
class _DashedLinePainter extends CustomPainter {
  final Color color;

  const _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 3.0;
    const gap = 3.0;
    double y = 0;
    while (y < size.height) {
      final end = (y + dash) > size.height ? size.height : (y + dash);
      canvas.drawLine(Offset(0, y), Offset(0, end), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

// ───────────────────────────────────────────────────────────────────────────
// Next bus card — 다음 버스 상태
// ───────────────────────────────────────────────────────────────────────────

class _NextBusCard extends StatelessWidget {
  final NextShuttle next;

  const _NextBusCard({required this.next});

  @override
  Widget build(BuildContext context) {
    final remain = next.remainMinutes;

    // 상태 → 타이틀/보조 문구. 활성 상태만 파란 강조를 준다.
    String title;
    String? sub;
    var active = true;
    if (next.showsMinutes && remain != null && remain > 0) {
      title = '$remain분 후 출발';
      sub = next.subText;
    } else if (next.showsMinutes) {
      title = '곧 출발';
      sub = next.subText;
    } else if (next.isBeyondCountdown) {
      title = '${next.departureTime!.label} 출발';
      sub = '다음 버스 출발 시각이에요';
    } else if (next.status == ShuttleStatus.flexible ||
        next.status == ShuttleStatus.arrivalBoarding) {
      title = next.statusLabel ?? '-';
      sub = next.subText;
    } else {
      active = false;
      title = next.statusLabel ?? '운행 종료';
      sub = next.status == ShuttleStatus.closed
          ? '오늘 예정된 버스가 없어요'
          : next.subText;
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _kBgBase,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: _kPrimaryTint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _kPrimaryTint.withValues(alpha: 0.6),
              border: const Border(bottom: BorderSide(color: _kPrimaryTint)),
            ),
            child: Row(
              children: [
                Text(
                  '다음 버스',
                  style: AppTextStyles.caption04.copyWith(
                    color: _kPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _kPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '실시간',
                  style: AppTextStyles.caption04.copyWith(color: _kPrimary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 아이콘 이미지가 자체 배경 타일을 포함하므로 별도 타일 없이 쓴다.
                Image.asset(
                  'assets/icons/bus/bus.png',
                  width: 52,
                  height: 52,
                  filterQuality: FilterQuality.medium,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.title02.copyWith(
                          color: active ? _kPrimary : _kTextStrong,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (sub != null && sub.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          sub,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption04.copyWith(
                            color: _kTextMuted,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
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

// ───────────────────────────────────────────────────────────────────────────
// 전체 시간표
// ───────────────────────────────────────────────────────────────────────────

class _TimetableSectionHeader extends StatelessWidget {
  final String routeLabel;

  const _TimetableSectionHeader({required this.routeLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          Text(
            '전체 시간표',
            style: AppTextStyles.caption01.copyWith(color: _kTextPrimary),
          ),
          const Spacer(),
          Text(
            routeLabel,
            style: AppTextStyles.caption03.copyWith(color: _kTextMuted),
          ),
        ],
      ),
    );
  }
}

class _TimetableCard extends StatelessWidget {
  final ShuttleTimetable? timetable;

  /// 자정 기준 현재 경과 분 — 지나간 출발 시각 칩을 흐리게 표시한다.
  final int nowMinutes;

  const _TimetableCard({required this.timetable, required this.nowMinutes});

  @override
  Widget build(BuildContext context) {
    final entries = timetable?.entries ?? const <ShuttleEntry>[];
    final fixed = entries.where((e) => !e.isSegment).toList(growable: false);
    final segments = entries.where((e) => e.isSegment).toList(growable: false);

    if (fixed.isEmpty && segments.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: _kBgBase,
          borderRadius: BorderRadius.circular(_kCardRadius),
          border: Border.all(color: _kBorder),
        ),
        child: Text(
          '오늘은 셔틀을 운행하지 않아요',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption03.copyWith(color: _kTextMuted),
        ),
      );
    }

    // 정시 출발을 시(hour) 단위로 묶는다. entries는 오름차순 전제.
    final byHour = <int, List<ShuttleTime>>{};
    for (final entry in fixed) {
      byHour.putIfAbsent(entry.time.hour, () => []).add(entry.time);
    }

    final rows = <Widget>[];
    for (final hour in byHour.keys) {
      rows.add(
        _HourRow(
          hour: hour,
          times: byHour[hour]!,
          nowMinutes: nowMinutes,
          showTopBorder: rows.isNotEmpty,
        ),
      );
    }
    for (final segment in segments) {
      rows.add(
        _SegmentRow(segment: segment, showTopBorder: rows.isNotEmpty),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _kBgBase,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: _kBorder),
      ),
      child: Column(children: rows),
    );
  }
}

class _HourRow extends StatelessWidget {
  final int hour;
  final List<ShuttleTime> times;
  final int nowMinutes;
  final bool showTopBorder;

  const _HourRow({
    required this.hour,
    required this.times,
    required this.nowMinutes,
    required this.showTopBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: showTopBorder
            ? const Border(top: BorderSide(color: _kBorder))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 34,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  hour.toString().padLeft(2, '0'),
                  style: AppTextStyles.caption02.copyWith(
                    color: _kTextPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  '시',
                  style: AppTextStyles.caption04.copyWith(color: _kTextMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final time in times)
                  _MinuteChip(
                    time: time,
                    isPast: time.minutesOfDay < nowMinutes,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 출발 분(minute) 칩.
///
/// 시안에는 칩 색이 파랑·초록·보라로 섞여 있지만, 구현에서는 색 차이 없이
/// 단일 색상(primary 계열)으로 통일한다. 지나간 시각은 흐리게 처리.
class _MinuteChip extends StatelessWidget {
  final ShuttleTime time;
  final bool isPast;

  const _MinuteChip({required this.time, required this.isPast});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isPast ? 0.35 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _kPrimaryTint,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: _kPrimary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              time.minute.toString().padLeft(2, '0'),
              style: AppTextStyles.caption02.copyWith(color: _kPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// 구간 항목(수시운행·도착버스 탑승) 안내 행 — 칩 대신 문장으로 표시.
class _SegmentRow extends StatelessWidget {
  final ShuttleEntry segment;
  final bool showTopBorder;

  const _SegmentRow({required this.segment, required this.showTopBorder});

  @override
  Widget build(BuildContext context) {
    final end = segment.endTime;
    final label = segment.type == ShuttleEntryType.arrivalBoarding
        ? '도착버스 탑승'
        : '수시 운행';
    final range =
        end == null ? segment.time.label : '${segment.time.label} ~ ${end.label}';
    final note = segment.boardingNote;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: showTopBorder
            ? const Border(top: BorderSide(color: _kBorder))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$range · $label',
            style: AppTextStyles.caption02.copyWith(
              color: _kTextStrong,
              letterSpacing: -0.3,
            ),
          ),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              note,
              style: AppTextStyles.caption04.copyWith(
                color: _kTextMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Footer note
// ───────────────────────────────────────────────────────────────────────────

class _FooterNote extends StatelessWidget {
  final DateTime lastUpdated;

  const _FooterNote({required this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    final hh = lastUpdated.hour.toString().padLeft(2, '0');
    final mm = lastUpdated.minute.toString().padLeft(2, '0');
    final style = AppTextStyles.caption04.copyWith(
      color: _kTextMuted,
      fontWeight: FontWeight.w400,
      height: 1.6,
    );
    return Column(
      children: [
        Text('시간표는 학교 사정에 따라 변경될 수 있어요.', style: style),
        Text('마지막 업데이트 · 오늘 $hh:$mm', style: style),
      ],
    );
  }
}
