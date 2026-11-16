import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/ticket_repository.dart';

class SendAdminReplyParams {
  final String ticketId;
  final String body;

  const SendAdminReplyParams({
    required this.ticketId,
    required this.body,
  });
}

class SendAdminReplyUseCase implements Usecase<MessageEntity, SendAdminReplyParams> {
  final TicketRepository _ticketRepository;

  SendAdminReplyUseCase(this._ticketRepository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendAdminReplyParams params) async {
    return await _ticketRepository.sendAdminReply(params.ticketId, params.body);
  }
}
