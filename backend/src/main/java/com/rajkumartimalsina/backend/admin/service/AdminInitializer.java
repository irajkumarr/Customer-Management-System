package com.rajkumartimalsina.backend.admin.service;

import com.rajkumartimalsina.backend.admin.entity.AdminEntity;
import com.rajkumartimalsina.backend.admin.enums.AdminRole;
import com.rajkumartimalsina.backend.admin.repository.AdminRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
@RequiredArgsConstructor
@Slf4j
public class AdminInitializer implements CommandLineRunner {

    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.admin.initial-username:admin}")
    private String initialUsername;

    @Value("${app.admin.initial-password:Admin@123456}")
    private String initialPassword;

    @Override
    public void run(String... args) {
        if (adminRepository.count() == 0) {
            log.info("No admin user found. Creating initial admin user '{}'", initialUsername);
            AdminEntity admin = AdminEntity.builder()
                    .username(initialUsername)
                    .passwordHash(passwordEncoder.encode(initialPassword))
                    .role(AdminRole.ADMIN)
                    .createdAt(Instant.now())
                    .build();
            adminRepository.save(admin);
            log.info("Initial admin user '{}' created successfully.", initialUsername);
        } else {
            log.info("Admin user already exists. Skipping admin initialization.");
        }
    }
}
