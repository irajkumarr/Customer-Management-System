package com.rajkumartimalsina.backend.customer.dto;

import com.rajkumartimalsina.backend.customer.entity.CustomerEntity;

import java.time.Instant;
import java.util.UUID;

public record CustomerResponse(
        UUID id,
        String email,
        String name,
        Instant createdAt,
        Instant updatedAt
) {
    public static CustomerResponse fromEntity(CustomerEntity entity) {
        return new CustomerResponse(
                entity.getId(),
                entity.getEmail(),
                entity.getName(),
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }
}
