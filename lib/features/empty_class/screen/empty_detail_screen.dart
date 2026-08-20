import 'dart:ui' as ui;
import 'package:handori/core/constants/app_text_styles.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

import 'package:handori/features/empty_class/model/class_model.dart';
import 'package:handori/features/empty_class/presentation/provider/empty_class_provider.dart';

import 'package:go_router/go_router.dart';
import 'package:handori/common/layout/root_shell.dart';

class EmptyDetailScreen extends ConsumerStatefulWidget {
  const EmptyDetailScreen({super.key});

  @override
  ConsumerState<EmptyDetailScreen> createState() => _EmptyDetailScreenState();
}

class _EmptyDetailScreenState extends ConsumerState<EmptyDetailScreen> {
  static const _primary = AppColors.primary;
  static const _minPanelH = 120.0;

  late final Future<List<EmptyClass>> dataFuture;
  List<EmptyClass>? _allData;
  Set<NMarker> _markers = {};
  String? _selectedId;
  final Map<String, ({NOverlayImage icon, NPoint anchor, Size size})>
      _iconCache = {};
  int _markerGen = 0;

  final PanelController _panelController = PanelController();
  final TextEditingController _searchCtrl = TextEditingController();
  // SlidingUpPanel이 panelBuilder로 넘겨주는 컨트롤러. 리스트 최상단에서
  // 아래로 드래그하면 패널이 따라 내려가도록 스크롤/드래그를 연동한다.
  ScrollController? _panelScroll;
  String _query = '';
  double _panelPos = 0.0;

  NaverMapController? _mapController;
  NCameraPosition _initialCamera = const NCameraPosition(
    target: NLatLng(37.34019, 126.7336),
    zoom: 17.0,
  );

  @override
  void initState() {
    super.initState();
    dataFuture = ref.read(emptyClassesProvider.future);
    dataFuture.then((data) {
      if (mounted) setState(() => _allData = data);
      _refreshMarkers(data);
    }).catchError((_) {});

    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim());
      if (_allData != null) _refreshMarkers(_allData!);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
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

  Future<void> _refreshMarkers(List<EmptyClass> allData) async {
    _markerGen++;
    final gen = _markerGen;
    final filtered = _applySearch(allData);
    final markers = <NMarker>{};

    for (final e in filtered) {
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
      marker.setOnTapListener((_) => _onMarkerTap(e, filtered));
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

  void _onMarkerTap(EmptyClass e, List<EmptyClass> filtered) {
    setState(() => _selectedId = e.className);
    if (_allData != null) _refreshMarkers(_allData!);
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
    if (_panelController.isAttached) {
      _panelController.open();
      final idx = filtered.indexOf(e);
      if (idx >= 0) {
        Future.delayed(const Duration(milliseconds: 450), () {
          final sc = _panelScroll;
          if (sc != null && sc.hasClients) {
            sc.animateTo(
              idx * 180.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  List<EmptyClass> _applySearch(List<EmptyClass> list) {
    if (_query.isEmpty) return list;
    final q = _query.toLowerCase();
    return list
        .where((e) =>
            e.className.toLowerCase().contains(q) ||
            e.classList.any((r) => r.toLowerCase().contains(q)))
        .toList();
  }

  void _handleBack() {
    StatefulNavigationShell.of(context).goBranch(RootShell.homeBranch);
  }

  /// 건물명 + 빈 강의실 개수를 표시하는 커스텀 마커 비트맵.
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
    const double chipD = 22.0; // 아이콘 칩 한 변
    const double tipH = 8.0;
    const double tipHalfW = 6.0;
    const double shadowBlur = 6.0;
    const double badgePadH = 6.0;
    const double badgePadV = 3.0;
    const double haloW = 2.5;
    const Color primary = AppColors.primary;

    final int roomCount = int.tryParse(count) ?? 0;
    final bool hasRooms = roomCount > 0;

    // 잔여 있음 = primary, 없음 = muted. 그라데이션 단도 같은 색에서만 파생.
    final Color accent = hasRooms ? primary : AppColors.textMuted;
    final Color accentTop = Color.lerp(accent, Colors.white, 0.22)!;

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

    final iconTp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.meeting_room_rounded.codePoint),
        style: TextStyle(
          fontSize: 13.0,
          fontFamily: Icons.meeting_room_rounded.fontFamily,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // 한 자리 수는 정원, 두 자리 이상은 알약형으로 늘어나는 배지
    final double badgeH = countTp.height + badgePadV * 2;
    final double badgeW = math.max(countTp.width + badgePadH * 2, badgeH);
    final double contentH =
        math.max(chipD, math.max(nameTp.height, badgeH));
    final double pillH = contentH + padV * 2;
    final double radius = pillH / 2; // 캡슐형
    final double pillW =
        padH + chipD + gap + nameTp.width + gap + badgeW + padH;

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

    // 아이콘 칩: 브랜드 그라데이션 스쿼클 + 흰 아이콘 (앱 아이콘 문법)
    final Rect chipRect =
        Rect.fromLTWH(ox + padH, oy + (pillH - chipD) / 2, chipD, chipD);
    final RRect chipRRect = RRect.fromRectAndRadius(
        chipRect, Radius.circular(chipD * 0.34));
    final Paint chipPaint = Paint();
    if (selected) {
      chipPaint.color = Colors.white.withValues(alpha: 0.26);
    } else {
      chipPaint.shader = ui.Gradient.linear(
        chipRect.topCenter,
        chipRect.bottomCenter,
        [accentTop, accent],
      );
      // 칩이 필 위에 살짝 떠 보이도록 얇은 그림자
      canvas.drawRRect(
        chipRRect.shift(const Offset(0, 1)),
        Paint()
          ..color = accent.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }
    canvas.drawRRect(chipRRect, chipPaint);
    // 상단 광택 하이라이트
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(chipRect.left + 2, chipRect.top + 1.5,
            chipRect.width - 4, chipRect.height * 0.42),
        Radius.circular(chipD * 0.26),
      ),
      Paint()..color = Colors.white.withValues(alpha: selected ? 0.10 : 0.18),
    );
    iconTp.paint(
      canvas,
      Offset(chipRect.center.dx - iconTp.width / 2,
          chipRect.center.dy - iconTp.height / 2),
    );

    // 건물명
    final double nameX = ox + padH + chipD + gap;
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
    final maxPanelH = size.height * 0.8;
    final fabBottom =
        _minPanelH + (_panelPos * (maxPanelH - _minPanelH)) + 12;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: FutureBuilder<List<EmptyClass>>(
        future: dataFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: _primary));
          }

          final allItems = snapshot.data!;
          final items = _applySearch(allItems);

          return Stack(
            children: [
              SlidingUpPanel(
                controller: _panelController,
                color: Colors.white,
                maxHeight: maxPanelH,
                minHeight: _minPanelH,
                panelSnapping: true,
                snapPoint: 0.4,
                parallaxEnabled: false,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
                panelBuilder: (sc) {
                  _panelScroll = sc;
                  return _buildPanel(items, allItems, sc);
                },
                body: Stack(
                  children: [
                    Positioned.fill(
                      child: NaverMap(
                        options: NaverMapViewOptions(
                          initialCameraPosition: _initialCamera,
                          mapType: NMapType.basic,
                          locationButtonEnable: false,
                          contentPadding: EdgeInsets.only(
                            bottom: _minPanelH,
                            top: MediaQuery.of(context).padding.top,
                          ),
                        ),
                        onMapReady: (c) {
                          _mapController = c;
                          _applyMarkersToMap();
                        },
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: _buildTopBar(),
                      ),
                    ),
                  ],
                ),
                onPanelSlide: (pos) => setState(() => _panelPos = pos),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 50),
                curve: Curves.linear,
                bottom: fabBottom,
                right: 12,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _panelPos > 0.7 ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: _panelPos > 0.7,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 4,
                      onPressed: _initCameraToMyLocation,
                      child: const Icon(Icons.my_location_rounded, size: 24),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Material(
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
        const SizedBox(width: 8),
        Expanded(
          child: Material(
            elevation: 3,
            shadowColor: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded,
                      color: Colors.black38, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      textInputAction: TextInputAction.search,
                      style: AppTextStyles.caption03
                          .copyWith(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: '건물명 또는 강의실 코드 (예: E동, E234)',
                        hintStyle: AppTextStyles.caption03
                            .copyWith(color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        FocusScope.of(context).unfocus();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.close_rounded,
                            size: 18, color: Colors.black38),
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

  Widget _buildPanel(
      List<EmptyClass> items, List<EmptyClass> allItems, ScrollController sc) {
    final totalBuildings = allItems.length;
    final totalRooms =
        allItems.fold<int>(0, (s, e) => s + (int.tryParse(e.classCount) ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더 (패널 최소 높이에서도 항상 보임)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
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
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 1, color: AppColors.divider),
        const SizedBox(height: 4),
        // 리스트
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 52, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        '조건에 맞는 빈 강의실이 없습니다.',
                        style: AppTextStyles.caption03.copyWith(
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  controller: sc,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, idx) => _EmptyClassCard(
                    item: items[idx],
                    isSelected: items[idx].className == _selectedId,
                    onTap: () {
                      setState(() => _selectedId = items[idx].className);
                      if (_allData != null) _refreshMarkers(_allData!);
                      try {
                        _mapController?.updateCamera(
                          NCameraUpdate.scrollAndZoomTo(
                            target: NLatLng(items[idx].latitude,
                                items[idx].longitude),
                          )..setAnimation(
                              animation: NCameraAnimation.easing,
                              duration: const Duration(milliseconds: 300),
                            ),
                        );
                      } catch (_) {}
                    },
                  ),
                ),
        ),
      ],
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
        gradient: isSelected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEEF0FF), Color(0xFFF5F6FF)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF7F5FF), Color(0xFFFDFDFF)],
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? primary.withValues(alpha: 0.4)
              : const Color(0xFFE8E6F8),
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primary.withValues(alpha: 0.12)
                : const Color(0xFF6D7AC9).withValues(alpha: 0.06),
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
                                    : const Color(0xFFE5E7FB),
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
        border: Border.all(color: const Color(0xFFE5E7FB)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.meeting_room_outlined,
              size: 12, color: AppColors.primary),
          const SizedBox(width: 3),
          Text(
            text,
            style: AppTextStyles.caption04.copyWith(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
