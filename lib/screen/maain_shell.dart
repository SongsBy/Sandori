import 'package:flutter/material.dart';
import 'package:handori/component/app_bottom_nav.dart';
import 'package:handori/screen/Notice_Screen.dart';
import 'package:handori/screen/home_screen.dart';
import 'package:handori/screen/Empty_detail_screen.dart';
import 'package:handori/screen/BusTime_detail_screen.dart';
import 'package:handori/screen/Restaurant_detail_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static _MainShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainShellState>();

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void jumpTo(int i) => setState(() => _index = i);

  final _pages = const [
    HomeScreen(),             // 0
    BusTimeDetailScreen(),    // 1
    RestaurantDetailScreen(), // 2
    NoticeScreen(),           // 3
    EmptyDetailScreen(),      // 4
  ];

  Future<bool> _onWillPop() async {
    // 현재 스택에 뒤로 갈 수 있는 게 있으면 pop
    final canPop = Navigator.of(context).canPop();
    if (canPop) {
      Navigator.of(context).pop();
      return false;
    }

    // 스택이 비었고 현재 탭이 홈이 아니면 홈으로 이동
    if (_index != 0) {
      setState(() => _index = 0);
      return false;
    }

    // 홈에서 다시 뒤로가기 → 앱 종료 허용
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: _pages,
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}