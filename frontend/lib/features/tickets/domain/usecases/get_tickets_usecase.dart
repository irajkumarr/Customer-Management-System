import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/page_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/ticket_enums.dart';
import '../entities/ticket_entity.dart';
import '../repositories/ticket_repository.dart';

class GetTicketsParams {
  final TicketStatus? status;
  final TicketCategory? category;
  final String? search;
  final int page;
  final int size;

  const GetTicketsParams({
    this.status,
    this.category,
    this.search,
    this.page = 0,
    this.size = 20,
  });
}

class GetTicketsUseCase implements Usecase<PageResponse<TicketEntity>, GetTicketsParams> {
  final TicketRepository _ticketRepository;

  GetTicketsUseCase(this._ticketRepository);

  @override
  Future<Either<Failure, PageResponse<TicketEntity>>> call(GetTicketsParams params) async {
    return await _ticketRepository.getTickets(
      status: params.status,
      category: params.category,
      search: params.search,
      page: params.page,
      size: params.size,
    );
  }
}
