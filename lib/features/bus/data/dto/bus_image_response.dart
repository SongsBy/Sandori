import 'package:json_annotation/json_annotation.dart';

part 'bus_image_response.g.dart';

@JsonSerializable()
class BusImageResponse {
  @JsonKey(name: 'image_url')
  final String imageUrl;

  const BusImageResponse({required this.imageUrl});

  factory BusImageResponse.fromJson(Map<String, dynamic> json) =>
      _$BusImageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BusImageResponseToJson(this);
}
