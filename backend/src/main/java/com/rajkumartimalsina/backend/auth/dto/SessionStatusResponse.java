package com.rajkumartimalsina.backend.auth.dto;

public record SessionStatusResponse(
        boolean authenticated,
        AdminProfileResponse admin
) {}
