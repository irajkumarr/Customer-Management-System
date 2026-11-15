package com.rajkumartimalsina.backend.customer.dto;

import jakarta.validation.constraints.Size;

public record CustomerUpdateRequest(
        @Size(max = 255, message = "Name must not exceed 255 characters")
        String name
) {}
