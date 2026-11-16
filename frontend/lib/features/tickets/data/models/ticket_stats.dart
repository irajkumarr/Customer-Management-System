import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/ticket_stats_entity.dart';

part 'ticket_stats.freezed.dart';
part 'ticket_stats.g.dart';

@freezed
abstract class TicketStats with _$TicketStats {
  const factory TicketStats({
    required int total,
    @Default(0) int newTickets,
    @Default(0) int aiProcessing,
    @Default(0) int aiReplied,
    @Default(0) int escalatedToHuman,
    @Default(0) int inProgress,
    @Default(0) int resolved,
    @Default(0) int closed,
    @Default({}) Map<String, int> byCategory,
  }) = _TicketStats;

  factory TicketStats.fromJson(Map<String, dynamic> json) => _$TicketStatsFromJson(json);
}

extension TicketStatsModelX on TicketStats {
  TicketStatsEntity toEntity() => TicketStatsEntity(
        total: total,
        newTickets: newTickets,
        aiProcessing: aiProcessing,
        aiReplied: aiReplied,
        escalatedToHuman: escalatedToHuman,
        inProgress: inProgress,
        resolved: resolved,
        closed: closed,
        byCategory: byCategory,
      );
}
