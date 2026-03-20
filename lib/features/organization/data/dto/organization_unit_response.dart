import 'package:json_annotation/json_annotation.dart';
import 'package:handori/features/organization/domain/model/organization_node.dart';

part 'organization_unit_response.g.dart';

@JsonSerializable()
class OrganizationUnitResponse {
  final String type;
  final String name;
  final String? phone;
  final String? url;

  const OrganizationUnitResponse({
    required this.type,
    required this.name,
    this.phone,
    this.url,
  });

  factory OrganizationUnitResponse.fromJson(Map<String, dynamic> json) =>
      _$OrganizationUnitResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrganizationUnitResponseToJson(this);

  OrganizationUnitNode toDomain() =>
      OrganizationUnitNode(name: name, phone: phone, url: url);
}
