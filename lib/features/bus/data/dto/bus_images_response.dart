import 'package:json_annotation/json_annotation.dart';

part 'bus_images_response.g.dart';

@JsonSerializable()
class BusImagesResponse {
  @JsonKey(name: 'image_urls')
  final List<String> imageUrls;

  const BusImagesResponse({required this.imageUrls});

  factory BusImagesResponse.fromJson(Map<String, dynamic> json) =>
      _$BusImagesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BusImagesResponseToJson(this);

  List<String> toDomain() => imageUrls;
}
