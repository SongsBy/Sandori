import 'package:json_annotation/json_annotation.dart';
import 'package:handori/features/notice/data/dto/notice_item_response.dart';
import 'package:handori/features/notice/domain/model/notice.dart';

part 'paginated_notice_response.g.dart';

@JsonSerializable()
class PaginatedNoticeResponse {
  final List<NoticeItemResponse> items;
  final int total;
  final int page;
  final int size;

  const PaginatedNoticeResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
  });

  factory PaginatedNoticeResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedNoticeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedNoticeResponseToJson(this);

  ({List<Notice> items, int total}) toDomain() => (
        items: items.map((e) => e.toDomain()).toList(),
        total: total,
      );
}
