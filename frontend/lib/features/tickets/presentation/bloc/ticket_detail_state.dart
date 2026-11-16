import 'package:equatable/equatable.dart';
import '../../domain/entities/ticket_detail_entity.dart';

enum TicketDetailStatus { initial, loading, refreshing, success, failure }

class TicketDetailState extends Equatable {
  final TicketDetailStatus status;
  final TicketDetailEntity? ticket;
  final bool isSendingReply;
  final bool isUpdatingStatus;
  final bool isUpdatingCategory;
  final String? errorMessage;
  final String? actionSuccessMessage;

  const TicketDetailState({
    this.status = TicketDetailStatus.initial,
    this.ticket,
    this.isSendingReply = false,
    this.isUpdatingStatus = false,
    this.isUpdatingCategory = false,
    this.errorMessage,
    this.actionSuccessMessage,
  });

  bool get isLoading => status == TicketDetailStatus.loading;
  bool get isRefreshing => status == TicketDetailStatus.refreshing;
  bool get hasError => status == TicketDetailStatus.failure;

  TicketDetailState copyWith({
    TicketDetailStatus? status,
    TicketDetailEntity? ticket,
    bool? isSendingReply,
    bool? isUpdatingStatus,
    bool? isUpdatingCategory,
    String? errorMessage,
    String? actionSuccessMessage,
  }) {
    return TicketDetailState(
      status: status ?? this.status,
      ticket: ticket ?? this.ticket,
      isSendingReply: isSendingReply ?? this.isSendingReply,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
      isUpdatingCategory: isUpdatingCategory ?? this.isUpdatingCategory,
      errorMessage: errorMessage ?? this.errorMessage,
      actionSuccessMessage: actionSuccessMessage ?? this.actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        ticket,
        isSendingReply,
        isUpdatingStatus,
        isUpdatingCategory,
        errorMessage,
        actionSuccessMessage,
      ];
}
