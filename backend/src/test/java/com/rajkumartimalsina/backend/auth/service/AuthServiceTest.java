package com.rajkumartimalsina.backend.auth.service;

import com.rajkumartimalsina.backend.admin.entity.AdminEntity;
import com.rajkumartimalsina.backend.admin.enums.AdminRole;
import com.rajkumartimalsina.backend.admin.repository.AdminRepository;
import com.rajkumartimalsina.backend.auth.dto.AdminProfileResponse;
import com.rajkumartimalsina.backend.auth.dto.LoginRequest;
import com.rajkumartimalsina.backend.auth.dto.SessionStatusResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.context.SecurityContextRepository;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private AuthenticationManager authenticationManager;

    @Mock
    private AdminRepository adminRepository;

    @Mock
    private SecurityContextRepository securityContextRepository;

    @Mock
    private HttpServletRequest httpRequest;

    @Mock
    private HttpServletResponse httpResponse;

    @Mock
    private Authentication authentication;

    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService(authenticationManager, adminRepository, securityContextRepository);
    }

    @Test
    void login_Successful_ReturnsProfile() {
        UUID adminId = UUID.randomUUID();
        AdminEntity admin = AdminEntity.builder()
                .id(adminId)
                .username("admin")
                .passwordHash("hashed")
                .role(AdminRole.ADMIN)
                .createdAt(Instant.now())
                .build();

        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenReturn(authentication);
        when(adminRepository.findByUsername("admin")).thenReturn(Optional.of(admin));

        LoginRequest request = new LoginRequest("admin", "secret");
        AdminProfileResponse response = authService.login(request, httpRequest, httpResponse);

        assertNotNull(response);
        assertEquals(adminId, response.id());
        assertEquals("admin", response.username());
        assertEquals(AdminRole.ADMIN, response.role());

        verify(securityContextRepository, times(1)).saveContext(any(), eq(httpRequest), eq(httpResponse));
    }

    @Test
    void getSessionStatus_Authenticated_ReturnsActiveStatus() {
        UUID adminId = UUID.randomUUID();
        AdminEntity admin = AdminEntity.builder()
                .id(adminId)
                .username("admin")
                .passwordHash("hashed")
                .role(AdminRole.ADMIN)
                .createdAt(Instant.now())
                .build();

        when(authentication.isAuthenticated()).thenReturn(true);
        when(authentication.getName()).thenReturn("admin");
        when(adminRepository.findByUsername("admin")).thenReturn(Optional.of(admin));

        SessionStatusResponse status = authService.getSessionStatus(authentication);

        assertTrue(status.authenticated());
        assertNotNull(status.admin());
        assertEquals("admin", status.admin().username());
    }

    @Test
    void getSessionStatus_Unauthenticated_ReturnsFalse() {
        SessionStatusResponse status = authService.getSessionStatus(null);
        assertFalse(status.authenticated());
        assertNull(status.admin());
    }
}
