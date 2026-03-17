// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoticeItemResponse _$NoticeItemResponseFromJson(Map<String, dynamic> json) =>
    NoticeItemResponse(
      id: (json['id'] as num).toInt(),
      url: json['url'] as String,
      title: json['title'] as String,
      html: json['html'] as String,
      author: json['author'] as String,
      createAt: json['createAt'] as String,
    );

Map<String, dynamic> _$NoticeItemResponseToJson(NoticeItemResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'title': instance.title,
      'html': instance.html,
      'author': instance.author,
      'createAt': instance.createAt,
    };
