import 'dart:ui' as ui;
import 'package:handori/core/constants/app_text_styles.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

import 'package:handori/features/empty_class/model/class_model.dart';
import 'package:handori/features/empty_class/presentation/provider/empty_class_provider.dart';

import 'package:go_router/go_router.dart';
import 'package:handori/common/layout/root_shell.dart';
import 'package:handori/shared/widget/sandol_loading_indicator.dart';

class EmptyDetailScreen extends ConsumerStatefulWidget {
  const EmptyDetailScreen({super.key});

  @override
  ConsumerState<EmptyDetailScreen> createState() => _EmptyDetailScreenState();
}

class _EmptyDetailScreenState extends ConsumerState<EmptyDetailScreen> {
  static const _primary = AppColors.primary;

  /// 시트 높이 3단. 접힘 높이만 픽셀 기준이라 화면 비율로 환산해 쓴다.
  static const _collapsedH = 120.0;
  static const _snapFrac = 0.4;
  static const _maxFrac = 0.8;

  /// 마커 탭으로 카드를 보여줄 때 올리는 높이 (드래그 스냅보다 한 단 높게)
  static const _revealFrac = 0.6;

  Set<NMarker> _markers = {};
  String? _selectedId;
  final Map<String, ({NOverlayImage icon, NPoint anchor, Size size})>
      _iconCache = {};
  int _markerGen = 0;

  final DraggableScrollableController _sheetCtrl =
      DraggableScrollableController();
  // 건물 카드로 정확히 스크롤(ensureVisible)하기 위한 카드 키 (건물명 → key)
  final Map<String, GlobalKey> _cardKeys = {};

  NaverMapController? _mapController;
  NCameraPosition _initialCamera = const NCameraPosition(
    target: NLatLng(37.34019, 126.7336),
    zoom: 17.0,
  );

  @override
  void dispose() {
    _sheetCtrl.dispose();
    super.dispose();
  }

  Future<void> _initCameraToMyLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm != LocationPermission.always &&
          perm != LocationPermission.whileInUse) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final cam = NCameraPosition(
          target: NLatLng(pos.latitude, pos.longitude), zoom: 17.0);
      _initialCamera = cam;
      if (mounted) {
        try {
          // 권한이 확보된 시점이므로 내 위치 오버레이(파란 점)도 켠다.
          _mapController?.setLocationTrackingMode(NLocationTrackingMode.noFollow);
          _mapController?.updateCamera(
            NCameraUpdate.scrollAndZoomTo(target: cam.target, zoom: cam.zoom)
              ..setAnimation(
                animation: NCameraAnimation.easing,
                duration: const Duration(milliseconds: 500),
              ),
          );
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> _refreshMarkers(List<EmptyClass> data) async {
    _markerGen++;
    final gen = _markerGen;
    final markers = <NMarker>{};

    for (final e in data) {
      if (gen != _markerGen) return;
      final name = e.className.replaceAll(':', '').trim();
      final selected = e.className == _selectedId;
      final key = '$name:${e.classCount}:${selected ? 1 : 0}';
      final iconData = _iconCache[key] ??
          await _buildCustomMarkerIcon(name, e.classCount,
              selected: selected);
      _iconCache[key] = iconData;

      final marker = NMarker(
        id: e.className,
        position: NLatLng(e.latitude, e.longitude),
        icon: iconData.icon,
        anchor: iconData.anchor,
        size: iconData.size,
      );
      // 선택된 마커가 다른 마커에 가려지지 않게 위로 올린다.
      marker.setGlobalZIndex(selected ? 400000 : 200000);
      marker.setOnTapListener((_) => _selectBuilding(e, reveal: true));
      markers.add(marker);
    }

    if (gen != _markerGen || !mounted) return;
    setState(() => _markers = markers);
    _applyMarkersToMap();
  }

  /// 네이버 지도는 마커를 위젯 속성이 아닌 컨트롤러로 관리하므로
  /// 마커 셋이 바뀔 때마다 지도에 다시 반영한다.
  Future<void> _applyMarkersToMap() async {
    final controller = _mapController;
    if (controller == null) return;
    try {
      await controller.clearOverlays(type: NOverlayType.marker);
      await controller.addOverlayAll(_markers);
    } catch (_) {}
  }

  /// 건물 선택 공통 처리. 마커 탭(reveal=true)이면 시트를 스냅 높이까지
  /// 올리고 해당 카드로 스크롤, 리스트 탭(reveal=false)이면 지도만 이동.
  void _selectBuilding(EmptyClass e, {required bool reveal}) {
    setState(() => _selectedId = e.className);
    final data = ref.read(emptyClassesProvider).valueOrNull;
    if (data != null) _refreshMarkers(data);
    try {
      _mapController?.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(e.latitude, e.longitude),
        )..setAnimation(
            animation: NCameraAnimation.easing,
            duration: const Duration(milliseconds: 300),
          ),
      );
    } catch (_) {}
    if (reveal) _revealCard(e.className);
  }

  /// 시트를 리빌 높이까지 올린 뒤 해당 건물 카드가 보이도록 스크롤한다.
  Future<void> _revealCard(String className) async {
    try {
      if (_sheetCtrl.isAttached && _sheetCtrl.size < _revealFrac - 0.01) {
        await _sheetCtrl.animateTo(
          _revealFrac,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
      final ctx = _cardKeys[className]?.currentContext;
      if (ctx != null && ctx.mounted) {
        await Scrollable.ensureVisible(
          ctx,
          alignment: 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (_) {}
  }

  double _minFrac(double screenH) =>
      (_collapsedH / screenH).clamp(0.08, 0.35).toDouble();

  // 헤더는 스크롤러블 밖에 있으므로 시트 컨트롤러를 직접 구동한다.
  // 리스트가 어디까지 스크롤돼 있든 헤더 드래그는 항상 시트를 움직인다.
  void _onHeaderDragUpdate(
      DragUpdateDetails d, double minFrac, double screenH) {
    if (!_sheetCtrl.isAttached) return;
    _sheetCtrl.jumpTo(
      (_sheetCtrl.size - d.delta.dy / screenH).clamp(minFrac, _maxFrac),
    );
  }

  void _onHeaderDragEnd(DragEndDetails d, double minFrac, double screenH) {
    if (!_sheetCtrl.isAttached) return;
    final v = -d.velocity.pixelsPerSecond.dy / screenH; // 위로 드래그가 양수
    final cur = _sheetCtrl.size;
    final stops = [minFrac, _snapFrac, _maxFrac];
    final double target;
    if (v.abs() > 0.9) {
      // 플링: 진행 방향의 다음 정지점으로
      target = v > 0
          ? stops.firstWhere((s) => s > cur + 0.01, orElse: () => _maxFrac)
          : stops.lastWhere((s) => s < cur - 0.01, orElse: () => minFrac);
    } else {
      // 가장 가까운 정지점으로
      target =
          stops.reduce((a, b) => (a - cur).abs() <= (b - cur).abs() ? a : b);
    }
    _sheetCtrl.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleBack() {
    StatefulNavigationShell.of(context).goBranch(RootShell.homeBranch);
  }

  /// 건물명 + 빈 강의실 개수(원형 숫자 배지)를 표시하는 커스텀 마커 비트맵.
  /// 앱 컬러 토큰만 사용한다: 잔여 있음 = primary, 없음 = muted 회색,
  /// 선택된 건물은 primary 반전 + 헤일로로 지도 위에서 바로 구분된다.
  static Future<({NOverlayImage icon, NPoint anchor, Size size})>
      _buildCustomMarkerIcon(
    String name,
    String count, {
    required bool selected,
  }) async {
    const double scale = 3.0;
    const double padH = 11.0;
    const double padV = 7.0;
    const double gap = 7.0;
    const double tipH = 8.0;
    const double tipHalfW = 6.0;
    const double shadowBlur = 6.0;
    const double badgePadH = 6.0;
    const double badgePadV = 3.0;
    const double haloW = 2.5;
    const Color primary = AppColors.primary;

    final int roomCount = int.tryParse(count) ?? 0;
    final bool hasRooms = roomCount > 0;

    // 잔여 있음 = primary, 없음 = muted.
    final Color accent = hasRooms ? primary : AppColors.textMuted;

    final Color nameColor = selected ? Colors.white : AppColors.textPrimary;
    final Color badgeBg = selected ? Colors.white : accent;
    final Color badgeFg = selected ? primary : Colors.white;

    final nameTp = TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: nameColor,
          letterSpacing: -0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // 숫자만 크게 — "개"는 리스트 패널이 이미 말해주므로 지도에선 수치가 핵심.
    final countTp = TextPainter(
      text: TextSpan(
        text: '$roomCount',
        style: TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w800,
          color: badgeFg,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // 한 자리 수는 정원, 두 자리 이상은 알약형으로 늘어나는 배지
    final double badgeH = countTp.height + badgePadV * 2;
    final double badgeW = math.max(countTp.width + badgePadH * 2, badgeH);
    final double contentH = math.max(nameTp.height, badgeH);
    final double pillH = contentH + padV * 2;
    final double radius = pillH / 2; // 캡슐형
    final double pillW = padH + nameTp.width + gap + badgeW + padH;

    // 헤일로 + 그림자 블러가 잘리지 않도록 여백 확보
    const double m = shadowBlur * 2 + haloW;
    const double ox = m;
    const double oy = m;
    final double canvasW = pillW + m * 2;
    final double canvasH = pillH + tipH + m * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, canvasW * scale, canvasH * scale),
    );
    canvas.scale(scale);

    // 말풍선(캡슐 + 꼬리)을 하나의 패스로 합쳐 외곽선이 매끄럽게 이어지게 한다.
    Path bubblePath(double inflate) {
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(ox - inflate, oy - inflate, pillW + inflate * 2,
            pillH + inflate * 2),
        Radius.circular(radius + inflate),
      );
      final tipX = ox + pillW / 2;
      final tip = Path()
        ..moveTo(tipX - tipHalfW - inflate, oy + pillH - radius / 2)
        ..lineTo(tipX + tipHalfW + inflate, oy + pillH - radius / 2)
        ..lineTo(tipX, oy + pillH + tipH + inflate)
        ..close();
      return Path.combine(
          PathOperation.union, Path()..addRRect(rrect), tip);
    }

    final bubble = bubblePath(0);

    // 선택 헤일로
    if (selected) {
      canvas.drawPath(
        bubblePath(haloW),
        Paint()..color = primary.withValues(alpha: 0.28),
      );
    }

    // 2겹 그림자: 넓게 퍼지는 ambient + 경계를 잡아주는 key
    canvas.drawPath(
      bubble.shift(const Offset(0, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: selected ? 0.20 : 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, shadowBlur),
    );
    canvas.drawPath(
      bubble.shift(const Offset(0, 1)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

    // 말풍선 본체 (미세한 세로 그라데이션으로 평면감 제거)
    final Paint pillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, oy),
        Offset(0, oy + pillH + tipH),
        selected
            ? [
                Color.lerp(primary, Colors.white, 0.14)!,
                Color.lerp(primary, Colors.black, 0.08)!,
              ]
            : [Colors.white, const Color(0xFFF5FAFD)],
      );
    canvas.drawPath(bubble, pillPaint);

    // 외곽선 (선택 시에는 배경색이 곧 브랜드 컬러라 생략)
    if (!selected) {
      canvas.drawPath(
        bubble,
        Paint()
          ..color = AppColors.cardBorder
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    // 건물명
    final double nameX = ox + padH;
    nameTp.paint(canvas, Offset(nameX, oy + (pillH - nameTp.height) / 2));

    // 개수 배지
    final double badgeX = nameX + nameTp.width + gap;
    final double badgeY = oy + (pillH - badgeH) / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(badgeX, badgeY, badgeW, badgeH),
        const Radius.circular(999),
      ),
      Paint()..color = badgeBg,
    );
    countTp.paint(
      canvas,
      Offset(
        badgeX + (badgeW - countTp.width) / 2,
        badgeY + (badgeH - countTp.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(
        (canvasW * scale).round(), (canvasH * scale).round());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final icon =
        await NOverlayImage.fromByteArray(byteData!.buffer.asUint8List());

    // 꼬리 끝(지리 위치)에 앵커 설정
    final double anchorX = (ox + pillW / 2) / canvasW;
    final double anchorY = (oy + pillH + tipH) / canvasH;
    return (
      icon: icon,
      anchor: NPoint(anchorX, anchorY),
      // 3배 스케일로 그린 비트맵이므로 마커 크기를 논리 크기로 고정한다.
      size: Size(canvasW, canvasH),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final minFrac = _minFrac(size.height);
    final classesAsync = ref.watch(emptyClassesProvider);

    // 데이터가 갱신되면 마커도 갱신 (최초 반영은 onMapReady에서)
    ref.listen(emptyClassesProvider, (_, next) {
      final data = next.valueOrNull;
      if (data != null) _refreshMarkers(data);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: classesAsync.when(
        error: (e, _) => Center(child: Text('오류: $e')),
        loading: () =>
            const Center(child: SandolLoadingIndicator()),
        data: (items) => Stack(
          children: [
            Positioned.fill(
              child: NaverMap(
                options: NaverMapViewOptions(
                  initialCameraPosition: _initialCamera,
                  mapType: NMapType.basic,
                  locationButtonEnable: false,
                  contentPadding: EdgeInsets.only(
                    bottom: _collapsedH,
                    top: MediaQuery.of(context).padding.top,
                  ),
                ),
                onMapReady: (c) {
                  _mapController = c;
                  _refreshMarkers(items);
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: _buildTopBar(),
              ),
            ),
            Positioned.fill(
              child: DraggableScrollableSheet(
                controller: _sheetCtrl,
                minChildSize: minFrac,
                initialChildSize: minFrac,
                maxChildSize: _maxFrac,
                snap: true,
                snapSizes: const [_snapFrac],
                builder: (context, sc) =>
                    _buildSheet(items, sc, minFrac, size.height),
              ),
            ),
            // 내 위치 FAB: 시트 컨트롤러에만 반응하므로 시트 드래그가
            // 화면 전체 리빌드로 번지지 않는다.
            AnimatedBuilder(
              animation: _sheetCtrl,
              builder: (context, child) {
                final frac =
                    _sheetCtrl.isAttached ? _sheetCtrl.size : minFrac;
                final hidden = frac > 0.6;
                return Positioned(
                  bottom: frac * size.height + 12,
                  right: 12,
                  child: IgnorePointer(
                    ignoring: hidden,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: hidden ? 0.0 : 1.0,
                      child: child!,
                    ),
                  ),
                );
              },
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 4,
                onPressed: _initCameraToMyLocation,
                child: const Icon(Icons.my_location_rounded, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _handleBack,
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildSheet(List<EmptyClass> items, ScrollController sc,
      double minFrac, double screenH) {
    final totalBuildings = items.length;
    final totalRooms =
        items.fold<int>(0, (s, e) => s + (int.tryParse(e.classCount) ?? 0));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 리스트 스크롤 위치와 무관하게 항상 시트를 끌 수 있다.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (d) =>
                  _onHeaderDragUpdate(d, minFrac, screenH),
              onVerticalDragEnd: (d) => _onHeaderDragEnd(d, minFrac, screenH),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '빈 강의실 현황',
                          style: AppTextStyles.title02.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        _StatChip(label: '$totalBuildings동', color: _primary),
                        const SizedBox(width: 6),
                        _StatChip(
                            label: '총 $totalRooms개',
                            color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.divider),
            const SizedBox(height: 4),
            // 리스트
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.meeting_room_outlined,
                              size: 52, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            '현재 빈 강의실이 없습니다.',
                            style: AppTextStyles.caption03.copyWith(
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: sc,
                      // 카드가 미리 빌드돼 있어야 ensureVisible 스크롤이
                      // 항상 정확히 동작한다 (건물 수십 개 수준이라 부담 없음).
                      cacheExtent: 4000,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, idx) {
                        final item = items[idx];
                        return KeyedSubtree(
                          key: _cardKeys.putIfAbsent(
                              item.className, GlobalKey.new),
                          child: _EmptyClassCard(
                            item: item,
                            isSelected: item.className == _selectedId,
                            onTap: () => _selectBuilding(item, reveal: false),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption04.copyWith(color: color),
      ),
    );
  }
}

class _EmptyClassCard extends StatelessWidget {
  final EmptyClass item;
  final bool isSelected;
  final VoidCallback? onTap;

  const _EmptyClassCard(
      {required this.item, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    const primary = AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        // 기본은 차분한 쿨그레이, 선택 시에만 브랜드 톤으로 밝게 반전
        color: isSelected ? AppColors.primaryLight : const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? primary.withValues(alpha: 0.45)
              : const Color(0xFFE7E9EE),
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primary.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isSelected ? 16 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 내용
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.className,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption01.copyWith(
                                color: isSelected ? primary : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected ? primary : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : const Color(0xFFE3E6EB),
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '총 ${item.classCount}개',
                              style: AppTextStyles.caption04.copyWith(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _FloorGroupedRooms(classList: item.classList),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 강의실 목록을 층별로 그룹화하여 세로 표시
class _FloorGroupedRooms extends StatelessWidget {
  final List<String> classList;
  const _FloorGroupedRooms({required this.classList});

  String _extractFloor(String room) {
    final match = RegExp(r'\d').firstMatch(room);
    return match != null ? '${match.group(0)}층' : '기타';
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<String>> floorMap = {};
    for (final room in classList) {
      floorMap.putIfAbsent(_extractFloor(room), () => []).add(room);
    }

    final sortedFloors = floorMap.keys.toList()
      ..sort((a, b) {
        if (a == '기타') return 1;
        if (b == '기타') return -1;
        return a.compareTo(b);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedFloors.map((floor) {
        final rooms = floorMap[floor]!;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.layers_rounded,
                      size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    floor,
                    style: AppTextStyles.caption04.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    rooms.map((room) => _RoomChip(text: room)).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RoomChip extends StatelessWidget {
  final String text;
  const _RoomChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE3E6EB)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption04.copyWith(color: Colors.black87),
      ),
    );
  }
}
