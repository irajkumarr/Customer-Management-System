import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/page_response.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/entities/ticket_stats_entity.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/ticket_remote_data_source.dart';
import '../models/ticket.dart';
import '../models/ticket_enums.dart';
import '../models/ticket_stats.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDataSource remoteDataSource;

  TicketRepositoryImpl({required this.remoteDataSource});

  Failure _mapExceptionToFailure(Object exception) {
    if (exception is ApiException) {
      if (exception.isUnauthorized) {
        return AuthenticationFailure(message: exception.message, statusCode: exception.statusCode);
      }
      return ServerFailure(message: exception.message, statusCode: exception.statusCode);
    }
    return ServerFailure(message: exception.toString());
  }

  @override
  Future<Either<Failure, PageResponse<TicketEntity>>> getTickets({
    TicketStatus? status,
    TicketCategory? category,
    String? search,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final pageResponse = await remoteDataSource.getTickets(
        status: status,
        category: category,
        search: search,
        page: page,
        size: size,
      );

      final entityPage = PageResponse<TicketEntity>(
        content: pageResponse.content.map((model) => model.toEntity()).toList(),
        totalElements: pageResponse.totalElements,
        totalPages: pageResponse.totalPages,
        size: pageResponse.size,
        number: pageResponse.number,
        first: pageResponse.first,
        last: pageResponse.last,
        empty: pageResponse.empty,
      );

      return Right(entityPage);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, TicketStatsEntity>> getStats() async {
    try {
      final statsModel = await remoteDataSource.getStats();
      return Right(statsModel.toEntity());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }
}
