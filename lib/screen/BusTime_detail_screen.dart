import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handori/component/Header_text.dart';
import 'package:handori/component/SelectableIconButton.dart';
import 'package:handori/component/Topdar.dart';
import 'package:handori/repository/static_repository.dart';

class BusTimeDetailScreen extends StatefulWidget {
  const BusTimeDetailScreen({super.key});

  @override
  State<BusTimeDetailScreen> createState() => _BusTimeDetailScreenState();
}

class _BusTimeDetailScreenState extends State<BusTimeDetailScreen> {
  final CameraPosition initailPosition = CameraPosition(
    target: LatLng(37.339496586083, 126.73287520461),
    zoom: 17.6,
  );
  final padding = SizedBox(height: 20);
  int? selectedButtonIndex;
  @override
  @override
  void initState() {
    super.initState();

    selectedButtonIndex = 0;
  }

  checkPermession() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      throw Exception('권한을 허가해주세요');
    }
    LocationPermission checkLocationPermission =
        await Geolocator.checkPermission();

    if (checkLocationPermission == LocationPermission.denied) {
      checkLocationPermission = await Geolocator.requestPermission();
    }

    if (checkLocationPermission != LocationPermission.always &&
        checkLocationPermission != LocationPermission.whileInUse) {
      throw Exception('위치 권한을 허가해 주세요 ');
    }
  }

  Widget build(BuildContext context) {
    final busTextPadding = SizedBox(width: 10);
    final bus = StaticDataRepository.bus;
    final mediumText = Theme.of(context).textTheme.displayMedium;
    return FutureBuilder(
      future: checkPermession(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('위치 권한을 허용해 주세요')));
        }
        return Scaffold(
          backgroundColor: Color(0xFFFAFAFA),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Color(0xFFFAFAFA),
                foregroundColor: Colors.black,
                surfaceTintColor: Colors.transparent,
                expandedHeight: 520,
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4,
                            ),
                            child: TopBar(
                              onBellPressed: () {},
                              onUserPressed: () {},
                              headerText: '버스조회',
                            ),
                          ),
                          padding,
                          Row(
                            children: [
                              SelectableIconButton(
                                isSelected: selectedButtonIndex == 0,
                                onPressed: () {
                                  setState(() {
                                    selectedButtonIndex = 0;
                                  });
                                },
                                imagePath: 'assets/img/bank.png',
                              ),
                              SizedBox(width: 20),
                              SelectableIconButton(
                                isSelected: selectedButtonIndex == 1,
                                onPressed: () {
                                  setState(() {
                                    selectedButtonIndex = 1;
                                  });
                                },
                                imagePath: 'assets/img/train.png',
                              ),
                            ],
                          ),
                          padding,
                          Row(
                            children: [
                              SizedBox(width: 7),
                              Text(
                                '정왕역',
                                style: mediumText?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 50),
                              Text(
                                '학교',
                                style: mediumText?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
                              Text(
                                '13분 후 출발',
                                style: mediumText?.copyWith(color: Colors.red),
                              ),
                            ],
                          ),
                          SizedBox(height: 40),
                          HeaderText(title: '정문 버스 정류장'),
                          padding,
                          Column(
                            children:
                                bus
                                    .map(
                                      (e) => Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          children: [
                                            Image.asset(e.busIcon),
                                            Text(
                                              e.busNumber,
                                              style: mediumText,
                                            ),
                                            busTextPadding,
                                            Text(
                                              e.busTime,
                                              style: mediumText?.copyWith(
                                                color: Colors.red,
                                              ),
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
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '탑승위치',
                          style: mediumText?.copyWith(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 1,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: initailPosition,
                        markers: {
                          Marker(
                            markerId: MarkerId('1'),
                            position: LatLng(37.33896, 126.7335),
                            infoWindow: InfoWindow(title: '정문 버스 정류장'),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue,
                            ),
                          ),
                          Marker(
                            markerId: MarkerId('2'),
                            position: LatLng(37.33991, 126.7323),
                            infoWindow: InfoWindow(
                              title: '셔틀버스 탑승장',
                              snippet: '바로 앞 첫 버스에 탑승',
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen,
                            ),
                          ),
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
