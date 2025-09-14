import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNav({
    required this.onTap,
    required this.currentIndex,
    super.key,
  });

  // 컬러 톤 (원하는 색으로 조정)
  static const _active = Color(0xFF3CB7BE);
  static const _inactive = Color(0xFFB0B6BF);

  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: currentIndex,
          onTap: onTap,
          iconSize: 28,
          selectedItemColor: _active,
          unselectedItemColor: _inactive,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/img/home_filled.png')),
              activeIcon: ImageIcon(AssetImage('assets/img/home_filled.png')),
              label: '홈',
            ),

            BottomNavigationBarItem(
              /// 버스시간표
              icon: ImageIcon(AssetImage('assets/img/bus_filled.png')),
              activeIcon: ImageIcon(AssetImage('assets/img/bus_filled.png')),
              label: '버스시간표',
            ),
            BottomNavigationBarItem(
              /// 학식
              icon: ImageIcon(AssetImage('assets/img/meal_filled.png')),
              activeIcon: ImageIcon(AssetImage('assets/img/meal_filled.png')),
              label: '학식',
            ),
            BottomNavigationBarItem(
              /// 공지사항
              icon: ImageIcon(AssetImage('assets/img/notice_filled.png')),
              activeIcon: ImageIcon(AssetImage('assets/img/notice_filled.png')),
              label: '공지사항',
            ),
            BottomNavigationBarItem(
              /// 빈 강의실
              icon: ImageIcon(AssetImage('assets/img/emptyclass_filled.png')),
              activeIcon: ImageIcon(AssetImage('assets/img/emptyclass_filled.png')),
              label: '빈 강의실',
            ),
          ],
        ),
      ),
    );
  }
}