import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:handori/features/empty_class/model/class_model.dart';
import 'package:handori/features/empty_class/repository/empty_class_repository.dart';

import 'package:handori/common/layout/root_tab.dart';

class EmptyDetailScreen extends StatefulWidget {
  const EmptyDetailScreen({super.key});

  @override
  State<EmptyDetailScreen> createState() => _EmptyDetailScreenState();
}

class _EmptyDetailScreenState extends State<EmptyDetailScreen> {
  static const _primary = Color(0xFF5C6BC0);
  static const _minPanelH = 120.0;

  late final Future<List<EmptyClass>> dataFuture;
  List<EmptyClass>? _allData;
  Set<Marker> _markers = {};
  String? _selectedId;
  final Map<String, ({BitmapDescriptor icon, Offset anchor})> _iconCache = {};
  int _markerGen = 0;

  final PanelController _panelController = PanelController();
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _listScroll = ScrollController();
  String _query = '';
  double _panelPos = 0.0;

  late GoogleMapController _mapController;
  CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(37.34019, 126.7336),
    zoom: 17.0,
  );

  @override
  void initState() {
    super.initState();
    dataFuture = GetIt.I<EmptyClassRepository>().fetchEmptyClassesStatically();
    dataFuture.then((data) {
      if (mounted) setState(() => _allData = data);
      _refreshMarkers(data);
    }).catchError((_) {});

    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim());
      if (_allData != null) _refreshMarkers(_allData!);
    });

    _initCameraToMyLocation();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _listScroll.dispose();
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
      final cam =
          CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 17.0);
      _initialCamera = cam;
      if (mounted) {
        try {
          _mapController.animateCamera(CameraUpdate.newCameraPosition(cam));
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> _refreshMarkers(List<EmptyClass> allData) async {
    _markerGen++;
    final gen = _markerGen;
    final filtered = _applySearch(allData);
    final markers = <Marker>{};

    for (final e in filtered) {
      if (gen != _markerGen) return;
      final name = e.className.replaceAll(':', '').trim();
      final key = '$name:${e.classCount}';
      final iconData =
          _iconCache[key] ?? await _buildCustomMarkerIcon(name, e.classCount);
      _iconCache[key] = iconData;

      markers.add(Marker(
        markerId: MarkerId(e.className),
        position: LatLng(e.latitude, e.longitude),
        icon: iconData.icon,
        anchor: iconData.anchor,
        onTap: () => _onMarkerTap(e, filtered),
      ));
    }

    if (gen != _markerGen || !mounted) return;
    setState(() => _markers = markers);
  }

  void _onMarkerTap(EmptyClass e, List<EmptyClass> filtered) {
    setState(() => _selectedId = e.className);
    if (_panelController.isAttached) {
      _panelController.open();
      final idx = filtered.indexOf(e);
      if (idx >= 0) {
        Future.delayed(const Duration(milliseconds: 450), () {
          if (_listScroll.hasClients) {
            _listScroll.animateTo(
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
    final shell = RootTab.of(context);
    if (shell != null) {
      shell.jumpTo(2);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// 건물명 + 빈 강의실 개수를 항상 표시하는 커스텀 마커 비트맵 생성
  static Future<({BitmapDescriptor icon, Offset anchor})> _buildCustomMarkerIcon(
    String name,
    String count,
  ) async {
    const double scale = 3.0;
    const double paddingH = 10.0;
    const double paddingV = 7.0;
    const double radius = 10.0;
    const double gap = 6.0;
    const double tipH = 9.0;
    const double tipHalfW = 7.0;
    const double shadowBlur = 2.5;
    const double shadowOff = 1.5;
    const double badgePadH = 6.0;
    const double badgePadV = 3.0;
    const Color primary = Color(0xFF5C6BC0);

    final nameTp = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          letterSpacing: -0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final countTp = TextPainter(
      text: TextSpan(
        text: '$count개',
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final double badgeW = countTp.width + badgePadH * 2;
    final double badgeH = countTp.height + badgePadV * 2;
    final double pillW = paddingH + nameTp.width + gap + badgeW + paddingH;
    final double pillH =
        math.max(nameTp.height + paddingV * 2, badgeH + paddingV * 2);

    const double ox = shadowBlur;
    const double oy = shadowBlur;
    final double canvasW = pillW + shadowBlur * 2 + shadowOff;
    final double canvasH = pillH + tipH + shadowBlur * 2 + shadowOff;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, canvasW * scale, canvasH * scale),
    );
    canvas.scale(scale);

    // Drop shadow (pill)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(ox + shadowOff, oy + shadowOff, pillW, pillH),
        const Radius.circular(radius),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, shadowBlur),
    );

    // Drop shadow (tip)
    canvas.drawPath(
      Path()
        ..moveTo(
            ox + shadowOff + pillW / 2 - tipHalfW, oy + shadowOff + pillH)
        ..lineTo(
            ox + shadowOff + pillW / 2 + tipHalfW, oy + shadowOff + pillH)
        ..lineTo(ox + shadowOff + pillW / 2, oy + shadowOff + pillH + tipH)
        ..close(),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, shadowBlur),
    );

    // White pill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(ox, oy, pillW, pillH),
        const Radius.circular(radius),
      ),
      Paint()..color = Colors.white,
    );

    // Left accent bar
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        ox, oy, ox + 3.5, oy + pillH,
        topLeft: const Radius.circular(radius),
        bottomLeft: const Radius.circular(radius),
      ),
      Paint()..color = primary,
    );

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(ox, oy, pillW, pillH),
        const Radius.circular(radius),
      ),
      Paint()
        ..color = const Color(0xFFD5D9F5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    // Arrow tip
    final tipX = ox + pillW / 2;
    final tipPath = Path()
      ..moveTo(tipX - tipHalfW, oy + pillH)
      ..lineTo(tipX + tipHalfW, oy + pillH)
      ..lineTo(tipX, oy + pillH + tipH)
      ..close();
    canvas.drawPath(tipPath, Paint()..color = Colors.white);
    canvas.drawPath(
      tipPath,
      Paint()
        ..color = const Color(0xFFD5D9F5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    // Count badge
    final double badgeX = ox + paddingH + nameTp.width + gap;
    final double badgeY = oy + (pillH - badgeH) / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(badgeX, badgeY, badgeW, badgeH),
        const Radius.circular(999),
      ),
      Paint()..color = primary,
    );

    // Name text
    nameTp.paint(canvas, Offset(ox + paddingH + 2, oy + (pillH - nameTp.height) / 2));

    // Count text
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
    final icon = BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      imagePixelRatio: scale,
    );

    // 화살표 끝(지리 위치)에 앵커 설정
    final double anchorX = (ox + pillW / 2) / canvasW;
    final double anchorY = (oy + pillH + tipH) / canvasH;
    return (icon: icon, anchor: Offset(anchorX, anchorY));
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
                panel: _buildPanel(items, allItems),
                body: Stack(
                  children: [
                    Positioned.fill(
                      child: GoogleMap(
                        initialCameraPosition: _initialCamera,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        onMapCreated: (c) => _mapController = c,
                        markers: _markers,
                        mapType: MapType.normal,
                        padding: EdgeInsets.only(
                          bottom: _minPanelH,
                          top: MediaQuery.of(context).padding.top,
                        ),
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
                      style: const TextStyle(
                          fontSize: 14, color: Colors.black87),
                      decoration: const InputDecoration(
                        hintText: '건물명 또는 강의실 코드 (예: E동, E234)',
                        hintStyle: TextStyle(
                            color: Colors.black38, fontSize: 13.5),
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

  Widget _buildPanel(List<EmptyClass> items, List<EmptyClass> allItems) {
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
                  const Text(
                    '빈 강의실 현황',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  _StatChip(label: '$totalBuildings동', color: _primary),
                  const SizedBox(width: 6),
                  _StatChip(
                      label: '총 $totalRooms개',
                      color: const Color(0xFF26C6DA)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F8)),
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
                      const Text(
                        '조건에 맞는 빈 강의실이 없습니다.',
                        style:
                            TextStyle(color: Colors.black38, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  controller: _listScroll,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, idx) => _EmptyClassCard(
                    item: items[idx],
                    isSelected: items[idx].className == _selectedId,
                    onTap: () {
                      setState(() => _selectedId = items[idx].className);
                      try {
                        _mapController.animateCamera(
                          CameraUpdate.newLatLng(
                            LatLng(items[idx].latitude,
                                items[idx].longitude),
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
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: color),
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
    const primary = Color(0xFF5C6BC0);

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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? primary
                                    : Colors.black87,
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
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w700,
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
                      size: 12, color: Color(0xFF26C6DA)),
                  const SizedBox(width: 4),
                  Text(
                    floor,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF26C6DA),
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
              size: 12, color: Color(0xFF26C6DA)),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
