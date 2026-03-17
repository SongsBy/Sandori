// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shuttle_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShuttleItemResponse _$ShuttleItemResponseFromJson(Map<String, dynamic> json) =>
    ShuttleItemResponse(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      place: json['place'] as String,
      createAt: json['createAt'] as String,
    );

Map<String, dynamic> _$ShuttleItemResponseToJson(
  ShuttleItemResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'imageUrl': instance.imageUrl,
  'place': instance.place,
  'createAt': instance.createAt,
};
