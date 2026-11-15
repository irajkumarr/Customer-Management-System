package com.rajkumartimalsina.backend.ticket.dto;

import com.rajkumartimalsina.backend.ticket.enums.TicketCategory;
import jakarta.validation.constraints.NotNull;

public record TicketCategoryUpdateRequest(
        @NotNull(message = "Category is required")
        TicketCategory category
) {}
