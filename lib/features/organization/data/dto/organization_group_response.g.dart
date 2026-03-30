// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_group_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationGroupResponse _$OrganizationGroupResponseFromJson(
  Map<String, dynamic> json,
) => OrganizationGroupResponse(
  type: json['type'] as String,
  name: json['name'] as String,
  subunits: json['subunits'] as Map<String, dynamic>,
);

Map<String, dynamic> _$OrganizationGroupResponseToJson(
  OrganizationGroupResponse instance,
) => <String, dynamic>{
  'type': instance.type,
  'name': instance.name,
  'subunits': instance.subunits,
};
