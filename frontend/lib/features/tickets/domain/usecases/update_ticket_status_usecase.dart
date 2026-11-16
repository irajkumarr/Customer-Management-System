import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/ticket_enums.dart';
import '../repositories/ticket_repository.dart';

class UpdateTicketStatusParams {
  final String ticketId;
  final TicketStatus status;

  const UpdateTicketStatusParams({
    required this.ticketId,
    required this.status,
  });
}

class UpdateTicketStatusUseCase implements Usecase<void, UpdateTicketStatusParams> {
  final TicketRepository _ticketRepository;

  UpdateTicketStatusUseCase(this._ticketRepository);

  @override
  Future<Either<Failure, void>> call(UpdateTicketStatusParams params) async {
    return await _ticketRepository.updateTicketStatus(params.ticketId, params.status);
  }
}
