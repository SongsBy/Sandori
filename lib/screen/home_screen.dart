import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:handori/component/Header_text.dart';
import 'package:handori/component/Topdar.dart';
import 'package:handori/model/banner_model.dart';
import 'package:handori/model/class_model.dart';
import 'package:handori/model/meal_model.dart';
import 'package:handori/repository/empty_class_repository.dart'; // ⬅️ 파일명 확인(소문자 권장)
import 'package:handori/repository/static_repository.dart';
import 'package:handori/screen/BusTime_detail_screen.dart';
import 'package:handori/screen/Empty_detail_screen.dart';
import 'package:handori/screen/Restaurant_detail_screen.dart';

import '../component/BannerCard_top.dart';
import '../component/BustimeCardScreen.dart';
import '../component/EmptyclassCard.dart';
import '../component/MealCard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataRepository = GetIt.I<StaticDataRepository>();
    final List<Meal> meals = StaticDataRepository.meals;
    final List<Banners> banner = dataRepository.banners;


    final Future<List<EmptyClass>> emptyClassesFuture =
    GetIt.I<EmptyClassRepository>().fetchEmptyClassesStatically();

    const padding = SizedBox(height: 20);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
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
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RestaurantDetailScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    Todaymeal(meals: meals),

                    padding,

                    /// 빈 강의실
                    HeaderText(
                      title: '빈 강의실',
                      onTextButtonPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EmptyDetailScreen()),
                        );
                      },
                    ),
                    padding,

                    // ⬇️ Repository 비동기 결과 표시
                    FutureBuilder<List<EmptyClass>>(
                      future: emptyClassesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('오류: ${snapshot.error}'));
                        }
                        final data = snapshot.data ?? const <EmptyClass>[];
                        // EmptyclassCard.dart 안의 섹션 위젯이 List<EmptyClass>를 받는다고 가정
                        return ClassStateSection(classstate: data);
                      },
                    ),

                    padding,

                    /// 버스
                    HeaderText(
                      title: '버스',
                      onTextButtonPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const BusTimeDetailScreen()),
                        );
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