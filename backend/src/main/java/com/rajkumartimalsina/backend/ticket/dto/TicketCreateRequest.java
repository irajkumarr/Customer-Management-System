package com.rajkumartimalsina.backend.ticket.dto;

import com.rajkumartimalsina.backend.ticket.enums.TicketCategory;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public record TicketCreateRequest(
        UUID customerId,

        @Email(message = "Customer email must be valid")
        String customerEmail,

        String customerName,

        @NotBlank(message = "Subject is required")
        @Size(max = 500, message = "Subject must not exceed 500 characters")
        String subject,

        @NotBlank(message = "Initial message body is required")
        String initialMessage,

        TicketCategory category
) {}
