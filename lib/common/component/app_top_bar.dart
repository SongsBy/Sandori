import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/core/constants/app_text_styles.dart';

/// 앱 전체 공통 상단 바.
///
/// 탭 화면마다 제각각이던 커스텀 앱바(홈 `TopBar`, 학식 `SliverAppBar`,
/// 공지 `AppBar`, 버스 `_Header`)를 하나로 통일한다.
///
/// - [onBack]이 null이면 뒤로가기 버튼을 그리지 않는다(홈 탭).
/// - [onBell] / [onUser]가 null이면 해당 액션 아이콘을 감춘다.
/// - [bottom]으로 TabBar 등을 덧붙일 수 있다(공지 탭).
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// 툴바 높이. 화면 간 세로 리듬을 맞추기 위해 모든 탭이 공유한다.
  static const double barHeight = 56;

  /// 본문 배경과 같은 값이라 스크롤 시 경계가 생기지 않는다.
  static const Color background = AppColors.background;
  static const Color foreground = AppColors.textPrimary;

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onBell;
  final VoidCallback? onUser;
  final PreferredSizeWidget? bottom;

  const AppTopBar({
    required this.title,
    this.onBack,
    this.onBell,
    this.onUser,
    this.bottom,
    super.key,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(barHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: barHeight,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            if (onBack != null)
              _BarIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                iconSize: 18,
                tooltip: '뒤로',
                onTap: onBack!,
              )
            else
              const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title02.copyWith(color: foreground),
              ),
            ),
            if (onBell != null)
              _BarIconButton(
                icon: Icons.notifications_none_rounded,
                iconSize: 22,
                tooltip: '알림',
                onTap: onBell!,
              ),
            if (onUser != null)
              _BarIconButton(
                icon: Icons.account_circle_outlined,
                iconSize: 24,
                tooltip: '내 정보',
                onTap: onUser!,
              ),
          ],
        ),
      ),
      bottom: bottom,
    );
  }
}

/// 상단 바 전용 아이콘 버튼. 터치 영역을 44x44로 보장한다.
class _BarIconButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final String tooltip;
  final VoidCallback onTap;

  const _BarIconButton({
    required this.icon,
    required this.iconSize,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: iconSize, color: AppTopBar.foreground),
          ),
        ),
      ),
    );
  }
}
