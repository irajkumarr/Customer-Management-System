package com.rajkumartimalsina.backend.ticket.dto;

import com.rajkumartimalsina.backend.customer.dto.CustomerResponse;
import com.rajkumartimalsina.backend.message.dto.MessageResponse;
import com.rajkumartimalsina.backend.ticket.entity.TicketEntity;
import com.rajkumartimalsina.backend.ticket.enums.TicketCategory;
import com.rajkumartimalsina.backend.ticket.enums.TicketStatus;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record TicketDetailResponse(
        UUID id,
        CustomerResponse customer,
        String subject,
        TicketStatus status,
        TicketCategory category,
        Long version,
        Instant createdAt,
        Instant updatedAt,
        List<MessageResponse> messages
) {
    public static TicketDetailResponse fromEntity(TicketEntity ticket, List<MessageResponse> messages) {
        return new TicketDetailResponse(
                ticket.getId(),
                CustomerResponse.fromEntity(ticket.getCustomer()),
                ticket.getSubject(),
                ticket.getStatus(),
                ticket.getCategory(),
                ticket.getVersion(),
                ticket.getCreatedAt(),
                ticket.getUpdatedAt(),
                messages
        );
    }
}
