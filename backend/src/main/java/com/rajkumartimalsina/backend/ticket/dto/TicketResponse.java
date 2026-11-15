package com.rajkumartimalsina.backend.ticket.dto;

import com.rajkumartimalsina.backend.ticket.entity.TicketEntity;
import com.rajkumartimalsina.backend.ticket.enums.TicketCategory;
import com.rajkumartimalsina.backend.ticket.enums.TicketStatus;

import java.time.Instant;
import java.util.UUID;

public record TicketResponse(
        UUID id,
        UUID customerId,
        String customerEmail,
        String customerName,
        String subject,
        TicketStatus status,
        TicketCategory category,
        Instant createdAt,
        Instant updatedAt
) {
    public static TicketResponse fromEntity(TicketEntity entity) {
        return new TicketResponse(
                entity.getId(),
                entity.getCustomer().getId(),
                entity.getCustomer().getEmail(),
                entity.getCustomer().getName(),
                entity.getSubject(),
                entity.getStatus(),
                entity.getCategory(),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }
}
