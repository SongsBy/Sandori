import 'package:handori/features/notice/domain/model/notice.dart';
import 'package:handori/features/notice/domain/model/shuttle.dart';
import 'package:handori/features/notice/domain/model/shuttle_recent.dart';

abstract class NoticeRepository {
  Future<({List<Notice> items, int total})> getNotices({
    int page = 1,
    int size = 10,
  });

  Future<({List<Notice> items, int total})> getDormitoryNotices({
    int page = 1,
    int size = 10,
  });

  Future<({List<Shuttle> items, int total})> getShuttles({
    int page = 1,
    int size = 10,
  });

  Future<ShuttleRecent> getRecentShuttle();
}
