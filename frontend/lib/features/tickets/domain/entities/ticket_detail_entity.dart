import 'package:equatable/equatable.dart';
import '../../data/models/ticket_enums.dart';
import 'customer_entity.dart';
import 'message_entity.dart';

class TicketDetailEntity extends Equatable {
  final String id;
  final CustomerEntity customer;
  final String subject;
  final TicketStatus status;
  final TicketCategory category;
  final int? version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MessageEntity> messages;

  const TicketDetailEntity({
    required this.id,
    required this.customer,
    required this.subject,
    required this.status,
    required this.category,
    this.version,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });

  TicketDetailEntity copyWith({
    String? id,
    CustomerEntity? customer,
    String? subject,
    TicketStatus? status,
    TicketCategory? category,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MessageEntity>? messages,
  }) {
    return TicketDetailEntity(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      category: category ?? this.category,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customer,
        subject,
        status,
        category,
        version,
        createdAt,
        updatedAt,
        messages,
      ];
}
