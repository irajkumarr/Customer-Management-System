package com.rajkumartimalsina.backend.ai.dto;

public record AiAgentResponse(
        String replyText,
        boolean requiresHuman,
        String escalationReason,
        String category
) {}
