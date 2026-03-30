import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:handori/features/school_meal/model/meal_model.dart';

const _kPrimary = AppColors.primary;

MealTimeSlot? _findCurrentOrNextSlot(List<MealTimeSlot>? timeSlots) {
  if (timeSlots == null || timeSlots.isEmpty) return null;

  final now = DateTime.now();
  final nowMinutes = now.hour * 60 + now.minute;

  MealTimeSlot? nextSlot;

  for (final slot in timeSlots) {
    if (slot.timeRange.isEmpty || slot.menus.isEmpty) continue;

    final parts = slot.timeRange.split('~');
    if (parts.length != 2) continue;

    final startParts = parts[0].trim().split(':');
    final endParts = parts[1].trim().split(':');
    if (startParts.length != 2 || endParts.length != 2) continue;

    final startMinutes =
        (int.tryParse(startParts[0]) ?? 0) * 60 + (int.tryParse(startParts[1]) ?? 0);
    final endMinutes =
        (int.tryParse(endParts[0]) ?? 0) * 60 + (int.tryParse(endParts[1]) ?? 0);

    if (nowMinutes >= startMinutes && nowMinutes < endMinutes) {
      return slot;
    }

    if (nowMinutes < startMinutes) {
      nextSlot ??= slot;
    }
  }

  return nextSlot ??
      timeSlots.lastWhere(
        (s) => s.timeRange.isNotEmpty && s.menus.isNotEmpty,
        orElse: () => timeSlots.first,
      );
}

class HomeMealSection extends StatefulWidget {
  final List<Meal> meals;
  final VoidCallback? onTap;

  const HomeMealSection({required this.meals, this.onTap, super.key});

  @override
  State<HomeMealSection> createState() => _HomeMealSectionState();
}

class _HomeMealSectionState extends State<HomeMealSection> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.meals.isEmpty) return const SizedBox.shrink();

    final meal = widget.meals[_selected];
    final slot = _findCurrentOrNextSlot(meal.timeSlots);
    final price = slot?.menus.isNotEmpty == true ? slot!.menus.first.price : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 식당 선택 칩
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.meals.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final isSelected = i == _selected;
              return GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
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
                    widget.meals[i].Name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
          onTap: widget.onTap,
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
                // 식당명 + 위치 + 가격
                Row(
                  children: [
                    Text(
                      meal.Name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    if (meal.location != null) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Colors.black38,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          meal.location!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else
                      const Spacer(),
                    if (price != null)
                      Text(
                        '${price ~/ 1000},${(price % 1000).toString().padLeft(3, '0')}원',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0088CC),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // 메뉴 아이템 칩
                if (slot != null && slot.menus.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: slot.menus.first.items.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                else
                  const Text(
                    '오늘은 운영하지 않아요',
                    style: TextStyle(fontSize: 13, color: Colors.black45),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
