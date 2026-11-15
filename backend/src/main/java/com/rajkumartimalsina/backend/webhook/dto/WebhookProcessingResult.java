package com.rajkumartimalsina.backend.webhook.dto;

import java.util.UUID;

public record WebhookProcessingResult(
        UUID ticketId,
        UUID messageId,
        boolean isNewTicket,
        boolean isDuplicate,
        String customerEmail
) {}
