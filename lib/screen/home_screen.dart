import 'package:flutter/material.dart';
import 'package:handori/screen/BustimeScreen.dart';
import 'package:handori/screen/Emptyclass.dart';
import 'package:handori/screen/TodayMeal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final smallText = TextTheme.of(context).displaySmall;
    final padding = SizedBox(height: 20,);
    return Scaffold(
      backgroundColor: Colors.white,
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
                    horizontal: 21.0,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderText(
                        title: '오늘의 식단표',
                        showIconButton: true,
                        onIconButtonPressed: () {},
                      ),
                      Todaymeal(),
                      padding,
                      _HeaderText(title: '강의실 조회', showIconButton: false),
                      padding,
                      Emptyclass(),
                      padding,
                      _HeaderText(title: '다음버스', showIconButton: false),
                      padding,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Image.asset('assets/img/logo.png', width: 36, height: 56),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '2025년 7월 26일',
                style: TextTheme.of(
                  context,
                ).displayLarge?.copyWith(fontSize: 21),
              ),
              SizedBox(height: 4),
              Text(
                '오늘 하루도 맛있는 하루 되세요!',
                style: TextTheme.of(
                  context,
                ).displayMedium?.copyWith(fontSize: 13),
              ),
            ],
          ),
          SizedBox(width: 42),
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
            style:mediumText?.copyWith(fontSize: 21 , color:Colors.black87, fontWeight: FontWeight.w600),
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
