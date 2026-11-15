// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionStatus _$SessionStatusFromJson(Map<String, dynamic> json) =>
    _SessionStatus(
      authenticated: json['authenticated'] as bool,
      username: json['username'] as String?,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$SessionStatusToJson(_SessionStatus instance) =>
    <String, dynamic>{
      'authenticated': instance.authenticated,
      'username': instance.username,
      'role': instance.role,
    };
