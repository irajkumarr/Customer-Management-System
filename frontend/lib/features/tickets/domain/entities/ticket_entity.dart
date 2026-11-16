import 'package:equatable/equatable.dart';
import '../../data/models/ticket_enums.dart';

class TicketEntity extends Equatable {
  final String id;
  final String customerId;
  final String customerEmail;
  final String? customerName;
  final String subject;
  final TicketStatus status;
  final TicketCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TicketEntity({
    required this.id,
    required this.customerId,
    required this.customerEmail,
    this.customerName,
    required this.subject,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerEmail,
        customerName,
        subject,
        status,
        category,
        createdAt,
        updatedAt,
      ];
}
