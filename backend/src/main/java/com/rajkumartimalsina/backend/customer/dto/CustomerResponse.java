package com.rajkumartimalsina.backend.customer.dto;

import java.time.Instant;
import java.util.UUID;

public record CustomerResponse(
        UUID id,
        String email,
        String name,
        Instant createdAt
) {}
