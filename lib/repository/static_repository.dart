import 'package:flutter/cupertino.dart';
import 'package:handori/model/banner_model.dart';
import 'package:handori/model/class_model.dart';
import 'package:handori/model/meal_model.dart';

class StaticDataRepository {
  final List<Meal> meals = [
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




  final List<EmptyClass> emptyclass = [
    EmptyClass(
      className: 'E동 : ',
      classCount: '24',
      trafficIcon: 'assets/img/green.png',
      classList: ['E234', 'E303', 'E402', 'E220', 'E321', 'E502'],
    ),
    EmptyClass(
      className: 'C동 : ',
      classCount: '18',
      trafficIcon: 'assets/img/orange.png',
      classList: ['C234', 'C303', 'C402', 'C220', 'C321', 'C502'],
    ),
    EmptyClass(
      className: 'G동 : ',
      classCount: '10',
      trafficIcon: 'assets/img/red.png',
      classList: ['G234', 'G303', 'G402', 'G220', 'G321', 'G502'],
    ),
    EmptyClass(
      className: 'A동 : ',
      classCount: '13',
      trafficIcon: 'assets/img/orange.png',
      classList: ['A234', 'A303', 'A402', 'A220', 'A321', 'A502'],
    ),
    EmptyClass(
      className: 'D동 : ',
      classCount: '20',
      trafficIcon: 'assets/img/green.png',
      classList: ['D234', 'D303', 'D402', 'D220', 'D321', 'D502'],
    ),
  ];
}