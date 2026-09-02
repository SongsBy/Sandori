import 'package:flutter/material.dart';
import 'package:handori/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handori/common/component/app_top_bar.dart';
import 'package:handori/common/component/coming_soon_snackbar.dart';
import 'package:handori/core/constants/app_text_styles.dart';
import 'package:handori/core/router/route_paths.dart';
import 'package:handori/features/notice/domain/model/notice.dart';
import 'package:handori/features/notice/domain/model/shuttle.dart';
import 'package:handori/features/notice/presentation/provider/notice_provider.dart';
import 'package:handori/features/notice/presentation/widget/notice_card.dart';
import 'package:handori/features/notice/presentation/widget/shuttle_card.dart';
import 'package:handori/shared/model/pagination_state.dart';
import 'package:handori/shared/widget/sandol_loading_indicator.dart';

class NoticePage extends ConsumerStatefulWidget {
  const NoticePage({super.key});

  @override
  ConsumerState<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends ConsumerState<NoticePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        title: '공지사항',
        onUser: () => showComingSoonSnackBar(context),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: '일반 공지'),
            Tab(text: '기숙사'),
            Tab(text: '셔틀'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NoticeListTab(isDormitory: false),
          _NoticeListTab(isDormitory: true),
          const _ShuttleListTab(),
        ],
      ),
    );
  }
}

// ── 일반 / 기숙사 공지 탭 ──────────────────────────────────────────────────────

class _NoticeListTab extends ConsumerStatefulWidget {
  final bool isDormitory;

  const _NoticeListTab({required this.isDormitory});

  @override
  ConsumerState<_NoticeListTab> createState() => _NoticeListTabState();
}

class _NoticeListTabState extends ConsumerState<_NoticeListTab> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    if (maxScroll - current <= 300) {
      ref
          .read(noticeListNotifierProvider(isDormitory: widget.isDormitory)
              .notifier)
          .loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      noticeListNotifierProvider(isDormitory: widget.isDormitory),
    );

    return state.when(
      data: (data) => _buildList(data),
      loading: () => const Center(child: SandolLoadingIndicator()),
      error: (e, _) => _ErrorView(
        message: '공지사항을 불러올 수 없습니다.',
        onRetry: () => ref
            .invalidate(noticeListNotifierProvider(isDormitory: widget.isDormitory)),
      ),
    );
  }

  Widget _buildList(PaginationState<Notice> data) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref
          .read(noticeListNotifierProvider(isDormitory: widget.isDormitory)
              .notifier)
          .refresh(),
      child: data.items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 200),
                Center(
                  child: Text(
                    '공지사항이 없습니다.',
                    style: AppTextStyles.caption03.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            )
          : CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text.rich(
                      TextSpan(
                        style: AppTextStyles.caption03.copyWith(
                          height: 20 / 14,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: '총 '),
                          TextSpan(
                            text: '${data.totalCount}',
                            style:
                                const TextStyle(color: AppColors.primary),
                          ),
                          const TextSpan(text: '건'),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: DecoratedSliver(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    sliver: SliverList.builder(
                      itemCount:
                          data.items.length + (data.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == data.items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SandolLoadingIndicator(),
                            ),
                          );
                        }
                        return NoticeCard(
                          notice: data.items[index],
                          showDivider: index < data.items.length - 1 ||
                              data.isLoadingMore,
                          onTap: () => context.push(
                            RoutePaths.noticeDetail,
                            extra: data.items[index],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── 셔틀 탭 ──────────────────────────────────────────────────────────────────

class _ShuttleListTab extends ConsumerStatefulWidget {
  const _ShuttleListTab();

  @override
  ConsumerState<_ShuttleListTab> createState() => _ShuttleListTabState();
}

class _ShuttleListTabState extends ConsumerState<_ShuttleListTab> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    if (maxScroll - current <= 300) {
      ref.read(shuttleListNotifierProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shuttleListNotifierProvider);

    return state.when(
      data: (data) => _buildList(data),
      loading: () => const Center(child: SandolLoadingIndicator()),
      error: (e, _) => _ErrorView(
        message: '셔틀 정보를 불러올 수 없습니다.',
        onRetry: () => ref.invalidate(shuttleListNotifierProvider),
      ),
    );
  }

  Widget _buildList(PaginationState<Shuttle> data) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () =>
          ref.read(shuttleListNotifierProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: data.items.length + (data.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == data.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SandolLoadingIndicator(),
              ),
            );
          }
          return ShuttleCard(shuttle: data.items[index]);
        },
      ),
    );
  }
}

// ── 공통 에러 뷰 ──────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
