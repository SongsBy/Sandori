// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_shuttle_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedShuttleResponse _$PaginatedShuttleResponseFromJson(
  Map<String, dynamic> json,
) => PaginatedShuttleResponse(
  items:
      (json['items'] as List<dynamic>)
          .map((e) => ShuttleItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$PaginatedShuttleResponseToJson(
  PaginatedShuttleResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'total': instance.total,
  'page': instance.page,
  'size': instance.size,
};
