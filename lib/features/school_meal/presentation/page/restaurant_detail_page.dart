import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handori/common/component/app_top_bar.dart';
import 'package:handori/common/component/coming_soon_snackbar.dart';
import 'package:handori/common/component/restaurant_location_label.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/core/constants/app_text_styles.dart';
import 'package:handori/features/school_meal/domain/model/restaurant.dart';
import 'package:handori/features/school_meal/presentation/model/restaurant_menu.dart';
import 'package:handori/features/school_meal/presentation/provider/meal_list_notifier.dart';
import 'package:handori/features/school_meal/presentation/provider/restaurant_list_notifier.dart';
import 'package:handori/features/school_meal/presentation/provider/selected_restaurant_id_notifier.dart';

// ── 색상 상수 ──────────────────────────────────────────────────
// 홈 화면 식당 칩과 동일한 메인 색상을 사용한다.
const _kPrimary = AppColors.primary;
const _kCardBorder = Color(0xFFEAEAEA);
const _kCardBg = Color(0xFFF8F8F8);
const _kGreen = Color(0xFF66BB6A);
const _kOrange = Color(0xFFFFB74D);
const _kRed = Color(0xFFE57373);

enum _MealStatus { notOperated, preparing, operating, closed }

/// 현재 시간 기준 운영 상태 판단
_MealStatus _computeStatus(MenuSlot slot) {
  if (!slot.isOperated) return _MealStatus.notOperated;
  final parts = slot.timeRange.split('~');
  if (parts.length != 2) return _MealStatus.notOperated;
  final s = parts[0].trim().split(':');
  final e = parts[1].trim().split(':');
  if (s.length != 2 || e.length != 2) return _MealStatus.notOperated;
  final now = TimeOfDay.now();
  final start = int.parse(s[0]) * 60 + int.parse(s[1]);
  final end = int.parse(e[0]) * 60 + int.parse(e[1]);
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

// ──────────────────────────────────────────────────────────────
class RestaurantDetailPage extends ConsumerStatefulWidget {
  const RestaurantDetailPage({super.key});

  @override
  ConsumerState<RestaurantDetailPage> createState() =>
      _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends ConsumerState<RestaurantDetailPage> {
  /// 사용자가 직접 펼침/접힘을 건드린 뒤의 확장 상태.
  ///
  /// null이면 아직 손대지 않았다는 뜻이고, 그동안은 현재 시각 기준
  /// "지금 먹는(또는 다음) 끼니"를 자동으로 펼친다. 식당 탭을 바꾸면
  /// 다시 null로 돌아가 새 식당의 현재 끼니를 펼친다.
  Set<int>? _userExpandedSlots;

  /// 실제로 펼쳐야 할 시간대 인덱스. 수동 조작이 없으면 자동 판정 결과를 쓴다.
  Set<int> _expandedSlotsOf(RestaurantMenu menu) {
    final manual = _userExpandedSlots;
    if (manual != null) return manual;

    final current = findCurrentOrNextSlot(menu.slots);
    if (current == null) return const {};
    final index = menu.slots.indexOf(current);
    return index < 0 ? const {} : {index};
  }

  /// 시간대 카드를 펼치거나 접는다. 첫 조작 시점에 자동 판정 결과를 그대로
  /// 이어받아 수동 상태로 굳힌다.
  void _toggleSlot(Set<int> current, int index) {
    final next = {...current};
    if (!next.remove(index)) next.add(index);
    setState(() => _userExpandedSlots = next);
  }

  String get _today => _dateString(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: '학식조회',
        onBell: () => showComingSoonSnackBar(context),
        onUser: () => showComingSoonSnackBar(context),
      ),
      body: SingleChildScrollView(
        child: restaurantsAsync.when(
          data: (restaurants) => _buildContent(restaurants),
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 80),
            child: Center(
              child: CircularProgressIndicator(color: _kPrimary),
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
  Widget _buildContent(List<Restaurant> restaurants) {
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
            // 수동 조작 기록을 지워 새 식당의 현재 끼니가 다시 펼쳐지게 한다.
            setState(() => _userExpandedSlots = null);
          },
        ),
        const SizedBox(height: 14),

        // 오늘의 메뉴 (식사 데이터)
        mealsAsync.when(
          data: (meals) {
            final menus = buildRestaurantMenus(restaurants, meals);
            final selected = menus[selectedTabIndex];
            return _buildMenuSection(selected);
          },
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 40, bottom: 40),
            child: Center(child: CircularProgressIndicator(color: _kPrimary)),
          ),
          error: (e, _) => _ErrorView(
            message: '식단 정보를 불러올 수 없습니다.',
            onRetry: () => ref.invalidate(
              mealListNotifierProvider(date: _today),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMenuSection(RestaurantMenu menu) {
    final expandedSlots = _expandedSlotsOf(menu);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 선택된 식당 요약 헤더 카드
        _RestaurantHeaderCard(menu: menu),
        const SizedBox(height: 18),

        // 식사 시간대 섹션
        if (menu.slots.isEmpty)
          const _EmptyView(message: '오늘은 등록된 식단이 없어요')
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: menu.slots.asMap().entries.map((entry) {
                final idx = entry.key;
                final slot = entry.value;
                final status = _computeStatus(slot);
                final expanded = expandedSlots.contains(idx);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MealTimeCard(
                    slot: slot,
                    status: status,
                    isExpanded: expanded,
                    onToggle: status != _MealStatus.notOperated
                        ? () => _toggleSlot(expandedSlots, idx)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
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
          final isSelected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onTabSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                color: isSelected ? _kPrimary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? _kPrimary : Colors.grey.shade300,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _kPrimary.withValues(alpha: 0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Text(
                restaurants[i].name,
                style: AppTextStyles.caption02.copyWith(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
/// 선택된 식당 요약 헤더 카드
class _RestaurantHeaderCard extends StatelessWidget {
  final RestaurantMenu menu;
  const _RestaurantHeaderCard({required this.menu});

  @override
  Widget build(BuildContext context) {
    // 메뉴가 있는 시간대만 chips로 표시
    final slots = menu.slots.where((s) => s.isOperated).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _kCardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: _kPrimary),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _kPrimary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.restaurant_rounded,
                                color: _kPrimary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menu.name,
                                    style: AppTextStyles.title02.copyWith(
                                      color: Colors.black87,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  if (menu.location != null) ...[
                                    const SizedBox(height: 4),
                                    RestaurantLocationLabel(
                                      location: menu.location!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (slots.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: slots.map((s) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _kCardBg,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: _kCardBorder),
                                ),
                                child: Text(
                                  '${s.label}  ${s.timeRange}',
                                  style: AppTextStyles.caption04.copyWith(
                                    color: Colors.black54,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
/// 식사 시간대 확장/축소 카드 (조식 / 중식 / 석식)
class _MealTimeCard extends StatelessWidget {
  final MenuSlot slot;
  final _MealStatus status;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const _MealTimeCard({
    required this.slot,
    required this.status,
    required this.isExpanded,
    this.onToggle,
  });

  Color get _statusColor {
    switch (status) {
      case _MealStatus.notOperated:
        return Colors.black38;
      case _MealStatus.preparing:
        return _kOrange;
      case _MealStatus.operating:
        return _kGreen;
      case _MealStatus.closed:
        return _kRed;
    }
  }

  String get _statusText {
    switch (status) {
      case _MealStatus.notOperated:
        return '미운영';
      case _MealStatus.preparing:
        return '준비중  ${slot.timeRange}';
      case _MealStatus.operating:
        return '운영중  ${slot.timeRange}';
      case _MealStatus.closed:
        return '운영종료';
    }
  }

  IconData get _slotIcon {
    switch (slot.label) {
      case '조식':
        return Icons.wb_sunny_outlined;
      case '점심':
        return Icons.wb_sunny;
      case '저녁':
        return Icons.brightness_3;
      default:
        return Icons.access_time_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _kCardBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_slotIcon, size: 18, color: Colors.black45),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    slot.label,
                    style: AppTextStyles.title03.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: _statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _statusText,
                          style: AppTextStyles.caption04.copyWith(
                            color: _statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onToggle != null) ...[
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black38,
                        size: 22,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: slot.menu.isNotEmpty && isExpanded
                ? Column(
                    children: [
                      const Divider(height: 1, color: _kCardBorder),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: _MealSetSection(slot: slot),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
/// 메뉴 세트 (가격 뱃지 + 아이템 목록)
class _MealSetSection extends StatelessWidget {
  final MenuSlot slot;
  const _MealSetSection({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (slot.price != null) ...[
            Text(
              '${_formatPrice(slot.price!)} 원',
              style: AppTextStyles.number02.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 10),
          ],
          ..._buildRows(slot.menu),
        ],
      ),
    );
  }

  List<Widget> _buildRows(List<String> items) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              Expanded(child: _MenuItem(text: items[i])),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption03.copyWith(color: Colors.black87),
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
                backgroundColor: _kPrimary,
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
