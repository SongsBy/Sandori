import 'package:flutter/cupertino.dart';
import 'package:handori/features/school_meal/model/meals_ranking_model.dart';
import 'package:handori/features/home/model/banner_model.dart';
import 'package:handori/features/school_meal/model/meal_model.dart';
import 'package:handori/features/bus/model/bus_model.dart';

class StaticDataRepository {
 static final List<Meal> meals = [
    Meal(
      Name: 'E동 학생식당',
      mainDish: '소불고기 덮밥',
      sideDishes: ['미역국', '배추김치', '오이무침'],
      location: 'E동 1층',
      timeSlots: [
        MealTimeSlot(label: '조식', timeRange: '', menus: []),
        MealTimeSlot(
          label: '중식',
          timeRange: '11:00~13:00',
          menus: [
            MealSet(price: 5500, items: ['소불고기덮밥', '미역국', '배추김치', '오이무침', '잡곡밥']),
            MealSet(price: 4000, items: ['제육볶음', '국물떡볶이', '단무지']),
          ],
        ),
        MealTimeSlot(
          label: '석식',
          timeRange: '17:00~18:30',
          menus: [
            MealSet(price: 5500, items: ['뼈없는감자탕', '두부계란전', '치커리사과무침', '도시락김', '알타리김치']),
            MealSet(price: 4000, items: ['스팸김치덮밥', '두부계란전', '단무지']),
          ],
        ),
      ],
    ),
    Meal(
      Name: 'TIP 학생식당',
      mainDish: '크림 파스타',
      sideDishes: ['마늘빵', '양상추 샐러드', '피클'],
      location: 'TIP관 1층',
      timeSlots: [
        MealTimeSlot(label: '조식', timeRange: '', menus: []),
        MealTimeSlot(
          label: '중식',
          timeRange: '11:30~13:30',
          menus: [
            MealSet(price: 6000, items: ['크림파스타', '마늘빵', '양상추샐러드', '피클']),
          ],
        ),
        MealTimeSlot(
          label: '석식',
          timeRange: '17:30~19:00',
          menus: [
            MealSet(price: 6000, items: ['치킨스테이크', '감자수프', '시저샐러드']),
          ],
        ),
      ],
    ),
    Meal(
      Name: '세미콘',
      mainDish: '치즈 돈까스',
      sideDishes: ['우동 국물', '단무지', '양배추 샐러드'],
      location: '학생회관 B1층',
      timeSlots: [
        MealTimeSlot(label: '조식', timeRange: '', menus: []),
        MealTimeSlot(
          label: '중식',
          timeRange: '11:00~14:00',
          menus: [
            MealSet(price: 7000, items: ['치즈돈까스', '우동국물', '단무지', '양배추샐러드']),
          ],
        ),
        MealTimeSlot(label: '석식', timeRange: '', menus: []),
      ],
    ),
    Meal(
      Name: '미가 식당',
      mainDish: '해물 순두부찌개',
      sideDishes: ['잡곡밥', '김치', '계란찜'],
      location: '경영경제관 310관 B4층',
      timeSlots: [
        MealTimeSlot(label: '조식', timeRange: '', menus: []),
        MealTimeSlot(
          label: '중식',
          timeRange: '11:00~13:30',
          menus: [
            MealSet(price: 5000, items: ['해물순두부찌개', '잡곡밥', '김치', '계란찜']),
            MealSet(price: 4500, items: ['비빔밥', '된장국', '깍두기']),
          ],
        ),
        MealTimeSlot(
          label: '석식',
          timeRange: '17:00~19:00',
          menus: [
            MealSet(price: 5000, items: ['김치찌개', '잡곡밥', '계란말이', '무나물']),
          ],
        ),
      ],
    ),
    Meal(
      Name: '가가 식당',
      mainDish: '참치 마요 덮밥',
      sideDishes: ['된장국', '단무지', '시금치 무침'],
      location: '제2학생회관 1층',
      timeSlots: [
        MealTimeSlot(label: '조식', timeRange: '', menus: []),
        MealTimeSlot(
          label: '중식',
          timeRange: '11:00~13:00',
          menus: [
            MealSet(price: 5000, items: ['참치마요덮밥', '된장국', '단무지', '시금치무침']),
          ],
        ),
        MealTimeSlot(label: '석식', timeRange: '', menus: []),
      ],
    ),
  ];



  final List<Banners> banners = [
    Banners(ImagePath: 'assets/img/banner1.png'),
    Banners(ImagePath: 'assets/img/banner2.png'),
    Banners(ImagePath: 'assets/img/banner3.png'),
  ];




  static final List<MealsRaking> mealRakings = _createMealRakings(meals);

  static List<MealsRaking> _createMealRakings(List<Meal> meals) {
    final List<MealsRaking> result = [];

    final medals = ['assets/img/saldol.png', 'assets/img/silver.png', 'assets/img/bronze.png'];
    final borderColors = [Color(0XFFFFD700), Color(0XFFBDBDBD), Color(0XFFCD7F32)];

    for(int i =0 ; i < 3; i++ ){
      final meal = meals[i];
      final ranking = MealsRaking(
          medalImage: medals[i],
          name: meal.Name,
          menu: meal.mainDish,
          borderColor: borderColors[i]
      );
      result.add(ranking);
    }
    return result;
  }

  static final List<Bus> bus =[
    Bus(busIcon: 'assets/img/bus.png', busNumber: '33', busTime: '2분'),
    Bus(busIcon: 'assets/img/bus.png', busNumber: '20-1', busTime: '7분'),
    Bus(busIcon: 'assets/img/bus.png', busNumber: '26-1', busTime: '3분'),

  ];


}
