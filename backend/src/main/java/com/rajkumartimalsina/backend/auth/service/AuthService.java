package com.rajkumartimalsina.backend.auth.service;

import com.rajkumartimalsina.backend.admin.entity.AdminEntity;
import com.rajkumartimalsina.backend.admin.repository.AdminRepository;
import com.rajkumartimalsina.backend.auth.dto.AdminProfileResponse;
import com.rajkumartimalsina.backend.auth.dto.LoginRequest;
import com.rajkumartimalsina.backend.auth.dto.SessionStatusResponse;
import com.rajkumartimalsina.backend.common.exception.ResourceNotFoundException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final AdminRepository adminRepository;
    private final SecurityContextRepository securityContextRepository;

    public AdminProfileResponse login(LoginRequest request, HttpServletRequest httpRequest, HttpServletResponse httpResponse) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.username(), request.password())
        );

        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(authentication);
        SecurityContextHolder.setContext(context);
        securityContextRepository.saveContext(context, httpRequest, httpResponse);

        AdminEntity admin = adminRepository.findByUsername(request.username())
                .orElseThrow(() -> new ResourceNotFoundException("Admin not found: " + request.username()));

        log.info("Admin '{}' logged in successfully with session.", admin.getUsername());
        return new AdminProfileResponse(admin.getId(), admin.getUsername(), admin.getRole());
    }

    public AdminProfileResponse getCurrentAdmin(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new ResourceNotFoundException("No authenticated admin session found.");
        }

        String username = authentication.getName();
        AdminEntity admin = adminRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("Admin not found: " + username));

        return new AdminProfileResponse(admin.getId(), admin.getUsername(), admin.getRole());
    }

    public SessionStatusResponse getSessionStatus(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated() || "anonymousUser".equals(authentication.getName())) {
            return new SessionStatusResponse(false, null);
        }

        return adminRepository.findByUsername(authentication.getName())
                .map(admin -> new SessionStatusResponse(true, new AdminProfileResponse(admin.getId(), admin.getUsername(), admin.getRole())))
                .orElseGet(() -> new SessionStatusResponse(false, null));
    }
}
