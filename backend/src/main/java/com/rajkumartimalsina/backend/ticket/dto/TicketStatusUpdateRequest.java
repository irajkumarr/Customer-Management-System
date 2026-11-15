package com.rajkumartimalsina.backend.ticket.dto;

import com.rajkumartimalsina.backend.ticket.enums.TicketStatus;
import jakarta.validation.constraints.NotNull;

public record TicketStatusUpdateRequest(
        @NotNull(message = "Status is required")
        TicketStatus status
) {}
