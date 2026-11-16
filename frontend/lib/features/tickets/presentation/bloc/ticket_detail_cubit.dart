import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/ticket_enums.dart';
import '../../domain/usecases/get_ticket_detail_usecase.dart';
import '../../domain/usecases/send_admin_reply_usecase.dart';
import '../../domain/usecases/update_ticket_category_usecase.dart';
import '../../domain/usecases/update_ticket_status_usecase.dart';
import 'ticket_detail_state.dart';

class TicketDetailCubit extends Cubit<TicketDetailState> {
  final GetTicketDetailUseCase getTicketDetailUseCase;
  final UpdateTicketStatusUseCase updateTicketStatusUseCase;
  final UpdateTicketCategoryUseCase updateTicketCategoryUseCase;
  final SendAdminReplyUseCase sendAdminReplyUseCase;

  TicketDetailCubit({
    required this.getTicketDetailUseCase,
    required this.updateTicketStatusUseCase,
    required this.updateTicketCategoryUseCase,
    required this.sendAdminReplyUseCase,
  }) : super(const TicketDetailState());

  Future<void> loadTicket(String ticketId) async {
    emit(state.copyWith(
      status: TicketDetailStatus.loading,
      errorMessage: null,
      actionSuccessMessage: null,
    ));

    final result = await getTicketDetailUseCase(ticketId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: TicketDetailStatus.failure,
        errorMessage: failure.message,
      )),
      (ticket) => emit(state.copyWith(
        status: TicketDetailStatus.success,
        ticket: ticket,
        errorMessage: null,
      )),
    );
  }

  /// Explicit Manual Refresh of the ticket thread (No WebSockets / Polling)
  Future<void> refresh() async {
    final currentTicket = state.ticket;
    if (currentTicket == null) return;

    emit(state.copyWith(
      status: TicketDetailStatus.refreshing,
      errorMessage: null,
      actionSuccessMessage: null,
    ));

    final result = await getTicketDetailUseCase(currentTicket.id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: TicketDetailStatus.failure,
        errorMessage: failure.message,
      )),
      (ticket) => emit(state.copyWith(
        status: TicketDetailStatus.success,
        ticket: ticket,
      )),
    );
  }

  Future<void> updateStatus(TicketStatus newStatus) async {
    final currentTicket = state.ticket;
    if (currentTicket == null || currentTicket.status == newStatus) return;

    emit(state.copyWith(
      isUpdatingStatus: true,
      errorMessage: null,
      actionSuccessMessage: null,
    ));

    final result = await updateTicketStatusUseCase(
      UpdateTicketStatusParams(
        ticketId: currentTicket.id,
        status: newStatus,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isUpdatingStatus: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isUpdatingStatus: false,
        ticket: currentTicket.copyWith(status: newStatus),
        actionSuccessMessage: 'Ticket status updated to ${newStatus.displayName}',
      )),
    );
  }

  Future<void> updateCategory(TicketCategory newCategory) async {
    final currentTicket = state.ticket;
    if (currentTicket == null || currentTicket.category == newCategory) return;

    emit(state.copyWith(
      isUpdatingCategory: true,
      errorMessage: null,
      actionSuccessMessage: null,
    ));

    final result = await updateTicketCategoryUseCase(
      UpdateTicketCategoryParams(
        ticketId: currentTicket.id,
        category: newCategory,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isUpdatingCategory: false,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        isUpdatingCategory: false,
        ticket: currentTicket.copyWith(category: newCategory),
        actionSuccessMessage: 'Ticket category updated to ${newCategory.displayName}',
      )),
    );
  }

  Future<bool> sendReply(String body) async {
    final currentTicket = state.ticket;
    if (currentTicket == null || body.trim().isEmpty) return false;

    emit(state.copyWith(
      isSendingReply: true,
      errorMessage: null,
      actionSuccessMessage: null,
    ));

    final result = await sendAdminReplyUseCase(
      SendAdminReplyParams(
        ticketId: currentTicket.id,
        body: body.trim(),
      ),
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          isSendingReply: false,
          errorMessage: failure.message,
        ));
        return false;
      },
      (newReply) {
        final updatedMessages = [...currentTicket.messages, newReply];
        emit(state.copyWith(
          isSendingReply: false,
          ticket: currentTicket.copyWith(
            messages: updatedMessages,
            // If ticket was NEW or ESCALATED_TO_HUMAN, admin reply moves it to IN_PROGRESS
            status: (currentTicket.status == TicketStatus.NEW ||
                    currentTicket.status == TicketStatus.ESCALATED_TO_HUMAN)
                ? TicketStatus.IN_PROGRESS
                : currentTicket.status,
          ),
          actionSuccessMessage: 'Reply sent and customer notified via email.',
        ));
        return true;
      },
    );
  }
}
