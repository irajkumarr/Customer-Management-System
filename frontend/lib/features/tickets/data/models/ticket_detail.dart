import 'package:freezed_annotation/freezed_annotation.dart';
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
