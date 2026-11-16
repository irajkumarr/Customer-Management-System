import 'package:equatable/equatable.dart';

class TicketStatsEntity extends Equatable {
  final int total;
  final int newTickets;
  final int aiProcessing;
  final int aiReplied;
  final int escalatedToHuman;
  final int inProgress;
  final int resolved;
  final int closed;
  final Map<String, int> byCategory;

  const TicketStatsEntity({
    required this.total,
    required this.newTickets,
    required this.aiProcessing,
    required this.aiReplied,
    required this.escalatedToHuman,
    required this.inProgress,
    required this.resolved,
    required this.closed,
    required this.byCategory,
  });

  @override
  List<Object?> get props => [
        total,
        newTickets,
        aiProcessing,
        aiReplied,
        escalatedToHuman,
        inProgress,
        resolved,
        closed,
        byCategory,
      ];
}
