import 'package:json_annotation/json_annotation.dart';
import 'package:handori/features/notice/data/dto/shuttle_item_response.dart';
import 'package:handori/features/notice/domain/model/shuttle.dart';

part 'paginated_shuttle_response.g.dart';

@JsonSerializable()
class PaginatedShuttleResponse {
  final List<ShuttleItemResponse> items;
  final int total;
  final int page;
  final int size;

  const PaginatedShuttleResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
  });

  factory PaginatedShuttleResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedShuttleResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedShuttleResponseToJson(this);

  ({List<Shuttle> items, int total}) toDomain() => (
        items: items.map((e) => e.toDomain()).toList(),
        total: total,
      );
}
