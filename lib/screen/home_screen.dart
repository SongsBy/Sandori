import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:handori/component/Header_text.dart';
import 'package:handori/component/Topdar.dart';
import 'package:handori/model/banner_model.dart';
import 'package:handori/model/class_model.dart';
import 'package:handori/model/meal_model.dart';
import 'package:handori/repository/empty_class_repository.dart';
import 'package:handori/repository/static_repository.dart';
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
                    const HeaderText(title: '학식/식당'),
                    const SizedBox(height: 8),

                    Todaymeal(meals: meals),

                    const SizedBox(height: 16),

                    /// 빈 강의실
                    const HeaderText(title: '빈 강의실'),
                    const SizedBox(height: 8),

                    FutureBuilder<List<EmptyClass>>(
                      future: emptyClassesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: Color(0xFF00C4F9)),
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

                    const SizedBox(height: 16),

                    /// 버스
                    const HeaderText(title: '버스'),
                    const SizedBox(height: 8),

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
