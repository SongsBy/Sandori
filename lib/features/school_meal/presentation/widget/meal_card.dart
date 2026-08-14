import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/core/constants/app_text_styles.dart';
import 'package:handori/features/school_meal/presentation/model/restaurant_menu.dart';
import 'package:handori/features/school_meal/presentation/provider/selected_restaurant_id_notifier.dart';

const _kPrimary = AppColors.primary;

class HomeMealSection extends ConsumerWidget {
  final List<RestaurantMenu> menus;
  final VoidCallback? onTap;

  const HomeMealSection({required this.menus, this.onTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (menus.isEmpty) return const SizedBox.shrink();

    // 선택 상태는 전역 provider(식당 ID)로부터 파생한다. 상세 페이지에서 탭을
    // 바꾸면 ID가 갱신되고, 홈으로 돌아왔을 때 같은 칩이 선택돼 보인다.
    final selectedId = ref.watch(selectedRestaurantIdProvider);
    var selected = menus.indexWhere((m) => m.restaurant.id == selectedId);
    if (selected < 0) selected = 0;

    final menu = menus[selected];
    final slot = findCurrentOrNextSlot(menu.slots);
    final price = slot?.price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 식당 선택 칩
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: menus.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final isSelected = i == selected;
              return GestureDetector(
                onTap: () => ref
                    .read(selectedRestaurantIdProvider.notifier)
                    .select(menus[i].restaurant.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? _kPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? _kPrimary : Colors.grey.shade300,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _kPrimary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    menus[i].name,
                    style: AppTextStyles.caption02.copyWith(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // 선택된 식당 메뉴 카드
        GestureDetector(
          onTap: () {
            // 상세 페이지가 동일한 식당으로 진입하도록 현재 선택 ID를 확정한다.
            ref
                .read(selectedRestaurantIdProvider.notifier)
                .select(menu.restaurant.id);
            onTap?.call();
          },
          child: Container(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
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
          ),
        ),
      ],
    );
  }
}
