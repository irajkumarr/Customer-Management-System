// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  ticketId: json['ticketId'] as String,
  senderType: $enumDecode(_$MessageSenderTypeEnumMap, json['senderType']),
  body: json['body'] as String,
  isAiGenerated: json['isAiGenerated'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'ticketId': instance.ticketId,
  'senderType': _$MessageSenderTypeEnumMap[instance.senderType]!,
  'body': instance.body,
  'isAiGenerated': instance.isAiGenerated,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$MessageSenderTypeEnumMap = {
  MessageSenderType.CUSTOMER: 'CUSTOMER',
  MessageSenderType.AI: 'AI',
  MessageSenderType.ADMIN: 'ADMIN',
};
