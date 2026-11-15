package com.rajkumartimalsina.backend.email.dto;

import java.util.List;

public record EmailSendRequest(
        String to,
        String subject,
        String markdownBody,
        String inReplyTo,
        List<String> references
) {}
