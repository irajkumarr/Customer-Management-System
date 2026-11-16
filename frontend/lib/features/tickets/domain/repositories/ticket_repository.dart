import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/page_response.dart';
import '../../data/models/ticket_enums.dart';
import '../entities/ticket_entity.dart';
import '../entities/ticket_stats_entity.dart';

abstract class TicketRepository {
  Future<Either<Failure, PageResponse<TicketEntity>>> getTickets({
    TicketStatus? status,
    TicketCategory? category,
    String? search,
    int page = 0,
    int size = 20,
  });

  Future<Either<Failure, TicketStatsEntity>> getStats();
}
