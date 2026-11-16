import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ticket_detail_entity.dart';
import '../repositories/ticket_repository.dart';

class GetTicketDetailUseCase implements Usecase<TicketDetailEntity, String> {
  final TicketRepository _ticketRepository;

  GetTicketDetailUseCase(this._ticketRepository);

  @override
  Future<Either<Failure, TicketDetailEntity>> call(String ticketId) async {
    return await _ticketRepository.getTicketDetail(ticketId);
  }
}
