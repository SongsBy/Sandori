import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:handori/model/class_model.dart';
import 'package:handori/repository/empty_class_repository.dart';

class EmptyDetailScreen extends StatefulWidget {
  const EmptyDetailScreen({super.key});

  @override
  State<EmptyDetailScreen> createState() => _EmptyDetailScreenState();
}

class _EmptyDetailScreenState extends State<EmptyDetailScreen> {

  late final Future<List<EmptyClass>> dataFuture;

  Set<Marker> _markers ={};

  final PanelController _panelController = PanelController();
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  double _panelPos = 0.0;


  late GoogleMapController _mapController;
  CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(37.34019, 126.7336),
    zoom: 17,
  );

  @override
  void initState() {
    super.initState();


    dataFuture = GetIt.I<EmptyClassRepository>().fetchEmptyClassesStatically();

    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim());
    });

    _initCameraToMyLocation();
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
      final cam = CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 18.5,
      );


      _initialCamera = cam;


      if (mounted) {
        try {
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(cam),
          );
        } catch (_) {
        }
      }
    } catch (_) {

    }
  }

  void _goToMyLocation() => _initCameraToMyLocation();


  Set<Marker> _buildMarkers(List<EmptyClass> items) {
    return items.map((e) {
      return Marker(
        markerId: MarkerId(e.className),
        position: LatLng(e.latitude, e.longitude),
        infoWindow: InfoWindow(
          title: e.className.replaceAll(':', '').trim(),
          snippet: '빈 강의실: ${e.classCount}개',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ),
        onTap: () async{

          if (_panelController.isAttached) {
            await Future.delayed(Duration(milliseconds: 820));
            _panelController.open();
          }
        },
      );
    }).toSet();
  }

  List<EmptyClass> _applySearch(List<EmptyClass> list) {
    if (_query.isEmpty) return list;
    final q = _query.toLowerCase();
    return list.where((e) {
      final nameHit = e.className.toLowerCase().contains(q);
      final roomHit = e.classList.any((r) => r.toLowerCase().contains(q));
      return nameHit || roomHit;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double fabBottomStart = 140.0;
    final double fabBottomEndExtra = 220.0;
    final double fabBottom = lerpDouble(
      fabBottomStart,
      fabBottomStart + fabBottomEndExtra,
      _panelPos.clamp(0.0, 0.5) / 0.5,
    )!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<EmptyClass>>(
        future: dataFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final item  = _applySearch(snapshot.data!);
          _markers = _buildMarkers(item);

          final items = _applySearch(snapshot.data!);
          final double panelMaxHeight = size.height * 0.8;

          return SlidingUpPanel(
            controller: _panelController,
            color: const Color(0XFFFAFAFA),
            maxHeight: panelMaxHeight,
            minHeight: 120.0,
            panelSnapping: true,
            snapPoint: 0.5,
            parallaxEnabled: true,
            parallaxOffset: .18,

            panel: _buildPanelContent(items),

            body: Stack(
              children: [
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: _initialCamera,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    onMapCreated: (c) => _mapController = c,
                    markers: _markers,
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Row(
                      children: [
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 2,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context),
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
                              child: Row(
                                children: [
                                   SizedBox(width: 12),
                                   Icon(Icons.search, color: Colors.black54),
                                   SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchCtrl,
                                      textInputAction: TextInputAction.search,
                                      decoration: const InputDecoration(
                                        hintText: '건물명 또는 강의실 코드로 검색 (예: E동, E234)',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  if (_query.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      color: Colors.black54,
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        FocusScope.of(context).unfocus();
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


                AnimatedPositioned(
                  duration:Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  bottom: fabBottom,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    onPressed: _goToMyLocation,
                    child: Icon(Icons.my_location),
                  ),
                ),
              ],
            ),

            onPanelSlide: (pos) {
              setState(() => _panelPos = pos);
            },
          );
        },
      ),
    );
  }

  Widget _buildPanelContent(List<EmptyClass> items) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                width: 80,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            '빈 강의실 현황',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),

          Expanded(
            child: items.isEmpty
                ? Center(child: Text('조건에 맞는 빈 강의실이 없습니다.'))
                : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (_, __) =>SizedBox(height: 8),
              itemBuilder: (context, index) {
                final e = items[index];
                return _EmptyClassCard(item: e);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyClassCard extends StatelessWidget {
  final EmptyClass item;
  const _EmptyClassCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7F5FF), Color(0xFFFDFDFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D7AC9).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            alignment: Alignment.center,
            child: Image.asset(
              item.classIcons,
              width: 40,
              height:40,
              fit: BoxFit.contain,
            ),
          ),
         SizedBox(width: 14),

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
                        style: theme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color:Color(0xFF5660C8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color:  Color(0xFFE5E7FB)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '총 ${item.classCount}개',
                        style:  TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF4E56B9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: item.classList
                      .map((room) =>
                      _Chip(text: room, icon: Icons.meeting_room_outlined))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Chip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7FB)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6D7AC9)),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF4E56B9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}