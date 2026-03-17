import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:handori/core/network/dio_provider.dart';
import 'package:handori/features/notice/data/data_source/notice_api.dart';
import 'package:handori/features/notice/data/repository/notice_repository_impl.dart';
import 'package:handori/features/notice/domain/model/notice.dart';
import 'package:handori/features/notice/domain/model/shuttle.dart';
import 'package:handori/features/notice/domain/model/shuttle_recent.dart';
import 'package:handori/features/notice/domain/repository/notice_repository.dart';
import 'package:handori/shared/model/pagination_state.dart';

part 'notice_provider.g.dart';

// ── API ────────────────────────────────────────────────────────────────────

@riverpod
NoticeApi noticeApi(Ref ref) {
  final dio = ref.watch(dioProvider);
  return NoticeApi(dio);
}

// ── Repository ─────────────────────────────────────────────────────────────

@riverpod
NoticeRepository noticeRepository(Ref ref) {
  final api = ref.watch(noticeApiProvider);
  return NoticeRepositoryImpl(api);
}

// ── 일반 공지 / 기숙사 공지 (family: isDormitory) ────────────────────────────
// 같은 로직, 같은 반환 타입(Notice) → family 파라미터로 중복 제거

@riverpod
class NoticeListNotifier extends _$NoticeListNotifier {
  static const int _pageSize = 10;

  @override
  Future<PaginationState<Notice>> build({required bool isDormitory}) async {
    return _fetchPage(1);
  }

  Future<({List<Notice> items, int total})> _callRepo(int page) {
    final repo = ref.read(noticeRepositoryProvider);
    return isDormitory
        ? repo.getDormitoryNotices(page: page, size: _pageSize)
        : repo.getNotices(page: page, size: _pageSize);
  }

  Future<PaginationState<Notice>> _fetchPage(int page) async {
    final result = await _callRepo(page);
    return PaginationState(
      items: result.items,
      currentPage: page,
      hasMore: result.items.length >= _pageSize,
    );
  }

  Future<void> loadNextPage() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final result = await _callRepo(current.currentPage + 1);
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...result.items],
          currentPage: current.currentPage + 1,
          hasMore: result.items.length >= _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(1));
  }
}

// ── 셔틀 목록 ────────────────────────────────────────────────────────────────

@riverpod
class ShuttleListNotifier extends _$ShuttleListNotifier {
  static const int _pageSize = 10;

  @override
  Future<PaginationState<Shuttle>> build() async {
    return _fetchPage(1);
  }

  Future<PaginationState<Shuttle>> _fetchPage(int page) async {
    final repo = ref.read(noticeRepositoryProvider);
    final result = await repo.getShuttles(page: page, size: _pageSize);
    return PaginationState(
      items: result.items,
      currentPage: page,
      hasMore: result.items.length >= _pageSize,
    );
  }

  Future<void> loadNextPage() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final repo = ref.read(noticeRepositoryProvider);
      final result = await repo.getShuttles(
        page: current.currentPage + 1,
        size: _pageSize,
      );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...result.items],
          currentPage: current.currentPage + 1,
          hasMore: result.items.length >= _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(1));
  }
}

// ── 최근 셔틀 (단건) ──────────────────────────────────────────────────────────

@riverpod
Future<ShuttleRecent> recentShuttle(Ref ref) {
  final repo = ref.watch(noticeRepositoryProvider);
  return repo.getRecentShuttle();
}
