import 'package:equatable/equatable.dart';
import '../../data/models/ticket_enums.dart';

class MessageEntity extends Equatable {
  final String id;
  final String ticketId;
  final MessageSenderType senderType;
  final String body;
  final bool isAiGenerated;
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    required this.ticketId,
    required this.senderType,
    required this.body,
    required this.isAiGenerated,
    required this.createdAt,
  });

  bool get isFromCustomer => senderType == MessageSenderType.CUSTOMER;
  bool get isFromAi => senderType == MessageSenderType.AI;
  bool get isFromAdmin => senderType == MessageSenderType.ADMIN;

  @override
  List<Object?> get props => [
        id,
        ticketId,
        senderType,
        body,
        isAiGenerated,
        createdAt,
      ];
}
