// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_unit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrganizationUnitResponse _$OrganizationUnitResponseFromJson(
  Map<String, dynamic> json,
) => OrganizationUnitResponse(
  type: json['type'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String?,
  url: json['url'] as String?,
);

Map<String, dynamic> _$OrganizationUnitResponseToJson(
  OrganizationUnitResponse instance,
) => <String, dynamic>{
  'type': instance.type,
  'name': instance.name,
  'phone': instance.phone,
  'url': instance.url,
};
