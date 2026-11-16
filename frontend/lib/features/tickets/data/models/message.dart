import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/message_entity.dart';
import 'ticket_enums.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String ticketId,
    required MessageSenderType senderType,
    required String body,
    required bool isAiGenerated,
    required DateTime createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}

extension MessageModelX on Message {
  MessageEntity toEntity() => MessageEntity(
        id: id,
        ticketId: ticketId,
        senderType: senderType,
        body: body,
        isAiGenerated: isAiGenerated,
        createdAt: createdAt,
      );
}
