package com.rajkumartimalsina.backend.auth.controller;

import com.rajkumartimalsina.backend.auth.dto.AdminProfileResponse;
import com.rajkumartimalsina.backend.auth.dto.LoginRequest;
import com.rajkumartimalsina.backend.auth.dto.SessionStatusResponse;
import com.rajkumartimalsina.backend.auth.service.AuthService;
import com.rajkumartimalsina.backend.common.response.ApiResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AdminProfileResponse>> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest httpRequest,
            HttpServletResponse httpResponse
    ) {
        AdminProfileResponse profile = authService.login(request, httpRequest, httpResponse);
        return ResponseEntity.ok(ApiResponse.success("Login successful", profile));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<AdminProfileResponse>> me(Authentication authentication) {
        AdminProfileResponse profile = authService.getCurrentAdmin(authentication);
        return ResponseEntity.ok(ApiResponse.success("Admin profile fetched", profile));
    }

    @GetMapping("/status")
    public ResponseEntity<ApiResponse<SessionStatusResponse>> status(Authentication authentication) {
        SessionStatusResponse status = authService.getSessionStatus(authentication);
        return ResponseEntity.ok(ApiResponse.success(status));
    }
}
