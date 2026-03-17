import 'package:json_annotation/json_annotation.dart';
import 'package:handori/features/notice/domain/model/notice.dart';

part 'notice_item_response.g.dart';

@JsonSerializable()
class NoticeItemResponse {
  final int id;
  final String url;
  final String title;
  final String html;
  final String author;
  final String createAt; // 서버 필드명 그대로 사용 (createAt)

  const NoticeItemResponse({
    required this.id,
    required this.url,
    required this.title,
    required this.html,
    required this.author,
    required this.createAt,
  });

  factory NoticeItemResponse.fromJson(Map<String, dynamic> json) =>
      _$NoticeItemResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NoticeItemResponseToJson(this);

  Notice toDomain() => Notice(
        id: id,
        url: url,
        title: title,
        html: html,
        author: author,
        createdAt: createAt,
      );
}
