import 'package:flutter/material.dart';
import 'package:handori/component/Header_text.dart';
import 'package:handori/component/Topdar.dart';
import 'package:handori/const/colors.dart';
import 'package:handori/model/Meals_ranking.dart';
import 'package:handori/model/meal_model.dart';
import 'package:handori/repository/static_repository.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.69);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meals = StaticDataRepository.meals;
    final raking = StaticDataRepository.mealRakings;
    if (meals.isEmpty) return Center(
      child: Text('데이터가 없습니다'),
    );
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TopBar(
                headerText: '한국공학대학교 학식',
                onBellPressed: () {},
                onUserPressed: () {},
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 25,
                ),
                child: HeaderText(
                  title: '오늘 식당 리스트',
                  titleImagePath: 'assets/img/fork.png',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 350,
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    padEnds: false,
                    itemCount: meals.length,
                    physics: BouncingScrollPhysics(),
                    controller: _controller,
                    itemBuilder: (context, i) {
                      final m = meals[i];
                      return
                        ///오늘의 학식
                        _MealsCard(controller: _controller, meals: m);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 35.0,
                ),
                child: HeaderText(
                  title: '오늘의 인기 학식',
                  titleImagePath: 'assets/img/fire.png',
                ),
              ),

              ///오늘의 인기 학식 로직
              _Ranking(Ranking: raking),
            ],
          ),
        ),
      ),
    );
  }
}


/// 오늘 식당 리스트 로직
class _MealsCard extends StatelessWidget {
  final PageController? controller;
  final Meal meals;
  const _MealsCard({required this.controller, required this.meals, super.key});

  @override
  Widget build(BuildContext context) {
    final largeText = Theme.of(context).textTheme.displayLarge;
    final mediumText = Theme.of(context).textTheme.displayMedium;
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF95E0F4)),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/img/logo1.png', width: 40),
                SizedBox(width: 20),
                Column(
                  children: [
                    Text('점심 : 11:00~13:00'),
                    Text('저녁 : 17:00~18:00'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(meals.Name, style: largeText!.copyWith(fontSize: 25)),
            SizedBox(height: 20),
            Text(
              meals.mainDish,
              style: mediumText?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF6F00),
              ),
            ),
            Column(
              children:
                  meals.sideDishes
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            '${e}',
                            style: mediumText?.copyWith(fontSize: 20),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
///오늘의 학식 랭킹 로직
class _Ranking extends StatelessWidget {
  final List<MealsRaking> Ranking;
  const _Ranking({required this.Ranking,super.key});

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    return  Column(
      children:
      Ranking
          .map(
            (rank) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.0),
              color: Colors.white,
              border: Border.all(
                color: rank.borderColor,
                width: 1.6,
              ),
            ),
            width: 320,
            height: 74,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  Image.asset(rank.medalImage),
                  SizedBox(width: 15),
                  Text(rank.name, style: mediumText),
                  SizedBox(width: 15),
                  Text('[${rank.menu}]', style: mediumText),
                ],
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}

