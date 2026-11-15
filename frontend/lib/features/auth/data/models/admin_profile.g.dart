// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminProfile _$AdminProfileFromJson(Map<String, dynamic> json) =>
    _AdminProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      role: $enumDecode(_$AdminRoleEnumMap, json['role']),
    );

Map<String, dynamic> _$AdminProfileToJson(_AdminProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'role': _$AdminRoleEnumMap[instance.role]!,
    };

const _$AdminRoleEnumMap = {AdminRole.ADMIN: 'ADMIN'};
