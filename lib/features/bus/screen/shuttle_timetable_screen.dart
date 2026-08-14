import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/core/constants/app_text_styles.dart';

import 'package:handori/features/bus/component/shuttle_direction_toggle.dart';
import 'package:handori/features/bus/data/data_source/shuttle_schedule_data.dart';
import 'package:handori/features/bus/domain/model/shuttle_schedule.dart';

// ─── Color tokens ──────────────────────────────────────────────────────────
const Color _kPrimary = AppColors.primary;
const Color _kBgBase = AppColors.surface;
const Color _kBgSoft = AppColors.background;
const Color _kBorderSoft = AppColors.divider;
const Color _kTextPrimary = AppColors.textPrimary;
const Color _kTextMuted = AppColors.textMuted;

const double _kCardRadius = 16.0;
const double _kHourColWidth = 60.0;

/// 셔틀버스 전체 시간표 화면.
///
/// 정왕역 방면(하교)·학교 방면(등교)을 토글로 전환하며, 시간대(시)별로
/// 묶어 분 단위 출발 시각을 한눈에 보여준다. 도착버스 탑승 구간 등 정시
/// 출발이 아닌 구간은 안내 카드로 별도 표시한다.
class ShuttleTimetableScreen extends StatefulWidget {
  /// 진입 시 선택할 방면. 0: 정왕역 방면(하교), 1: 학교 방면(등교).
  final int initialDestination;

  const ShuttleTimetableScreen({super.key, this.initialDestination = 0});

  @override
  State<ShuttleTimetableScreen> createState() => _ShuttleTimetableScreenState();
}

class _ShuttleTimetableScreenState extends State<ShuttleTimetableScreen> {
  late int _selectedDestination = widget.initialDestination;

  void _onDestinationChanged(int index) {
    if (_selectedDestination == index) return;
    setState(() => _selectedDestination = index);
  }

  @override
  Widget build(BuildContext context) {
    final isToStation = _selectedDestination == 0;
    final direction = isToStation
        ? ShuttleDirection.schoolToJeongwang
        : ShuttleDirection.jeongwangToSchool;

    // 노선1은 평일 전용 → 전체 시간표는 평일 기준으로 보여준다.
    final timetable = ShuttleScheduleData.timetableFor(
      route: ShuttleRoute.route1,
      direction: direction,
      dayType: ShuttleDayType.weekday,
    );

    final originLabel = isToStation ? '한국공학대' : '정왕역';
    final destinationLabel = isToStation ? '정왕역' : '한국공학대';
    final rows = _buildRows(timetable?.entries ?? const []);

    return Scaffold(
      backgroundColor: _kBgSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              title: '셔틀버스 전체 시간표',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: ShuttleDirectionToggle(
                selected: _selectedDestination,
                onChanged: _onDestinationChanged,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                children: [
                  _RouteCaption(
                    origin: originLabel,
                    destination: destinationLabel,
                    summary: _operatingSummary(rows),
                  ),
                  const SizedBox(height: 18),
                  if (rows.isEmpty)
                    const _EmptyNotice()
                  else
                    _TimetableCard(rows: rows),
                  const SizedBox(height: 14),
                  const _PlatformNotice(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 첫차~막차(정시 운행 구간) 요약 문구.
  String _operatingSummary(List<_TimetableRow> rows) {
    final hourRows = rows.whereType<_HourRow>().toList();
    if (hourRows.isEmpty) return '운행 정보 없음';
    final first = hourRows.first;
    final last = hourRows.last;
    final firstLabel = _hhmm(first.hour, first.minutes.first);
    final lastLabel = _hhmm(last.hour, last.minutes.last);
    return '정시 운행 $firstLabel ~ $lastLabel';
  }

  static String _hhmm(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

// ─── Row grouping ────────────────────────────────────────────────────────────

/// 시간표 표시용 행. 시(hour)별 정시 출발 묶음 또는 구간 안내.
sealed class _TimetableRow {
  const _TimetableRow();
}

/// 한 시간대(예: 09시)의 분 단위 출발 시각 묶음.
class _HourRow extends _TimetableRow {
  final int hour;
  final List<int> minutes;
  _HourRow(this.hour, this.minutes);
}

/// 수시운행 · 도착버스 탑승 등 정시 출발이 아닌 구간 안내.
class _SegmentRow extends _TimetableRow {
  final ShuttleEntry entry;
  const _SegmentRow(this.entry);
}

/// 정렬된 [entries]를 시(hour)별 묶음 + 구간 안내 행으로 변환.
List<_TimetableRow> _buildRows(List<ShuttleEntry> entries) {
  final rows = <_TimetableRow>[];
  _HourRow? current;
  for (final e in entries) {
    if (e.type == ShuttleEntryType.fixed) {
      if (current != null && current.hour == e.time.hour) {
        current.minutes.add(e.time.minute);
      } else {
        current = _HourRow(e.time.hour, [e.time.minute]);
        rows.add(current);
      }
    } else {
      current = null;
      rows.add(_SegmentRow(e));
    }
  }
  return rows;
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onBack,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: _kTextPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title03.copyWith(
                color: _kTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

// ─── Route caption (출발 → 도착 + 운행 요약) ──────────────────────────────────

class _RouteCaption extends StatelessWidget {
  final String origin;
  final String destination;
  final String summary;

  const _RouteCaption({
    required this.origin,
    required this.destination,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            origin,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption01.copyWith(
              color: _kTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.arrow_forward_rounded, size: 15, color: _kPrimary),
        ),
        Flexible(
          child: Text(
            destination,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption01.copyWith(
              color: _kTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const Spacer(),
        Text(
          summary,
          style: AppTextStyles.caption04.copyWith(
            color: _kTextMuted,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

// ─── Timetable card ──────────────────────────────────────────────────────────

class _TimetableCard extends StatelessWidget {
  final List<_TimetableRow> rows;

  const _TimetableCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[const _TableHeaderRow()];
    for (final row in rows) {
      children.add(const Divider(height: 1, thickness: 1, color: _kBorderSoft));
      children.add(switch (row) {
        _HourRow() => _HourRowTile(row: row),
        _SegmentRow() => _SegmentRowTile(entry: row.entry),
      });
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _kBgBase,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: _kBorderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

/// 표 머리글 — 시 | 분.
class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.caption04.copyWith(
      color: _kTextMuted,
      letterSpacing: 0.4,
    );
    return Container(
      color: _kBgSoft,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: _kHourColWidth,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: _kBorderSoft)),
              ),
              child: Text('시', style: style),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text('분', style: style),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourRowTile extends StatelessWidget {
  final _HourRow row;

  const _HourRowTile({required this.row});

  @override
  Widget build(BuildContext context) {
    // 분 단위 출발 시각을 점(·)으로 구분해 한 줄로.
    final minutesText = row.minutes
        .map((m) => m.toString().padLeft(2, '0'))
        .join('  ·  ');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 시(hour) 열.
          Container(
            width: _kHourColWidth,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: _kBorderSoft)),
            ),
            child: Text(
              row.hour.toString().padLeft(2, '0'),
              style: AppTextStyles.caption01.copyWith(
                color: _kPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          // 분 열.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                minutesText,
                style: AppTextStyles.caption01.copyWith(
                  color: _kTextPrimary,
                  letterSpacing: 0.2,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentRowTile extends StatelessWidget {
  final ShuttleEntry entry;

  const _SegmentRowTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isArrival = entry.type == ShuttleEntryType.arrivalBoarding;
    final title = isArrival ? '도착버스 탑승' : '수시운행';
    final start = entry.time.label;
    final timeRange = '$start 이후';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: _kPrimary.withValues(alpha: 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isArrival
                ? Icons.directions_bus_filled_rounded
                : Icons.schedule_rounded,
            size: 18,
            color: _kPrimary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      timeRange,
                      style: AppTextStyles.caption02.copyWith(
                        color: _kTextPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _kPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        title,
                        style: AppTextStyles.caption04.copyWith(
                          color: _kPrimary,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ],
                ),
                if (entry.boardingNote != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.boardingNote!,
                    style: AppTextStyles.caption04.copyWith(
                      color: _kTextMuted,
                      height: 1.4,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notices ─────────────────────────────────────────────────────────────────

class _PlatformNotice extends StatelessWidget {
  const _PlatformNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kBgBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: _kTextMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '평일 기준 시간표예요. 토·일·공휴일은 운행하지 않습니다.\n'
              '도로 사정에 따라 출발 시각이 달라질 수 있어요.',
              style: AppTextStyles.caption04.copyWith(
                color: _kTextMuted,
                height: 1.5,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotice extends StatelessWidget {
  const _EmptyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: _kBgBase,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: _kBorderSoft),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_busy_rounded, size: 28, color: _kTextMuted),
          const SizedBox(height: 12),
          Text(
            '시간표 정보가 없어요',
            style: AppTextStyles.caption02.copyWith(
              color: _kTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
