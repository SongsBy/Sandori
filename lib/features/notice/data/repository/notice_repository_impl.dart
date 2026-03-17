import 'package:handori/features/notice/data/data_source/notice_api.dart';
import 'package:handori/features/notice/domain/model/notice.dart';
import 'package:handori/features/notice/domain/model/shuttle.dart';
import 'package:handori/features/notice/domain/model/shuttle_recent.dart';
import 'package:handori/features/notice/domain/repository/notice_repository.dart';

class NoticeRepositoryImpl implements NoticeRepository {
  final NoticeApi _api;

  const NoticeRepositoryImpl(this._api);

  @override
  Future<({List<Notice> items, int total})> getNotices({
    int page = 1,
    int size = 10,
  }) async {
    final response = await _api.getNotices(page, size);
    return response.toDomain();
  }

  @override
  Future<({List<Notice> items, int total})> getDormitoryNotices({
    int page = 1,
    int size = 10,
  }) async {
    final response = await _api.getDormitoryNotices(page, size);
    return response.toDomain();
  }

  @override
  Future<({List<Shuttle> items, int total})> getShuttles({
    int page = 1,
    int size = 10,
  }) async {
    final response = await _api.getShuttles(page, size);
    return response.toDomain();
  }

  @override
  Future<ShuttleRecent> getRecentShuttle() async {
    final response = await _api.getRecentShuttle();
    return response.toDomain();
  }
}
