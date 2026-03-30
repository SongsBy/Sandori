// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_images_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusImagesResponse _$BusImagesResponseFromJson(Map<String, dynamic> json) =>
    BusImagesResponse(
      imageUrls:
          (json['image_urls'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$BusImagesResponseToJson(BusImagesResponse instance) =>
    <String, dynamic>{'image_urls': instance.imageUrls};
