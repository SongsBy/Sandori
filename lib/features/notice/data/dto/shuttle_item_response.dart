import 'package:json_annotation/json_annotation.dart';
import 'package:handori/features/notice/domain/model/shuttle.dart';

part 'shuttle_item_response.g.dart';

@JsonSerializable()
class ShuttleItemResponse {
  final String id;
  final String imageUrl;
  final String place;
  final String createAt; // 서버 필드명 그대로 사용 (createAt)

  const ShuttleItemResponse({
    required this.id,
    required this.imageUrl,
    required this.place,
    required this.createAt,
  });

  factory ShuttleItemResponse.fromJson(Map<String, dynamic> json) =>
      _$ShuttleItemResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ShuttleItemResponseToJson(this);

  Shuttle toDomain() => Shuttle(
        id: id,
        imageUrl: imageUrl,
        place: place,
        createdAt: createAt,
      );
}
