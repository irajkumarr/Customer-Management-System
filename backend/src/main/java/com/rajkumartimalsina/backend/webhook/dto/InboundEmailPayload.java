package com.rajkumartimalsina.backend.webhook.dto;

public record InboundEmailPayload(
        String from,
        String to,
        String subject,
        String text,
        String html,
        String headers,
        String envelope
) {}
