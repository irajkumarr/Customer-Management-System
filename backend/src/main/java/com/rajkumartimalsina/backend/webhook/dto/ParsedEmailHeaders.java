package com.rajkumartimalsina.backend.webhook.dto;

import java.util.List;

public record ParsedEmailHeaders(
        String messageId,
        String inReplyTo,
        List<String> references,
        String subject,
        String from
) {}
