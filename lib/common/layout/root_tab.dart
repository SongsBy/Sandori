import 'package:flutter/material.dart';
import 'package:handori/common/layout/default_layout.dart';
import 'package:handori/common/component/app_bottom_nav.dart';
import 'package:handori/features/notice/presentation/page/notice_page.dart';
import 'package:handori/features/bus/screen/bus_time_detail_screen.dart';
import 'package:handori/features/empty_class/screen/empty_detail_screen.dart';
import 'package:handori/features/school_meal/screen/restaurant_detail_screen.dart';
import 'package:handori/features/home/screen/home_screen.dart';

class RootTab extends StatefulWidget {
  const RootTab({super.key});

  static RootTabState? of(BuildContext context) =>
      context.findAncestorStateOfType<RootTabState>();

  @override
  State<RootTab> createState() => RootTabState();
}

class RootTabState extends State<RootTab> with TickerProviderStateMixin {
  late final TabController _tabController;
  int _index = 2;

  static const _pages = [
    BusTimeDetailScreen(),    // 0
    RestaurantDetailScreen(), // 1
    HomeScreen(),             // 2 ← 중앙 (기본)
    NoticePage(),             // 3
    EmptyDetailScreen(),      // 4
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: _index,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _index = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void jumpTo(int i) {
    _tabController.animateTo(i);
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // 홈(index 2)일 때만 시스템 뒤로가기 허용 → 앱 종료
      canPop: _index == 2,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // 홈이 아닌 탭에서 뒤로가기 → 홈으로 이동
        jumpTo(2);
      },
      child: DefaultLayout(
        bottomNavigationBar: AppBottomNav(
          currentIndex: _index,
          onTap: jumpTo,
        ),
        child: IndexedStack(
          index: _index,
          children: _pages,
        ),
      ),
    );
  }
}
