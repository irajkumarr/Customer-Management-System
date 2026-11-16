import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ticket_stats_entity.dart';
import '../repositories/ticket_repository.dart';

class GetTicketStatsUseCase implements Usecase<TicketStatsEntity, NoParams> {
  final TicketRepository _ticketRepository;

  GetTicketStatsUseCase(this._ticketRepository);

  @override
  Future<Either<Failure, TicketStatsEntity>> call(NoParams params) async {
    return await _ticketRepository.getStats();
  }
}
