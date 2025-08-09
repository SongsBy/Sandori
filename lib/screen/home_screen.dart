import 'package:flutter/material.dart';
import 'package:handori/screen/Banner_top.dart';
import 'package:handori/screen/BustimeScreen.dart';
import 'package:handori/screen/Emptyclass.dart';
import 'package:handori/screen/TodayMeal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final smallText = TextTheme.of(context).displaySmall;
    final meals = [
      Meal(Name: 'E동학생식당', mainDIsh: '제육덮밥', sideDish:['두부 미소국', '배추김치', '요구르트']),
      Meal(Name: 'TIP 학생식당', mainDIsh: '제육덮밥', sideDish:['두부 미소국', '배추김치', '요구르트']),
      Meal(Name: '세미콘', mainDIsh: '제육덮밥', sideDish:['두부 미소국', '배추김치', '요구르트']),
      Meal(Name: '미가 식당', mainDIsh: '제육덮밥', sideDish:['두부 미소국', '배추김치', '요구르트']),
      Meal(Name: '가가 식당', mainDIsh: '제육덮밥', sideDish:['두부 미소국', '배추김치', '요구르트']),
    ];
    
    final banner = [
      Banners(banner: ['assets/img/banner1.png']),
      Banners(banner: ['assets/img/banner2.png']),
      Banners(banner: ['assets/img/banner3.png']),
    ];


    final padding = SizedBox(height: 20,);
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ///상단
              _Top(onBellPressed: () {}, onUserPressed: () {}),
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
                      BannerTop(images: banner),
                      padding,
                      _HeaderText(
                        title: '학식/식당',
                        showIconButton: false,
                      ),
                      SizedBox(height: 20),
                      ///오늘의 식단 카드 섹션
                      Todaymeal(meals: meals),
                      padding,
                      _HeaderText(title: '강의실', showIconButton: false),
                      padding,
                      ///빈 강의실 카드 섹션
                      Emptyclass(),
                      padding,
                      _HeaderText(title: '버스', showIconButton: false),
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

/// 상단 위젯
class _Top extends StatelessWidget {
  final VoidCallback onBellPressed;
  final VoidCallback onUserPressed;
  const _Top({
    required this.onBellPressed,
    required this.onUserPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2025년 7월 26일',
                    style: TextTheme.of(
                      context,
                    ).displayLarge?.copyWith(fontSize: 21),overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '오늘 하루도 맛있는 하루 되세요!',
                    style: TextTheme.of(
                      context,
                    ).displayMedium?.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onBellPressed,
              icon: Image.asset('assets/img/bell.png'),
            ),
            IconButton(
              onPressed: onUserPressed,
              icon: Image.asset('assets/img/user.png'),
            ),
          ],
        ),
      ),
    );
  }
}
/// 각 카트섹션 헤더 텍스트
class _HeaderText extends StatelessWidget {
  final String title;
  final VoidCallback? onIconButtonPressed;
  final bool showIconButton;
  const _HeaderText({
    required this.title,
    this.showIconButton = true,
    this.onIconButtonPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style:mediumText?.copyWith(fontSize: 25 , color:Colors.black87, fontWeight: FontWeight.w600),
          ),
        ),
        if (showIconButton)
          IconButton(
            onPressed: onIconButtonPressed,
            icon: Image.asset('assets/img/dot.png'),
          ),
      ],
    );
  }
}
