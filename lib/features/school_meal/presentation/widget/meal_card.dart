import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/core/constants/app_text_styles.dart';
import 'package:handori/features/school_meal/presentation/model/restaurant_menu.dart';
import 'package:handori/features/school_meal/presentation/provider/selected_restaurant_id_notifier.dart';
import 'package:handori/features/school_meal/presentation/widget/restaurant_chip.dart';

const _kPrimary = AppColors.primary;

/// 스와이프 판정 최소 가로 속도(px/s). 이보다 느린 드래그는 무시한다.
const _kSwipeVelocity = 200.0;

class HomeMealSection extends ConsumerStatefulWidget {
  final List<RestaurantMenu> menus;
  final VoidCallback? onTap;

  const HomeMealSection({required this.menus, this.onTap, super.key});

  @override
  ConsumerState<HomeMealSection> createState() => _HomeMealSectionState();
}

class _HomeMealSectionState extends ConsumerState<HomeMealSection> {
  /// 카드 전환 애니메이션 방향. 1이면 다음 식당(오른쪽에서 등장),
  /// -1이면 이전 식당(왼쪽에서 등장).
  int _slideDirection = 1;

  /// 식당 ID → 칩 위젯 키. 선택된 칩이 스크롤 영역 밖에 있을 때
  /// `Scrollable.ensureVisible`로 찾아가기 위해 보관한다.
  final Map<int, GlobalKey> _chipKeys = {};

  GlobalKey _chipKey(int restaurantId) =>
      _chipKeys.putIfAbsent(restaurantId, () => GlobalKey());

  /// 선택된 칩이 칩 목록 스크롤 영역 밖에 있으면 보이는 위치로 스크롤한다.
  void _revealChip(int restaurantId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chipContext = _chipKeys[restaurantId]?.currentContext;
      if (chipContext == null || !mounted) return;
      Scrollable.ensureVisible(
        chipContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    // 상세 페이지에서 먼 식당을 고르고 돌아온 경우 첫 프레임에 칩을 노출한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = ref.read(selectedRestaurantIdProvider);
      if (id != null) _revealChip(id);
    });
  }

  void _select(int from, int to) {
    if (to == from || to < 0 || to >= widget.menus.length) return;
    setState(() => _slideDirection = to > from ? 1 : -1);
    ref
        .read(selectedRestaurantIdProvider.notifier)
        .select(widget.menus[to].restaurant.id);
  }

  @override
  Widget build(BuildContext context) {
    final menus = widget.menus;
    if (menus.isEmpty) return const SizedBox.shrink();

    // 선택 상태는 전역 provider(식당 ID)로부터 파생한다. 상세 페이지에서 탭을
    // 바꾸면 ID가 갱신되고, 홈으로 돌아왔을 때 같은 칩이 선택돼 보인다.
    final selectedId = ref.watch(selectedRestaurantIdProvider);
    var selected = menus.indexWhere((m) => m.restaurant.id == selectedId);
    if (selected < 0) selected = 0;

    final menu = menus[selected];

    // 스와이프·상세 페이지 등 어디서 선택이 바뀌어도 해당 칩이 보이게 스크롤한다.
    ref.listen(selectedRestaurantIdProvider, (previous, next) {
      if (next != null && next != previous) _revealChip(next);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 식당 선택 칩 (상세 페이지 탭 바와 동일한 RestaurantChip 재사용)
        // ListView는 화면 밖 칩을 빌드하지 않아 ensureVisible이 불가능하므로,
        // 칩 개수가 적은 홈에서는 전부 빌드하는 Row 스크롤을 쓴다.
        SizedBox(
          height: 46,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < menus.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  RestaurantChip(
                    key: _chipKey(menus[i].restaurant.id),
                    label: menus[i].name,
                    isSelected: i == selected,
                    onTap: () => _select(selected, i),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 선택된 식당 메뉴 카드 — 좌우 스와이프로 식당 전환
        GestureDetector(
          onTap: () {
            // 상세 페이지가 동일한 식당으로 진입하도록 현재 선택 ID를 확정한다.
            ref
                .read(selectedRestaurantIdProvider.notifier)
                .select(menu.restaurant.id);
            widget.onTap?.call();
          },
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < -_kSwipeVelocity) {
              _select(selected, selected + 1);
            } else if (velocity > _kSwipeVelocity) {
              _select(selected, selected - 1);
            }
          },
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                // 새로 들어오는 카드는 스와이프 방향에서, 나가는 카드는 반대쪽으로.
                final incoming =
                    child.key == ValueKey(menu.restaurant.id);
                final begin = Offset(
                  (incoming ? 0.25 : -0.25) * _slideDirection,
                  0,
                );
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: begin, end: Offset.zero)
                        .animate(animation),
                    child: child,
                  ),
                );
              },
              layoutBuilder: (currentChild, previousChildren) => Stack(
                alignment: Alignment.topCenter,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              ),
              child: _MealMenuCard(
                key: ValueKey(menu.restaurant.id),
                menu: menu,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 선택된 식당의 현재(또는 다음) 끼니 메뉴 카드
class _MealMenuCard extends StatelessWidget {
  final RestaurantMenu menu;

  const _MealMenuCard({required this.menu, super.key});

  @override
  Widget build(BuildContext context) {
    final slot = findCurrentOrNextSlot(menu.slots);
    final price = slot?.price;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBorder.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 식당명 + 가격
          Row(
            children: [
              Text(
                menu.name,
                style: AppTextStyles.caption01.copyWith(
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (price != null)
                Text(
                  '${price ~/ 1000},${(price % 1000).toString().padLeft(3, '0')}원',
                  style: AppTextStyles.number02.copyWith(
                    color: _kPrimary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // 메뉴 아이템 칩
          if (slot != null && slot.menu.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: slot.menu.map((item) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item,
                    style: AppTextStyles.caption04.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            )
          else
            Text(
              '오늘은 운영하지 않아요',
              style: AppTextStyles.caption03.copyWith(
                color: Colors.black45,
              ),
            ),
        ],
      ),
    );
  }
}
