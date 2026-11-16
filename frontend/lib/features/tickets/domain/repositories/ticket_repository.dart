import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/page_response.dart';
import '../../data/models/ticket_enums.dart';
import '../entities/message_entity.dart';
import '../entities/ticket_detail_entity.dart';
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

  Future<Either<Failure, TicketDetailEntity>> getTicketDetail(String id);

  Future<Either<Failure, void>> updateTicketStatus(String id, TicketStatus status);

  Future<Either<Failure, void>> updateTicketCategory(String id, TicketCategory category);

  Future<Either<Failure, MessageEntity>> sendAdminReply(String id, String body);
}
