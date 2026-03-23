/// 메뉴 세트 (가격 + 메뉴 항목 목록)
class MealSet {
  final int price;
  final List<String> items;

  const MealSet({required this.price, required this.items});
}

/// 식사 시간대 (조식 / 중식 / 석식)
class MealTimeSlot {
  final String label;      // "조식", "중식", "석식"
  final String timeRange;  // "11:00~13:00" — 미운영이면 빈 문자열
  final List<MealSet> menus;

  const MealTimeSlot({
    required this.label,
    required this.timeRange,
    required this.menus,
  });
}

class Meal {
  final String Name;
  final String mainDish;
  final List<String> sideDishes;
  final String? location;             // 식당 위치 (예: "E동 1층")
  final List<MealTimeSlot>? timeSlots; // 시간대별 메뉴 (조식/중식/석식)

  const Meal({
    required this.Name,
    required this.mainDish,
    required this.sideDishes,
    this.location,
    this.timeSlots,
  });
}
