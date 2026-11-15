package com.rajkumartimalsina.backend.ticket.repository;

import com.rajkumartimalsina.backend.ticket.entity.TicketEntity;
import com.rajkumartimalsina.backend.ticket.enums.TicketCategory;
import com.rajkumartimalsina.backend.ticket.enums.TicketStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TicketRepository extends JpaRepository<TicketEntity, UUID> {

    List<TicketEntity> findByStatus(TicketStatus status);

    List<TicketEntity> findByCategory(TicketCategory category);

    List<TicketEntity> findByCustomerId(UUID customerId);

    @Query("SELECT t FROM TicketEntity t JOIN FETCH t.customer ORDER BY t.updatedAt DESC")
    List<TicketEntity> findAllWithCustomerOrderByUpdatedAtDesc();

    @Query("SELECT t FROM TicketEntity t JOIN FETCH t.customer WHERE t.id = :id")
    Optional<TicketEntity> findByIdWithCustomer(UUID id);
}
