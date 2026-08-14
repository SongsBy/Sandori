import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:handori/common/component/app_bottom_nav.dart';

/// 5개 탭을 감싸는 셸.
///
/// 바텀 네비를 여기 한 곳에서만 그리므로, 탭 하위 상세 화면(전체 시간표 ·
/// 공지 상세 · 조직도)으로 들어가도 네비가 사라지지 않는다. 각 탭은 자기
/// 네비게이션 스택을 따로 유지해서, 탭을 옮겼다 돌아오면 보던 화면 그대로다.
///
/// 탭 인덱스는 GoRouter가 관리한다. 화면에서 탭을 옮길 때는
/// `StatefulNavigationShell.of(context).goBranch(n)`을 쓴다.
class RootShell extends StatelessWidget {
  /// 홈 탭 인덱스. 시스템 뒤로가기의 귀착점이다.
  static const homeBranch = 2;

  final StatefulNavigationShell navigationShell;

  const RootShell({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    final isHome = navigationShell.currentIndex == homeBranch;

    return PopScope(
      // 홈에서만 뒤로가기로 앱을 종료하고, 다른 탭에서는 홈으로 되돌린다.
      canPop: isHome,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        navigationShell.goBranch(homeBranch);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: AppBottomNav(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            // 이미 선택된 탭을 다시 누르면 그 탭의 첫 화면으로 돌아간다.
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}
