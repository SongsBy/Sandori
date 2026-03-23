import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:handori/common/component/header_text.dart';
import 'package:handori/common/component/top_bar.dart';
import 'package:handori/common/layout/root_tab.dart';
import 'package:handori/core/router/route_paths.dart';
import 'package:handori/features/home/model/banner_model.dart';
import 'package:handori/features/empty_class/model/class_model.dart';
import 'package:handori/features/school_meal/model/meal_model.dart';
import 'package:handori/features/empty_class/repository/empty_class_repository.dart';
import 'package:handori/common/repository/static_repository.dart';
import 'package:handori/features/home/component/banner_card_top.dart';
import 'package:handori/features/bus/component/bus_time_card.dart';
import 'package:handori/features/empty_class/component/empty_class_card.dart';
import 'package:handori/features/school_meal/component/meal_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _OrganizationCard extends StatelessWidget {
  final VoidCallback onTap;
  const _OrganizationCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF0088CC);
    const subtleBg = Color(0xFFF7FBFD);
    const border = Color(0xFFE2EEF3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: subtleBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.account_tree_outlined,
                  color: primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '학과/부서 조회',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '전체 조직도와 연락처를 확인하세요',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7A89),
                          fontSize: 13,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
          ],
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final dataRepository = GetIt.I<StaticDataRepository>();
    final List<Meal> meals = StaticDataRepository.meals;
    final List<Banners> banner = dataRepository.banners;


    final Future<List<EmptyClass>> emptyClassesFuture =
        GetIt.I<EmptyClassRepository>().fetchEmptyClassesStatically();

    const padding = SizedBox(height: 20);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 30,
        title: TopBar(
          headerText: '산돌이',
          onBellPressed: () {},
          onUserPressed: () {},
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30.0,
            vertical: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    padding,

                    /// 상단 배너
                    BannerTop(images: banner),

                    padding,

                    /// 학식/식당
                    const HeaderText(title: '학식/식당'),
                    const SizedBox(height: 8),

                    Todaymeal(
                      meals: meals,
                      onTap: () => RootTab.of(context)?.jumpTo(1),
                    ),

                    const SizedBox(height: 16),

                    /// 빈 강의실
                    const HeaderText(title: '빈 강의실'),
                    const SizedBox(height: 8),

                    FutureBuilder<List<EmptyClass>>(
                      future: emptyClassesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: Color(0xFF00C4F9)),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('오류: ${snapshot.error}'));
                        }
                        final data = snapshot.data ?? const <EmptyClass>[];
                        return ClassStateCard(
                          items: data,
                          maxItems: 5,
                          onTap: () => RootTab.of(context)?.jumpTo(4),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    /// 버스
                    const HeaderText(title: '버스'),
                    const SizedBox(height: 8),

                    /// 셔틀/버스 카드 섹션
                    Bustimescreen(onTap: () => RootTab.of(context)?.jumpTo(0)),

                    const SizedBox(height: 16),

                    /// 조직도
                    const HeaderText(title: '학과/부서 조직도'),
                    const SizedBox(height: 8),

                    _OrganizationCard(
                      onTap: () => context.push(RoutePaths.organization),
                    ),

                    const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
