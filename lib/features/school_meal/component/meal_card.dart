import 'package:flutter/material.dart';
import 'package:handori/features/school_meal/model/meal_model.dart';

class Todaymeal extends StatelessWidget {
  final List<Meal> meals;
  final VoidCallback? onTap;

  const Todaymeal({required this.meals, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) return const SizedBox.shrink();

    return Column(
      children: meals.map((m) => _MealRow(meal: m, onTap: onTap)).toList(),
    );
  }
}

class _MealRow extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;

  const _MealRow({required this.meal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF89DAF0).withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 식당명
          SizedBox(
            width: 88,
            child: Text(
              meal.Name,
              maxLines: 2,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFDDF0F8),
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),
          // 메뉴
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F9FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    meal.mainDish,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0088CC),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.sideDishes.join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
