import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:handori/component/Header_text.dart';
import 'package:handori/component/Topdar.dart';
import 'package:handori/model/banner_model.dart';
import 'package:handori/model/class_model.dart';
import 'package:handori/model/meal_model.dart';
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
    final List<Meal> meals = dataRepository.meals;
    final List<Banners> banner = dataRepository.banners;
    final List<EmptyClass> classState = dataRepository.emptyclass;
    final smallText = TextTheme.of(context).displaySmall;
    final padding = SizedBox(height: 20);
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ///상단 바
              TopBar(onBellPressed: () {}, onUserPressed: () {}),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 상단 배너
                      BannerTop(images: banner),
                      //패딩값
                      padding,
                      //각 섹션 헤더 텍스트
                      HeaderText(
                        title: '학식/식당',
                        showIconButton: true,
                        onTextButtonPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RestaurantDetailScreen(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 20),

                      ///오늘의 식단
                      Todaymeal(meals: meals),
                      padding,

                      HeaderText(
                        title: '빈 강의실',
                        showIconButton: true,
                        onTextButtonPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EmptyDetailScreen(),
                            ),
                          );
                        },
                      ),
                      padding,

                      ///빈 강의실
                      ClassStateSection(classstate: classState),
                      padding,

                      HeaderText(
                        title: '버스',
                        showIconButton: true,
                        onTextButtonPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BusTimeDetailScreen(),
                            ),
                          );
                        },
                      ),
                      padding,

                      ///셔틀 버스 카드 섹션
                      Bustimescreen(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
