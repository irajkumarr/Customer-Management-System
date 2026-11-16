import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/ticket_enums.dart';
import '../repositories/ticket_repository.dart';

class UpdateTicketCategoryParams {
  final String ticketId;
  final TicketCategory category;

  const UpdateTicketCategoryParams({
    required this.ticketId,
    required this.category,
  });
}

class UpdateTicketCategoryUseCase implements Usecase<void, UpdateTicketCategoryParams> {
  final TicketRepository _ticketRepository;

  UpdateTicketCategoryUseCase(this._ticketRepository);

  @override
  Future<Either<Failure, void>> call(UpdateTicketCategoryParams params) async {
    return await _ticketRepository.updateTicketCategory(params.ticketId, params.category);
  }
}
