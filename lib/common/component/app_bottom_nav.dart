import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/core/constants/app_text_styles.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNav({
    required this.onTap,
    required this.currentIndex,
    super.key,
  });

  // 컬러 톤 (원하는 색으로 조정)
  static const _active = AppColors.primary;
  static const _inactive = AppColors.textMuted;

  // 아이콘을 라벨 쪽으로 살짝 내리는 상단 여백
  static const _iconTopPadding = 6.0;

  BottomNavigationBarItem _item(IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(top: _iconTopPadding),
        child: Icon(icon),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(top: _iconTopPadding),
        child: Icon(activeIcon),
      ),
      label: label,
    );
  }

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
          // 5탭 한글 라벨('버스시간표')이 좁은 화면에서 잘리지 않도록
          // 선택/비선택 크기를 caption04(12)로 통일하고 굵기로만 구분한다.
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: AppTextStyles.caption04.copyWith(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: AppTextStyles.caption04,
          items: [
            _item(
              Icons.directions_bus_outlined,
              Icons.directions_bus_rounded,
              '버스시간표',
            ),
            _item(Icons.restaurant_outlined, Icons.restaurant_rounded, '학식'),
            _item(Icons.home_outlined, Icons.home_rounded, '홈'),
            _item(
              Icons.notifications_none_rounded,
              Icons.notifications_rounded,
              '공지사항',
            ),
            _item(
              Icons.meeting_room_outlined,
              Icons.meeting_room_rounded,
              '빈 강의실',
            ),
          ],
        ),
      ),
    );
  }
}
