// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_node_raw_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationNodeRawResponse _$OrganizationNodeRawResponseFromJson(
  Map<String, dynamic> json,
) => OrganizationNodeRawResponse(
  type: json['type'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String?,
  url: json['url'] as String?,
  subunits: json['subunits'] as Map<String, dynamic>? ?? {},
);

Map<String, dynamic> _$OrganizationNodeRawResponseToJson(
  OrganizationNodeRawResponse instance,
) => <String, dynamic>{
  'type': instance.type,
  'name': instance.name,
  'phone': instance.phone,
  'url': instance.url,
  'subunits': instance.subunits,
};
