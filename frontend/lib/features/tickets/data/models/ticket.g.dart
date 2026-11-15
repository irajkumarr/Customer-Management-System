// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Ticket _$TicketFromJson(Map<String, dynamic> json) => _Ticket(
  id: json['id'] as String,
  customerId: json['customerId'] as String,
  customerEmail: json['customerEmail'] as String,
  customerName: json['customerName'] as String?,
  subject: json['subject'] as String,
  status: $enumDecode(_$TicketStatusEnumMap, json['status']),
  category: $enumDecode(_$TicketCategoryEnumMap, json['category']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TicketToJson(_Ticket instance) => <String, dynamic>{
  'id': instance.id,
  'customerId': instance.customerId,
  'customerEmail': instance.customerEmail,
  'customerName': instance.customerName,
  'subject': instance.subject,
  'status': _$TicketStatusEnumMap[instance.status]!,
  'category': _$TicketCategoryEnumMap[instance.category]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
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
