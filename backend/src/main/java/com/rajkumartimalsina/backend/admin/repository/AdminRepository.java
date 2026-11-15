package com.rajkumartimalsina.backend.admin.repository;

import com.rajkumartimalsina.backend.admin.entity.AdminEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface AdminRepository extends JpaRepository<AdminEntity, UUID> {
    Optional<AdminEntity> findByUsername(String username);
    boolean existsByUsername(String username);
}
