package com.rajkumartimalsina.backend.message.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;

public record MessageCreateRequest(
        @NotBlank(message = "Message body cannot be blank")
        String body,

        @JsonProperty("resolveTicket")
        Boolean resolveTicket
) {
    public MessageCreateRequest {
        if (resolveTicket == null) {
            resolveTicket = false;
        }
    }

    public MessageCreateRequest(String body) {
        this(body, false);
    }
}
