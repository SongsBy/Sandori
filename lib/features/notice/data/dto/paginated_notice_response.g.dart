// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_notice_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedNoticeResponse _$PaginatedNoticeResponseFromJson(
  Map<String, dynamic> json,
) => PaginatedNoticeResponse(
  items:
      (json['items'] as List<dynamic>)
          .map((e) => NoticeItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$PaginatedNoticeResponseToJson(
  PaginatedNoticeResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'total': instance.total,
  'page': instance.page,
  'size': instance.size,
};
