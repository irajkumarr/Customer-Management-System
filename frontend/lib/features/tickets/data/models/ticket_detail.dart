import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/ticket_detail_entity.dart';
import 'customer.dart';
import 'message.dart';
import 'ticket_enums.dart';

part 'ticket_detail.freezed.dart';
part 'ticket_detail.g.dart';

@freezed
abstract class TicketDetail with _$TicketDetail {
  const factory TicketDetail({
    required String id,
    required Customer customer,
    required String subject,
    required TicketStatus status,
    required TicketCategory category,
    int? version,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<Message> messages,
  }) = _TicketDetail;

  factory TicketDetail.fromJson(Map<String, dynamic> json) => _$TicketDetailFromJson(json);
}

extension TicketDetailModelX on TicketDetail {
  TicketDetailEntity toEntity() => TicketDetailEntity(
        id: id,
        customer: customer.toEntity(),
        subject: subject,
        status: status,
        category: category,
        version: version,
        createdAt: createdAt,
        updatedAt: updatedAt,
        messages: messages.map((m) => m.toEntity()).toList(),
      );
}
