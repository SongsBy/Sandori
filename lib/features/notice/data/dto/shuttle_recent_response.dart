import 'package:json_annotation/json_annotation.dart';
import 'package:handori/features/notice/data/dto/shuttle_item_response.dart';
import 'package:handori/features/notice/domain/model/shuttle_recent.dart';

part 'shuttle_recent_response.g.dart';

@JsonSerializable()
class ShuttleRecentResponse {
  final ShuttleItemResponse primary;
  final ShuttleItemResponse second;

  const ShuttleRecentResponse({
    required this.primary,
    required this.second,
  });

  factory ShuttleRecentResponse.fromJson(Map<String, dynamic> json) =>
      _$ShuttleRecentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ShuttleRecentResponseToJson(this);

  ShuttleRecent toDomain() => ShuttleRecent(
        primary: primary.toDomain(),
        second: second.toDomain(),
      );
}
