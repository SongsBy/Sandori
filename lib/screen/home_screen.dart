import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:handori/component/Header_text.dart';
import 'package:handori/component/Topdar.dart';
import 'package:handori/component/app_bottom_nav.dart';
import 'package:handori/model/banner_model.dart';
import 'package:handori/model/class_model.dart';
import 'package:handori/model/meal_model.dart';
import 'package:handori/repository/empty_class_repository.dart';
import 'package:handori/repository/static_repository.dart';
import 'package:handori/screen/BusTime_detail_screen.dart';
import 'package:handori/screen/Empty_detail_screen.dart';
import 'package:handori/screen/Restaurant_detail_screen.dart';
import 'package:handori/screen/maain_shell.dart';

import '../component/BannerCard_top.dart';
import '../component/BustimeCardScreen.dart';
import '../component/EmptyclassCard.dart';
import '../component/MealCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final dataRepository = GetIt.I<StaticDataRepository>();
    final List<Meal> meals = StaticDataRepository.meals;
    final List<Banners> banner = dataRepository.banners;
    int _currentIndex = 0;

    void _onTapapped(int index) {
      setState(() => _currentIndex = index);

      if (index == 1) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => EmptyDetailScreen()));
      }
      else if  (index == 2) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => BusTimeDetailScreen()));
      }
      else if (index == 3) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => RestaurantDetailScreen()));
      }
    }

    final Future<List<EmptyClass>> emptyClassesFuture =
        GetIt.I<EmptyClassRepository>().fetchEmptyClassesStatically();

    const padding = SizedBox(height: 20);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 10.0,
            ),
            child: Column(
              children: [
                /// 상단 바
                TopBar(
                  headerText: '산돌이',
                  onBellPressed: () {},
                  onUserPressed: () {},
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    padding,

                    /// 상단 배너
                    BannerTop(images: banner),

                    padding,

                    /// 학식/식당
                    HeaderText(
                      title: '학식/식당',
                      onTextButtonPressed: () {
                        MainShell.of(context)?.jumpTo(2);
                      },
                    ),
                    const SizedBox(height: 20),

                    Todaymeal(meals: meals),

                    padding,

                    /// 빈 강의실
                    HeaderText(
                      title: '빈 강의실',
                      onTextButtonPressed: () {
                        MainShell.of(context)?.jumpTo(4);
                      },
                    ),
                    padding,

                    FutureBuilder<List<EmptyClass>>(
                      future: emptyClassesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('오류: ${snapshot.error}'));
                        }
                        final data = snapshot.data ?? const <EmptyClass>[];
                        return ClassStateCard(
                          items: data,
                          maxItems: 5,
                          onMore: () {},
                        );
                      },
                    ),

                    padding,

                    /// 버스
                    HeaderText(
                      title: '버스',
                      onTextButtonPressed: () {
                        MainShell.of(context)?.jumpTo(1);
                      },
                    ),
                    padding,

                    /// 셔틀/버스 카드 섹션
                    const Bustimescreen(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
