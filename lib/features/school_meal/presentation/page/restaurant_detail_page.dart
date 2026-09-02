import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handori/common/component/app_top_bar.dart';
import 'package:handori/common/component/coming_soon_snackbar.dart';
import 'package:handori/common/component/restaurant_location_label.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/core/constants/app_text_styles.dart';
import 'package:handori/features/school_meal/domain/model/meal_type.dart';
import 'package:handori/features/school_meal/domain/model/restaurant.dart';
import 'package:handori/features/school_meal/presentation/model/restaurant_menu.dart';
import 'package:handori/features/school_meal/presentation/provider/meal_list_notifier.dart';
import 'package:handori/features/school_meal/presentation/provider/restaurant_list_notifier.dart';
import 'package:handori/features/school_meal/presentation/provider/selected_restaurant_id_notifier.dart';
import 'package:handori/features/school_meal/presentation/widget/restaurant_chip.dart';
import 'package:handori/shared/widget/sandol_loading_indicator.dart';

// ── 색상 상수 ──────────────────────────────────────────────────
const _kCardBorder = Color(0xFFECECEC);
const _kBulletColor = Color(0xFFC9C9C9);
const _kPreparing = Color(0xFFDD8A00);

/// 시간대별 아이콘. 디자인 시안의 아이콘 이미지가 자체 배경 타일을 포함한다.
String _iconOf(MealType type) {
  switch (type) {
    case MealType.breakfast:
    case MealType.brunch:
      return 'assets/icons/meal/morn.png';
    case MealType.lunch:
      return 'assets/icons/meal/sun.png';
    case MealType.dinner:
      return 'assets/icons/meal/moon.png';
  }
}

enum _MealStatus { unknown, preparing, operating, closed }

/// 현재 시간 기준 운영 상태. 운영시간이 등록되지 않았으면 [unknown].
_MealStatus _computeStatus(String timeRange) {
  final parts = timeRange.split('~');
  if (parts.length != 2) return _MealStatus.unknown;
  final s = parts[0].trim().split(':');
  final e = parts[1].trim().split(':');
  if (s.length != 2 || e.length != 2) return _MealStatus.unknown;
  final start = (int.tryParse(s[0]) ?? 0) * 60 + (int.tryParse(s[1]) ?? 0);
  final end = (int.tryParse(e[0]) ?? 0) * 60 + (int.tryParse(e[1]) ?? 0);
  final now = TimeOfDay.now();
  final nowMin = now.hour * 60 + now.minute;
  if (nowMin < start) return _MealStatus.preparing;
  if (nowMin <= end) return _MealStatus.operating;
  return _MealStatus.closed;
}

/// 가격 숫자 → "5,500" 형식
String _formatPrice(int price) {
  final s = price.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

String _dateString(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

const _kWeekdays = ['월', '화', '수', '목', '금', '토', '일'];

/// "9월 2일 수요일" 형식
String _koreanDate(DateTime d) =>
    '${d.month}월 ${d.day}일 ${_kWeekdays[d.weekday - 1]}요일';

/// "11:30~13:50" → "11:30 – 13:50"
String _prettyRange(String timeRange) {
  final parts = timeRange.split('~');
  if (parts.length != 2) return timeRange;
  return '${parts[0].trim()} – ${parts[1].trim()}';
}

// ──────────────────────────────────────────────────────────────
class RestaurantDetailPage extends ConsumerWidget {
  const RestaurantDetailPage({super.key});

  String get _today => _dateString(DateTime.now());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(restaurantListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: '학식조회',
        onUser: () => showComingSoonSnackBar(context),
      ),
      body: SingleChildScrollView(
        child: restaurantsAsync.when(
          data: (restaurants) => _buildContent(context, ref, restaurants),
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(
              child: SandolLoadingIndicator(),
            ),
          ),
          error: (e, _) => _ErrorView(
            message: '식당 정보를 불러올 수 없습니다.',
            onRetry: () => ref.invalidate(restaurantListNotifierProvider),
          ),
        ),
      ),
    );
  }

  // ── 본문 ──────────────────────────────────────────────────────
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Restaurant> restaurants,
  ) {
    if (restaurants.isEmpty) {
      return const _EmptyView(message: '등록된 식당이 없습니다');
    }

    // 선택 탭은 전역 provider(식당 ID)에서 파생한다. 홈 화면의 칩 선택이
    // 그대로 진입 탭으로 반영되고, 여기서 탭을 바꾸면 홈 칩도 동기화된다.
    final selectedId = ref.watch(selectedRestaurantIdProvider);
    var selectedTabIndex = restaurants.indexWhere((r) => r.id == selectedId);
    if (selectedTabIndex < 0) selectedTabIndex = 0;

    final mealsAsync = ref.watch(mealListNotifierProvider(date: _today));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),

        // 식당 선택 탭 바
        _RestaurantTabBar(
          restaurants: restaurants,
          selectedIndex: selectedTabIndex,
          onTabSelected: (i) {
            // 전역 provider 갱신 → 홈 칩과 양방향 동기화.
            ref
                .read(selectedRestaurantIdProvider.notifier)
                .select(restaurants[i].id);
          },
        ),
        const SizedBox(height: 16),

        // 오늘의 메뉴 (식사 데이터)
        mealsAsync.when(
          data: (meals) {
            final menus = buildRestaurantMenus(restaurants, meals);
            final selected = menus[selectedTabIndex];
            return _MenuSection(menu: selected);
          },
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 40, bottom: 40),
            child: Center(child: SandolLoadingIndicator()),
          ),
          error: (e, _) => _ErrorView(
            message: '식단 정보를 불러올 수 없습니다.',
            onRetry: () => ref.invalidate(
              mealListNotifierProvider(date: _today),
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
/// 식당 선택 수평 스크롤 탭 바
class _RestaurantTabBar extends StatelessWidget {
  final List<Restaurant> restaurants;
  final int selectedIndex;
  final void Function(int) onTabSelected;

  const _RestaurantTabBar({
    required this.restaurants,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: restaurants.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return RestaurantChip(
            label: restaurants[i].name,
            isSelected: i == selectedIndex,
            onTap: () => onTabSelected(i),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
/// 식당명 + 날짜/위치 헤더와 시간대별 메뉴 블록
class _MenuSection extends StatelessWidget {
  final RestaurantMenu menu;
  const _MenuSection({required this.menu});

  @override
  Widget build(BuildContext context) {
    final location = menu.location;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 식당명 · 날짜/위치
          Text(
            menu.name,
            style: AppTextStyles.title02.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _koreanDate(DateTime.now()),
                style: AppTextStyles.caption03.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              if (location != null) ...[
                Text(
                  '  ·  ',
                  style: AppTextStyles.caption03.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Flexible(
                  child: RestaurantLocationLabel(location: location),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          // 시간대별 메뉴 블록
          if (menu.slots.isEmpty)
            const _EmptyView(message: '오늘은 등록된 식단이 없어요')
          else
            for (int i = 0; i < menu.slots.length; i++) ...[
              if (i > 0) const SizedBox(height: 18),
              _MealBlock(slot: menu.slots[i]),
            ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
/// 시간대 블록: 아이콘 + 라벨 + 운영시간/상태 헤더와 메뉴 카드
class _MealBlock extends StatelessWidget {
  final MenuSlot slot;
  const _MealBlock({required this.slot});

  @override
  Widget build(BuildContext context) {
    final status = _computeStatus(slot.timeRange);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              Image.asset(
                _iconOf(slot.mealType),
                width: 30,
                height: 30,
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(width: 9),
              Text(
                slot.label,
                style: AppTextStyles.caption01.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              if (slot.timeRange.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _prettyRange(slot.timeRange),
                    style: AppTextStyles.caption03.copyWith(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else
                const Spacer(),
              _StatusLabel(status: status),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _MenuCard(slot: slot),
      ],
    );
  }
}

/// 운영 상태 표시. 운영중일 때만 색으로 강조하고 나머지는 회색으로 눌러둔다.
class _StatusLabel extends StatelessWidget {
  final _MealStatus status;
  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    final (String text, Color color) = switch (status) {
      _MealStatus.operating => ('운영중', AppColors.success),
      _MealStatus.preparing => ('준비중', _kPreparing),
      _MealStatus.closed => ('운영종료', AppColors.textMuted),
      _MealStatus.unknown => ('', Colors.transparent),
    };
    if (text.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: AppTextStyles.caption04.copyWith(color: color),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
/// 메뉴 카드: 2열 불릿 목록 + 가격. 메뉴가 없으면 빈 상태 문구.
class _MenuCard extends StatelessWidget {
  final MenuSlot slot;
  const _MenuCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final items = slot.menu;

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: _cardDecoration,
        child: Text(
          '아직 등록된 메뉴가 없어요',
          style: AppTextStyles.caption03.copyWith(color: AppColors.textMuted),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildRows(items),
          if (slot.price != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: _kCardBorder),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '가격',
                  style: AppTextStyles.caption04.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  '${_formatPrice(slot.price!)}원',
                  style: AppTextStyles.number02.copyWith(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static final _cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: _kCardBorder),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  List<Widget> _buildRows(List<String> items) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 < items.length ? 8 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _MenuItem(text: items[i])),
              const SizedBox(width: 12),
              Expanded(
                child: i + 1 < items.length
                    ? _MenuItem(text: items[i + 1])
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }
    return rows;
  }
}

/// 단일 메뉴 아이템 (도트 불릿 + 텍스트)
class _MenuItem extends StatelessWidget {
  final String text;
  const _MenuItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: _kBulletColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
/// 빈 상태 뷰
class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant_outlined,
                size: 44, color: Colors.black26),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.caption03.copyWith(color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}

/// 공통 에러 뷰 (재시도 버튼 포함)
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: onRetry,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
