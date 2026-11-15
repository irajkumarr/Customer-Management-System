package com.rajkumartimalsina.backend.message.dto;

import com.rajkumartimalsina.backend.message.entity.MessageEntity;
import com.rajkumartimalsina.backend.message.enums.MessageSenderType;

import java.time.Instant;
import java.util.UUID;

public record MessageResponse(
        UUID id,
        UUID ticketId,
        MessageSenderType senderType,
        String body,
        boolean isAiGenerated,
        Instant createdAt
) {
    public static MessageResponse fromEntity(MessageEntity entity) {
        return new MessageResponse(
                entity.getId(),
                entity.getTicket().getId(),
                entity.getSenderType(),
                entity.getBody(),
                entity.isAiGenerated(),
                entity.getCreatedAt()
        );
    }
}
