package com.rajkumartimalsina.backend.message.dto;

import jakarta.validation.constraints.NotBlank;

public record MessageCreateRequest(
        @NotBlank(message = "Message body cannot be blank")
        String body,

        boolean resolveTicket
) {}
