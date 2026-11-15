package com.rajkumartimalsina.backend.auth.dto;

import com.rajkumartimalsina.backend.admin.enums.AdminRole;

import java.util.UUID;

public record AdminProfileResponse(
        UUID id,
        String username,
        AdminRole role
) {}
