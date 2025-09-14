import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handori/component/Header_text.dart';
import 'package:handori/component/SelectableIconButton.dart';
import 'package:handori/repository/static_repository.dart';

import 'maain_shell.dart';

class BusTimeDetailScreen extends StatefulWidget {
  const BusTimeDetailScreen({super.key});

  @override
  State<BusTimeDetailScreen> createState() => _BusTimeDetailScreenState();
}

class _BusTimeDetailScreenState extends State<BusTimeDetailScreen> {
  final CameraPosition initailPosition = const CameraPosition(
    target: LatLng(37.339496586083, 126.73287520461),
    zoom: 17.6,
  );

  final padding = const SizedBox(height: 20);
  int? selectedButtonIndex;

  final ScrollController _scrollCtrl = ScrollController();
  final GlobalKey _mapSectionKey = GlobalKey();

  late GoogleMapController _mapController;


  final Set<Marker> _markers = <Marker>{
    Marker(
      markerId: const MarkerId('main_gate'),
      position: const LatLng(37.33896, 126.7335),
      infoWindow: const InfoWindow(title: '정문 버스 정류장'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ),
    Marker(
      markerId: const MarkerId('shuttle'),
      position: const LatLng(37.33991, 126.7323),
      infoWindow: const InfoWindow(
        title: '셔틀버스 탑승장',
        snippet: '바로 앞 첫 버스에 탑승',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ),
  };

  @override
  void initState() {
    super.initState();
    selectedButtonIndex = 0;
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> checkPermession() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) throw Exception('권한을 허가해주세요');

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm != LocationPermission.always &&
        perm != LocationPermission.whileInUse) {
      throw Exception('위치 권한을 허가해 주세요 ');
    }
  }

  void _handleBack() {
    final shell = MainShell.of(context);
    if (shell != null) {
      shell.jumpTo(0);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _onBellPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('알림 버튼')),
    );
  }

  void _onUserPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('유저 버튼')),
    );
  }

  Future<void> _focusTo(LatLng target, {double zoom = 18}) async {
    try {
      await _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom),
        ),
      );
    } catch (_) {}
  }

  Future<void> _scrollToMap() async {
    final ctx = _mapSectionKey.currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        alignment: 0.02,
      );
    }
  }

  Future<void> _scrollToMapAndFocus(LatLng target) async {
    await _scrollToMap();
    await Future.delayed(const Duration(milliseconds: 120));
    await _focusTo(target);
  }

  Future<void> _goToMyLocation() async {
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
      await _scrollToMapAndFocus(LatLng(pos.latitude, pos.longitude));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final busTextPadding = const SizedBox(width: 10);
    final bus = StaticDataRepository.bus;
    final mediumText = Theme.of(context).textTheme.displayMedium;

    return FutureBuilder(
      future: checkPermession(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text('위치 권한을 허용해 주세요')));
        }
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // 상단 앱바
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0xFFFAFAFA),
                foregroundColor: Colors.black,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                expandedHeight: 490,
                titleSpacing: 12,
                title: _ToolbarCard(
                  title: '버스조회',
                  onBack: _handleBack,
                  onBell: _onBellPressed,
                  onUser: _onUserPressed,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 76),
                          Row(
                            children: [
                              SelectableIconButton(
                                isSelected: selectedButtonIndex == 0,
                                onPressed: () => setState(() => selectedButtonIndex = 0),
                                imagePath: 'assets/img/bank.png',
                              ),
                              const SizedBox(width: 20),
                              SelectableIconButton(
                                isSelected: selectedButtonIndex == 1,
                                onPressed: () => setState(() => selectedButtonIndex = 1),
                                imagePath: 'assets/img/train.png',
                              ),
                            ],
                          ),
                          padding,
                          Row(
                            children: [
                              const SizedBox(width: 7),
                              Text('정왕역',
                                  style: mediumText?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(width: 50),
                              Text('학교',
                                  style: mediumText?.copyWith(fontWeight: FontWeight.w700)),
                            ],
                          ),
                          padding,
                          HeaderText(
                            title: '학교 셔틀버스',
                            onTextButtonPressed: () {},
                          ),
                          padding,
                          Row(
                            children: [
                              Text('정왕역(셔틀)행', style: mediumText),
                              busTextPadding,
                              Text('13분 후 출발',
                                  style: mediumText?.copyWith(color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 40),
                          const HeaderText(title: '정문 버스 정류장'),
                          padding,
                          Column(
                            children: bus
                                .map(
                                  (e) => Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    Image.asset(e.busIcon),
                                    Text(e.busNumber, style: mediumText),
                                    busTextPadding,
                                    Text(
                                      e.busTime,
                                      style: mediumText?.copyWith(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .toList(),
                          ),
                          padding,
                        ],
                      ),
                    ),
                  ),
                ),
              ),


              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _mapSectionKey,
                  child: Column(
                    children: [

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFDDE8EE)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF89DAF0).withOpacity(.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.directions_bus, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    '탑승 위치',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _scrollToMapAndFocus(
                                        const LatLng(37.33896, 126.7335),
                                      ),
                                      icon: const Icon(Icons.place, size: 18),
                                      label: const Text('정문 보기'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        foregroundColor: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _scrollToMapAndFocus(
                                        const LatLng(37.33991, 126.7323),
                                      ),
                                      icon: const Icon(Icons.directions, size: 18),
                                      label: const Text('셔틀 보기'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        foregroundColor: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: OutlinedButton.icon(
                                  onPressed: _goToMyLocation,
                                  icon: const Icon(Icons.my_location, size: 18),
                                  label: const Text('내 위치 보기'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    foregroundColor: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),


                      SizedBox(
                        height: MediaQuery.of(context).size.height * .9,
                        child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: initailPosition,
                          onMapCreated: (c) => _mapController = c,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          markers: _markers,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


/// 카드형 툴바 (공통 스타일)
class _ToolbarCard extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onBell;
  final VoidCallback onUser;

  const _ToolbarCard({
    required this.title,
    required this.onBack,
    required this.onBell,
    required this.onUser,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Row(
          children: [

            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onBack,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 8),


            Expanded(
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: '알림',
                        onPressed: onBell,
                        icon: const Icon(Icons.notifications_none, size: 20),
                        color: Colors.black54,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: '내 정보',
                        onPressed: onUser,
                        icon: const Icon(Icons.account_circle_outlined, size: 22),
                        color: Colors.black54,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}