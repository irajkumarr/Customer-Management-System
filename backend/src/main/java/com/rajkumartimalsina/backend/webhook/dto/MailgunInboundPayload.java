package com.rajkumartimalsina.backend.webhook.dto;

public record MailgunInboundPayload(
        String from,
        String sender,
        String recipient,
        String to,
        String subject,
        String bodyPlain,
        String strippedText,
        String bodyHtml,
        String strippedHtml,
        String messageHeaders,
        String messageId,
        String inReplyTo,
        String references,
        String timestamp,
        String token,
        String signature
) {}
