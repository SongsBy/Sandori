// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shuttle_recent_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShuttleRecentResponse _$ShuttleRecentResponseFromJson(
  Map<String, dynamic> json,
) => ShuttleRecentResponse(
  primary: ShuttleItemResponse.fromJson(
    json['primary'] as Map<String, dynamic>,
  ),
  second: ShuttleItemResponse.fromJson(json['second'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ShuttleRecentResponseToJson(
  ShuttleRecentResponse instance,
) => <String, dynamic>{'primary': instance.primary, 'second': instance.second};
