import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handori/common/component/coming_soon_snackbar.dart';
import 'package:handori/common/component/app_top_bar.dart';
import 'package:handori/core/constants/app_text_styles.dart';
import 'package:handori/core/router/route_paths.dart';
import 'package:handori/features/home/model/banner_model.dart';
import 'package:handori/features/empty_class/model/class_model.dart';
import 'package:handori/features/empty_class/presentation/provider/empty_class_provider.dart';
import 'package:handori/features/home/presentation/provider/home_static_provider.dart';
import 'package:handori/features/home/component/banner_card_top.dart';
import 'package:handori/features/bus/component/bus_time_card.dart';
import 'package:handori/features/empty_class/component/empty_class_card.dart';
import 'package:handori/features/school_meal/presentation/model/restaurant_menu.dart';
import 'package:handori/features/school_meal/presentation/provider/meal_list_notifier.dart';
import 'package:handori/features/school_meal/presentation/provider/restaurant_list_notifier.dart';
import 'package:handori/features/school_meal/presentation/widget/meal_card.dart';
import 'package:handori/shared/widget/sandol_loading_indicator.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.title02.copyWith(color: Colors.black87),
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  final VoidCallback onTap;
  const _OrganizationCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const primary = AppColors.primary;
    const subtleBg = AppColors.subtleBg;
    const border = AppColors.cardBorder;

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
                  Text(
                    '학과/부서 조회',
                    style: AppTextStyles.title03,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '전체 조직도와 연락처를 확인하세요',
                    style: AppTextStyles.caption03.copyWith(
                      color: AppColors.textSecondary,
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

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Banners> banner = ref.watch(bannersProvider);

    final Future<List<EmptyClass>> emptyClassesFuture =
        ref.watch(emptyClassesProvider.future);

    const padding = SizedBox(height: 20);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: '산돌이',
        onBell: () => showComingSoonSnackBar(context),
        onUser: () => showComingSoonSnackBar(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    _buildMealSection(),

                    const SizedBox(height: 20),

                    _SectionHeader(
                      title: '셔틀버스',
                    ),
                    const SizedBox(height: 10),

                    Bustimescreen(
                      onTap: () => StatefulNavigationShell.of(context).goBranch(0),
                      showHeader: false,
                    ),

                    const SizedBox(height: 20),

                    _SectionHeader(
                      title: '빈 강의실',
                    ),
                    const SizedBox(height: 10),

                    FutureBuilder<List<EmptyClass>>(
                      future: emptyClassesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: SandolLoadingIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('오류: ${snapshot.error}'));
                        }
                        final data = snapshot.data ?? const <EmptyClass>[];
                        return ClassStateCard(
                          items: data,
                          maxItems: 5,
                          onTap: () => StatefulNavigationShell.of(context).goBranch(4),
                          showHeader: false,
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    _SectionHeader(title: '학과/부서 조직도'),
                    const SizedBox(height: 10),

                    _OrganizationCard(
                      onTap: () => context.push(RoutePaths.organization),
                    ),

                    padding,

                    BannerTop(images: banner),

                    const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 학식 섹션 — 식당 목록 + 오늘 최신 식사를 결합해 표시.
  Widget _buildMealSection() {
    final restaurantsAsync = ref.watch(restaurantListNotifierProvider);
    final mealsAsync = ref.watch(mealListNotifierProvider());

    if (restaurantsAsync.isLoading || mealsAsync.isLoading) {
      return const SizedBox(
        height: 120,
        child:
            Center(child: SandolLoadingIndicator()),
      );
    }
    if (restaurantsAsync.hasError || mealsAsync.hasError) {
      return _MealErrorView(
        onRetry: () {
          ref.invalidate(restaurantListNotifierProvider);
          ref.invalidate(mealListNotifierProvider());
        },
      );
    }

    final restaurants = restaurantsAsync.value ?? const [];
    final meals = mealsAsync.value ?? const [];
    if (restaurants.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          '등록된 식당이 없습니다',
          style: AppTextStyles.caption03.copyWith(color: Colors.black45),
        ),
      );
    }

    return HomeMealSection(
      menus: buildRestaurantMenus(restaurants, meals),
      onTap: () => StatefulNavigationShell.of(context).goBranch(1),
    );
  }
}

/// 학식 섹션 에러 뷰 (재시도 포함)
class _MealErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _MealErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '학식 정보를 불러올 수 없습니다.',
              style: AppTextStyles.caption03.copyWith(color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
