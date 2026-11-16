import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/ticket_entity.dart';
import 'ticket_enums.dart';

part 'ticket.freezed.dart';
part 'ticket.g.dart';

@freezed
abstract class Ticket with _$Ticket {
  const factory Ticket({
    required String id,
    required String customerId,
    required String customerEmail,
    String? customerName,
    required String subject,
    required TicketStatus status,
    required TicketCategory category,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Ticket;

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
}

extension TicketModelX on Ticket {
  TicketEntity toEntity() => TicketEntity(
        id: id,
        customerId: customerId,
        customerEmail: customerEmail,
        customerName: customerName,
        subject: subject,
        status: status,
        category: category,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
