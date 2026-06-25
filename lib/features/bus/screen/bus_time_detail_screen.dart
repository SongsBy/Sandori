import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:handori/common/component/coming_soon_snackbar.dart';
import 'package:handori/common/layout/root_tab.dart';
import 'package:handori/core/router/route_paths.dart';
import 'package:handori/features/bus/component/next_shuttle_card.dart';
import 'package:handori/features/bus/component/shuttle_direction_toggle.dart';
import 'package:handori/features/bus/domain/model/shuttle_schedule.dart';
import 'package:handori/features/bus/presentation/provider/next_shuttle_provider.dart';

// ─── Color tokens ──────────────────────────────────────────────────────────
const Color _kPrimary = Color(0xFF00C4F9); // 핀포인트 전용
const Color _kBgBase = Colors.white;
const Color _kBgSoft = Color(0xFFFAFAFA);
const Color _kBorderSoft = Color(0xFFF0F0F8);
const Color _kTextPrimary = Color(0xFF1A1A1A);
const Color _kTextMuted = Color(0xFF8A8F98);

// ─── Layout tokens ─────────────────────────────────────────────────────────
const double _kCardRadius = 12.0;

// ─── Text styles ───────────────────────────────────────────────────────────
const TextStyle _kSectionTitle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w700,
  color: _kTextMuted,
  letterSpacing: 0.4,
);

class BusTimeDetailScreen extends ConsumerStatefulWidget {
  const BusTimeDetailScreen({super.key});

  @override
  ConsumerState<BusTimeDetailScreen> createState() =>
      _BusTimeDetailScreenState();
}

class _BusTimeDetailScreenState extends ConsumerState<BusTimeDetailScreen> {
  int _selectedDestination = 0; // 0: 정왕역 방면, 1: 학교 방면

  void _onDestinationChanged(int index) {
    if (_selectedDestination == index) return;
    setState(() => _selectedDestination = index);
  }

  void _handleBack() {
    final shell = RootTab.of(context);
    if (shell != null) {
      shell.jumpTo(2);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _onBellPressed() => showComingSoonSnackBar(context);

  void _onUserPressed() => showComingSoonSnackBar(context);

  // 현재 선택된 방면을 그대로 넘겨 전체 시간표 화면으로 이동.
  void _openFullTimetable() {
    context.push(RoutePaths.shuttleTimetable, extra: _selectedDestination);
  }

  // 당겨서 새로고침 — 셔틀 정보를 다시 불러온다.
  Future<void> _onRefresh() async {
    ref.invalidate(nextShuttleProvider);
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final isToStation = _selectedDestination == 0;

    // 방면별 라벨 / 데이터.
    final shuttleRoute = isToStation ? '정왕역(셔틀)행' : '학교(셔틀)행';
    final originLabel = isToStation ? '한국공학대 정문' : '정왕역';
    final destinationLabel = isToStation ? '정왕역' : '한국공학대';

    // 화면 토글 → 노선1(정왕역↔본교) 방향 매핑.
    final direction = isToStation
        ? ShuttleDirection.schoolToJeongwang
        : ShuttleDirection.jeongwangToSchool;
    final nextShuttle = ref.watch(
      nextShuttleProvider(
        route: ShuttleRoute.route1,
        direction: direction,
      ),
    );

    return Scaffold(
      backgroundColor: _kBgSoft,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              title: '버스조회',
              onBack: _handleBack,
              onBell: _onBellPressed,
              onUser: _onUserPressed,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: ShuttleDirectionToggle(
                selected: _selectedDestination,
                onChanged: _onDestinationChanged,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: _kPrimary,
                backgroundColor: _kBgBase,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  children: [
                    // 방향 요약 — 지도를 대신해 출발/도착 맥락을 전달.
                    _RouteSummary(
                      origin: originLabel,
                      destination: destinationLabel,
                    ),
                    const SizedBox(height: 28),
                    // 셔틀 — 다음 출발을 가장 크게 강조하는 히어로 카드.
                    const _SectionHeader(title: '학교 셔틀버스'),
                    const SizedBox(height: 14),
                    NextShuttleCard(
                      route: shuttleRoute,
                      next: nextShuttle,
                    ),
                    const SizedBox(height: 12),
                    _FullTimetableButton(onTap: _openFullTimetable),
                    const SizedBox(height: 36),
                    // 실시간 시내버스 도착 — 준비 중.
                    const _SectionHeader(title: '실시간 버스 도착'),
                    const SizedBox(height: 14),
                    const _ComingSoonCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Header
// ───────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onBell;
  final VoidCallback onUser;

  const _Header({
    required this.title,
    required this.onBack,
    required this.onBell,
    required this.onUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Row(
        children: [
          _IconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            iconSize: 18,
            onTap: onBack,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _kTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          _IconButton(
            icon: Icons.notifications_none_rounded,
            iconSize: 22,
            onTap: onBell,
          ),
          _IconButton(
            icon: Icons.account_circle_outlined,
            iconSize: 24,
            onTap: onUser,
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: iconSize, color: _kTextPrimary),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Route summary (출발 → 도착)
// ───────────────────────────────────────────────────────────────────────────

class _RouteSummary extends StatelessWidget {
  final String origin;
  final String destination;

  const _RouteSummary({required this.origin, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _kBgBase,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: _kBorderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _endpoint(origin, isOrigin: true),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: _kPrimary.withValues(alpha: 0.7),
            ),
          ),
          _endpoint(destination, isOrigin: false),
        ],
      ),
    );
  }

  Widget _endpoint(String label, {required bool isOrigin}) {
    return Expanded(
      child: Column(
        crossAxisAlignment:
            isOrigin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            isOrigin ? '출발' : '도착',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _kTextMuted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: isOrigin ? TextAlign.start : TextAlign.end,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: _kTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Full timetable button — 전체 시간표 보기 진입.
// ───────────────────────────────────────────────────────────────────────────

class _FullTimetableButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FullTimetableButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kBgBase,
      borderRadius: BorderRadius.circular(_kCardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(_kCardRadius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_kCardRadius),
            border: Border.all(color: _kBorderSoft),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: _kPrimary.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '전체 시간표 보기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: _kTextMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Section header
// ───────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(title.toUpperCase(), style: _kSectionTitle),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Coming soon — 실시간 시내버스 도착 정보(공공 API) 준비 중 안내.
// ───────────────────────────────────────────────────────────────────────────

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: _kBgBase,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _kBgSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorderSoft),
            ),
            child: const Icon(
              Icons.directions_bus_filled_outlined,
              size: 26,
              color: _kTextMuted,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '준비 중이에요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _kTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '실시간 시내버스 도착 정보는\n곧 만나보실 수 있어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _kTextMuted,
              height: 1.5,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
