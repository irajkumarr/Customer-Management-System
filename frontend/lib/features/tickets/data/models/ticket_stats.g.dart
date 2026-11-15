// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TicketStats _$TicketStatsFromJson(Map<String, dynamic> json) => _TicketStats(
  total: (json['total'] as num).toInt(),
  newTickets: (json['newTickets'] as num?)?.toInt() ?? 0,
  aiProcessing: (json['aiProcessing'] as num?)?.toInt() ?? 0,
  aiReplied: (json['aiReplied'] as num?)?.toInt() ?? 0,
  escalatedToHuman: (json['escalatedToHuman'] as num?)?.toInt() ?? 0,
  inProgress: (json['inProgress'] as num?)?.toInt() ?? 0,
  resolved: (json['resolved'] as num?)?.toInt() ?? 0,
  closed: (json['closed'] as num?)?.toInt() ?? 0,
  byCategory:
      (json['byCategory'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$TicketStatsToJson(_TicketStats instance) =>
    <String, dynamic>{
      'total': instance.total,
      'newTickets': instance.newTickets,
      'aiProcessing': instance.aiProcessing,
      'aiReplied': instance.aiReplied,
      'escalatedToHuman': instance.escalatedToHuman,
      'inProgress': instance.inProgress,
      'resolved': instance.resolved,
      'closed': instance.closed,
      'byCategory': instance.byCategory,
    };
