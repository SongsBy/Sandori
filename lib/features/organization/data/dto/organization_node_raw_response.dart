import 'package:json_annotation/json_annotation.dart';
import 'package:handori/features/organization/domain/model/organization_node.dart';

part 'organization_node_raw_response.g.dart';

/// group / unit 양쪽을 모두 표현하는 통합 DTO.
/// retrofit_generator는 `List<dynamic>` / `Map<String,dynamic>`을 반환 타입으로 지원하지 않아
/// 이 DTO로 대체한다.
@JsonSerializable()
class OrganizationNodeRawResponse {
  final String type;
  final String name;
  final String? phone;
  final String? url;
  @JsonKey(defaultValue: {})
  final Map<String, dynamic> subunits;

  const OrganizationNodeRawResponse({
    required this.type,
    required this.name,
    this.phone,
    this.url,
    this.subunits = const {},
  });

  factory OrganizationNodeRawResponse.fromJson(Map<String, dynamic> json) =>
      _$OrganizationNodeRawResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrganizationNodeRawResponseToJson(this);

  OrganizationNode toDomain() {
    if (type == 'unit') {
      return OrganizationUnitNode(name: name, phone: phone, url: url);
    }
    final children = subunits.values
        .map(_parseChild)
        .cast<OrganizationNode>()
        .toList();
    return OrganizationGroupNode(name: name, children: children);
  }

  static OrganizationNode _parseChild(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return OrganizationUnitNode(name: raw.toString());
    }
    return OrganizationNodeRawResponse.fromJson(raw).toDomain();
  }
}
