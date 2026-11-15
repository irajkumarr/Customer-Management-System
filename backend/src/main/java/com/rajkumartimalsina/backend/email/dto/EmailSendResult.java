package com.rajkumartimalsina.backend.email.dto;

public record EmailSendResult(
        boolean success,
        int statusCode,
        String messageId,
        String errorMessage
) {}
