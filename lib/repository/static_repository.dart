import 'package:flutter/cupertino.dart';
import 'package:handori/model/Meals_ranking_model.dart';
import 'package:handori/model/banner_model.dart';
import 'package:handori/model/class_model.dart';
import 'package:handori/model/meal_model.dart';

import '../model/bus_model.dart';

class StaticDataRepository {
 static final List<Meal> meals = [
    Meal(
      Name: 'E동 학생식당',
      mainDish: '소불고기 덮밥',
      sideDishes: ['미역국', '배추김치', '오이무침'],
    ),
    Meal(
      Name: 'TIP 학생식당',
      mainDish: '크림 파스타',
      sideDishes: ['마늘빵', '양상추 샐러드', '피클'],
    ),
    Meal(
      Name: '세미콘',
      mainDish: '치즈 돈까스',
      sideDishes: ['우동 국물', '단무지', '양배추 샐러드'],
    ),
    Meal(
      Name: '미가 식당',
      mainDish: '해물 순두부찌개',
      sideDishes: ['잡곡밥', '김치', '계란찜'],
    ),
    Meal(
      Name: '가가 식당',
      mainDish: '참치 마요 덮밥',
      sideDishes: ['된장국', '단무지', '시금치 무침'],
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

    final medals = ['assets/img/gold.png', 'assets/img/silver.png', 'assets/img/bronze.png'];
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