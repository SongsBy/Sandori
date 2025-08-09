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
      Meal(
        Name: 'E동 학생식당',
        mainDish: '소불고기 덮밥',
        sideDishes: ['미역국', '배추김치', '오이무침'],
      ),
      Meal(
        Name: 'TIP 학생식당',
        mainDish: '크림 파스타',
        sideDishes: ['마늘빵', '양상추 샐러드', '피클'],
      ),
      Meal(
        Name: '세미콘',
        mainDish: '치즈 돈까스',
        sideDishes: ['우동 국물', '단무지', '양배추 샐러드'],
      ),
      Meal(
        Name: '미가 식당',
        mainDish: '해물 순두부찌개',
        sideDishes: ['잡곡밥', '김치', '계란찜'],
      ),
      Meal(
        Name: '가가 식당',
        mainDish: '참치 마요 덮밥',
        sideDishes: ['된장국', '단무지', '시금치 무침'],
      ),
    ];

    final banner = [
      Banners(banner: ['assets/img/banner1.png']),
      Banners(banner: ['assets/img/banner2.png']),
      Banners(banner: ['assets/img/banner3.png']),
    ];

    final classState = [
      classStateInfo(
        className: 'E동 : ',
        classCount: '24',
        trfficIcon: 'assets/img/green.png',
        classList: ['E234', 'E303', 'E402', 'E220','E321','E502'],
      ),
      classStateInfo(
        className: 'C동 : ',
        classCount: '18',
        trfficIcon: 'assets/img/orange.png',
        classList: ['C234', 'C303', 'C402', 'C220', 'C321', 'C502'],
      ),
      classStateInfo(
        className: 'G동 : ',
        classCount: '10',
        trfficIcon: 'assets/img/red.png',
        classList: ['G234', 'G303', 'G402', 'G220', 'G321', 'G502'],
      ),
      classStateInfo(
        className: 'A동 : ',
        classCount: '13',
        trfficIcon: 'assets/img/orange.png',
        classList: ['A234', 'A303', 'A402', 'A220', 'A321', 'A502'],
      ),
      classStateInfo(
        className: 'D동 : ',
        classCount: '20',
        trfficIcon: 'assets/img/green.png',
        classList: ['D234', 'D303', 'D402', 'D220', 'D321', 'D502'],
      ),
    ];


    final padding = SizedBox(height: 20);
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
                      _HeaderText(title: '학식/식당', showIconButton: true, onTextButtonPressed: onShowMealPressed,),

                      SizedBox(height: 20),

                      ///오늘의 식단 카드 섹션
                      Todaymeal(meals: meals),
                      padding,
                      _HeaderText(title: '빈 강의실', showIconButton: true, onTextButtonPressed: onShowClassPressed,),
                      padding,

                      ///빈 강의실 카드 섹션
                      Emptyclass(classstate: classState),
                      padding,
                      _HeaderText(title: '버스', showIconButton: true, onTextButtonPressed: onShowBusPressed,),
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
  void onShowMealPressed(){

  }
  void onShowClassPressed(){

  }
  void onShowBusPressed(){

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
                    ).displayLarge?.copyWith(fontSize: 21),
                    overflow: TextOverflow.ellipsis,
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
              icon: Icon(Icons.account_circle)
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
  final VoidCallback? onTextButtonPressed;
  final bool showIconButton;
  const _HeaderText({
    required this.title,
    this.showIconButton = true,
    this.onTextButtonPressed,
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
            style: mediumText?.copyWith(
              fontSize: 25,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (showIconButton)
          TextButton(
              onPressed: onTextButtonPressed,
              child: Text('더보기', style: TextStyle(color: Colors.grey),))
      ],
    );
  }
}
