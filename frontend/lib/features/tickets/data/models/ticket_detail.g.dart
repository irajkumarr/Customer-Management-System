// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TicketDetail _$TicketDetailFromJson(Map<String, dynamic> json) =>
    _TicketDetail(
      id: json['id'] as String,
      customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
      subject: json['subject'] as String,
      status: $enumDecode(_$TicketStatusEnumMap, json['status']),
      category: $enumDecode(_$TicketCategoryEnumMap, json['category']),
      version: (json['version'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TicketDetailToJson(_TicketDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer': instance.customer,
      'subject': instance.subject,
      'status': _$TicketStatusEnumMap[instance.status]!,
      'category': _$TicketCategoryEnumMap[instance.category]!,
      'version': instance.version,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'messages': instance.messages,
    };

const _$TicketStatusEnumMap = {
  TicketStatus.NEW: 'NEW',
  TicketStatus.AI_PROCESSING: 'AI_PROCESSING',
  TicketStatus.AI_REPLIED: 'AI_REPLIED',
  TicketStatus.ESCALATED_TO_HUMAN: 'ESCALATED_TO_HUMAN',
  TicketStatus.IN_PROGRESS: 'IN_PROGRESS',
  TicketStatus.RESOLVED: 'RESOLVED',
  TicketStatus.CLOSED: 'CLOSED',
};

const _$TicketCategoryEnumMap = {
  TicketCategory.BILLING: 'BILLING',
  TicketCategory.TECHNICAL: 'TECHNICAL',
  TicketCategory.ACCOUNT: 'ACCOUNT',
  TicketCategory.GENERAL: 'GENERAL',
  TicketCategory.UNKNOWN: 'UNKNOWN',
};
