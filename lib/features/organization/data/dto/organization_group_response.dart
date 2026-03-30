import 'package:json_annotation/json_annotation.dart';
import 'package:handori/features/organization/data/dto/organization_unit_response.dart';
import 'package:handori/features/organization/domain/model/organization_node.dart';

part 'organization_group_response.g.dart';

@JsonSerializable()
class OrganizationGroupResponse {
  final String type;
  final String name;
  final Map<String, dynamic> subunits;

  const OrganizationGroupResponse({
    required this.type,
    required this.name,
    required this.subunits,
  });

  factory OrganizationGroupResponse.fromJson(Map<String, dynamic> json) =>
      _$OrganizationGroupResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrganizationGroupResponseToJson(this);

  OrganizationGroupNode toDomain() {
    final children = subunits.values
        .map(parseNode)
        .toList()
        .cast<OrganizationNode>();
    return OrganizationGroupNode(name: name, children: children);
  }

  static OrganizationNode parseNode(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return OrganizationUnitNode(name: raw.toString());
    }
    final type = raw['type'] as String? ?? '';
    if (type == 'unit') {
      return OrganizationUnitResponse.fromJson(raw).toDomain();
    }
    // group (재귀)
    return OrganizationGroupResponse.fromJson(raw).toDomain();
  }
}
