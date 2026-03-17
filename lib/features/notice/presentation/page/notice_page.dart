import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:handori/core/router/route_paths.dart';
import 'package:handori/features/notice/domain/model/notice.dart';
import 'package:handori/features/notice/domain/model/shuttle.dart';
import 'package:handori/features/notice/presentation/provider/notice_provider.dart';
import 'package:handori/features/notice/presentation/widget/notice_card.dart';
import 'package:handori/features/notice/presentation/widget/shuttle_card.dart';
import 'package:handori/shared/model/pagination_state.dart';

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
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('공지사항', style: TextStyle(color: Colors.black)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00C4F9),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF00C4F9),
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
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C4F9))),
      error: (e, _) => _ErrorView(
        message: '공지사항을 불러올 수 없습니다.',
        onRetry: () => ref
            .invalidate(noticeListNotifierProvider(isDormitory: widget.isDormitory)),
      ),
    );
  }

  Widget _buildList(PaginationState<Notice> data) {
    return RefreshIndicator(
      color: const Color(0xFF00C4F9),
      onRefresh: () => ref
          .read(noticeListNotifierProvider(isDormitory: widget.isDormitory)
              .notifier)
          .refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: data.items.length + (data.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == data.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF00C4F9)),
              ),
            );
          }
          return NoticeCard(
            notice: data.items[index],
            onTap: () => context.push(
              RoutePaths.noticeDetail,
              extra: data.items[index],
            ),
          );
        },
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
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C4F9))),
      error: (e, _) => _ErrorView(
        message: '셔틀 정보를 불러올 수 없습니다.',
        onRetry: () => ref.invalidate(shuttleListNotifierProvider),
      ),
    );
  }

  Widget _buildList(PaginationState<Shuttle> data) {
    return RefreshIndicator(
      color: const Color(0xFF00C4F9),
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
                child: CircularProgressIndicator(color: Color(0xFF00C4F9)),
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
              backgroundColor: const Color(0xFF00C4F9),
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
