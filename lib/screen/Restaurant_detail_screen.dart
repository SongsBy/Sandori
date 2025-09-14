import 'package:flutter/material.dart';
import 'package:handori/component/Header_text.dart';
import 'package:handori/model/Meals_ranking_model.dart';
import 'package:handori/model/meal_model.dart';
import 'package:handori/repository/static_repository.dart';
import 'maain_shell.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late final PageController _controller;


  double _pageValue = 0.0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.78);


    _controller.addListener(() {
      if (!mounted) return;
      if (_controller.positions.length == 1) {
        final p = _controller.page ?? _controller.initialPage.toDouble();
        setState(() => _pageValue = p);
      } else {

        setState(() => _pageValue = _currentIndex.toDouble());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _backToHome() {
    final shell = MainShell.of(context);
    if (shell != null) {
      shell.jumpTo(0);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final meals = StaticDataRepository.meals;
    final raking = StaticDataRepository.mealRakings;

    if (meals.isEmpty) {
      return const Center(child: Text('데이터가 없습니다'));
    }
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFFAFAFA),
            foregroundColor: Colors.black,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            toolbarHeight: 72,
            title: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _backToHome,
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '학식조회',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: '알림',
                                onPressed: () {},
                                icon: const Icon(Icons.notifications_none, size: 20),
                                color: Colors.black54,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                tooltip: '내 정보',
                                onPressed: () {},
                                icon: const Icon(Icons.account_circle_outlined, size: 22),
                                color: Colors.black54,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 본문
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // 타이틀(아이콘 제거)
                  const HeaderText(title: '오늘 식당 리스트'),
                  const SizedBox(height: 12),


                  SizedBox(
                    height: 360,
                    child: PageView.builder(
                      controller: _controller,
                      physics: const BouncingScrollPhysics(),
                      itemCount: meals.length,
                      padEnds: false,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (context, index) {

                        final dist = (_pageValue - index).abs();
                        final scale = 1 - (dist * 0.08).clamp(0.0, 0.08);
                        final opacity = 1 - (dist * 0.3).clamp(0.0, 0.3);
                        return Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: scale,
                            child: _MealPrettyCard(meal: meals[index]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),


                  Center(
                    child: _DotsIndicator(
                      count: meals.length,
                      current: _pageValue,
                    ),
                  ),

                  const SizedBox(height: 28),
                  const HeaderText(title: '오늘의 인기 학식'),
                  const SizedBox(height: 12),

                  // ====== 오늘의 인기 학식 ======
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: raking.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _RankingCard(item: raking[i]),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 한 끼 카드(UI 개선)
class _MealPrettyCard extends StatelessWidget {
  final Meal meal;
  const _MealPrettyCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final largeText = Theme.of(context).textTheme.displayLarge;
    final mediumText = Theme.of(context).textTheme.displayMedium;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9F8FF), Color(0xFFFFFFFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF95E0F4).withOpacity(.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFF95E0F4), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFEAF6)),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Image.asset('assets/img/logo1.png'),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('점심  11:00 ~ 13:00'),
                    SizedBox(height: 4),
                    Text('저녁  17:00 ~ 18:00'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),


            Text(
              meal.Name,
              style: largeText?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),


            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E3),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFFFBB85)),
              ),
              child: Text(
                meal.mainDish,
                style: mediumText?.copyWith(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEB6D00),
                ),
              ),
            ),

            const SizedBox(height: 12),


            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: meal.sideDishes
                  .map((e) => _Chip(text: e, icon: Icons.restaurant_menu))
                  .toList(),
            ),

            const Spacer(),


            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 1,
              color: const Color(0xFFEAF7FB),
            ),
          ],
        ),
      ),
    );
  }
}

/// 작은 칩
class _Chip extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Chip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6F2F7)),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.restaurant_menu, size: 14, color: Color(0xFF6DB6D9)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.8,
              fontWeight: FontWeight.w600,
              color: Color(0xFF35576B),
            ),
          ),
        ],
      ),
    );
  }
}

/// 안전한 도트 인디케이터(컨트롤러 직접 접근 X)
class _DotsIndicator extends StatelessWidget {
  final int count;
  final double current; // 부드러운 실수 페이지 값

  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = (current - i).abs() < 0.5;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 18 : 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6DB6D9) : const Color(0xFFBFDDEB),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

/// 인기 학식 카드
class _RankingCard extends StatelessWidget {
  final MealsRaking item;
  const _RankingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final mediumText = Theme.of(context).textTheme.displayMedium;
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: item.borderColor.withOpacity(.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // 메달 이미지
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: item.borderColor.withOpacity(.09),
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset(item.medalImage, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          // 텍스트들
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: mediumText?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE9ECFA)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '[${item.menu}]',
                    style: mediumText?.copyWith(
                      fontSize: 13.2,
                      color: const Color(0xFF4E56B9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.black38),
        ],
      ),
    );
  }
}