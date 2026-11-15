package com.rajkumartimalsina.backend.ticket.service;

import com.rajkumartimalsina.backend.common.exception.InvalidOperationException;
import com.rajkumartimalsina.backend.common.exception.ResourceNotFoundException;
import com.rajkumartimalsina.backend.customer.entity.CustomerEntity;
import com.rajkumartimalsina.backend.customer.repository.CustomerRepository;
import com.rajkumartimalsina.backend.customer.service.CustomerService;
import com.rajkumartimalsina.backend.message.dto.MessageResponse;
import com.rajkumartimalsina.backend.message.entity.MessageEntity;
import com.rajkumartimalsina.backend.message.enums.MessageSenderType;
import com.rajkumartimalsina.backend.message.repository.MessageRepository;
import com.rajkumartimalsina.backend.ticket.dto.*;
import com.rajkumartimalsina.backend.ticket.entity.TicketEntity;
import com.rajkumartimalsina.backend.ticket.enums.TicketCategory;
import com.rajkumartimalsina.backend.ticket.enums.TicketStatus;
import com.rajkumartimalsina.backend.ticket.repository.TicketRepository;
import com.rajkumartimalsina.backend.ticket.repository.TicketSpecification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class TicketService {

    private final TicketRepository ticketRepository;
    private final CustomerRepository customerRepository;
    private final CustomerService customerService;
    private final MessageRepository messageRepository;

    @Transactional(readOnly = true)
    public Page<TicketResponse> getTickets(
            TicketStatus status,
            TicketCategory category,
            UUID customerId,
            String search,
            Pageable pageable
    ) {
        Specification<TicketEntity> spec = TicketSpecification.withFilters(status, category, customerId, search);
        return ticketRepository.findAll(spec, pageable).map(TicketResponse::fromEntity);
    }

    @Transactional(readOnly = true)
    public TicketDetailResponse getTicketById(UUID id) {
        TicketEntity ticket = ticketRepository.findByIdWithCustomer(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket not found with id: " + id));

        List<MessageResponse> messages = messageRepository.findByTicketIdOrderByCreatedAtAsc(id)
                .stream()
                .map(MessageResponse::fromEntity)
                .toList();

        return TicketDetailResponse.fromEntity(ticket, messages);
    }

    @Transactional
    public TicketResponse createTicket(TicketCreateRequest request) {
        CustomerEntity customer;
        if (request.customerId() != null) {
            customer = customerRepository.findById(request.customerId())
                    .orElseThrow(() -> new ResourceNotFoundException("Customer not found with id: " + request.customerId()));
        } else if (request.customerEmail() != null && !request.customerEmail().isBlank()) {
            customer = customerService.findOrCreateCustomer(request.customerEmail(), request.customerName());
        } else {
            throw new InvalidOperationException("Either customerId or customerEmail must be provided.");
        }

        TicketCategory category = request.category() != null ? request.category() : TicketCategory.GENERAL;

        TicketEntity ticket = TicketEntity.builder()
                .customer(customer)
                .subject(request.subject().trim())
                .status(TicketStatus.NEW)
                .category(category)
                .build();

        TicketEntity savedTicket = ticketRepository.save(ticket);

        MessageEntity message = MessageEntity.builder()
                .ticket(savedTicket)
                .senderType(MessageSenderType.CUSTOMER)
                .body(request.initialMessage().trim())
                .isAiGenerated(false)
                .createdAt(Instant.now())
                .build();

        messageRepository.save(message);

        log.info("Ticket created manually with id '{}' for customer '{}'", savedTicket.getId(), customer.getEmail());
        return TicketResponse.fromEntity(savedTicket);
    }

    @Transactional
    public TicketResponse updateStatus(UUID id, TicketStatus newStatus) {
        TicketEntity ticket = ticketRepository.findByIdWithCustomer(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket not found with id: " + id));

        TicketLifecycleValidator.validateTransition(ticket.getStatus(), newStatus);

        log.info("Transitioning ticket '{}' status from '{}' to '{}'", id, ticket.getStatus(), newStatus);
        ticket.setStatus(newStatus);
        TicketEntity updated = ticketRepository.save(ticket);
        return TicketResponse.fromEntity(updated);
    }

    @Transactional
    public TicketResponse updateCategory(UUID id, TicketCategory newCategory) {
        TicketEntity ticket = ticketRepository.findByIdWithCustomer(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket not found with id: " + id));

        log.info("Updating ticket '{}' category from '{}' to '{}'", id, ticket.getCategory(), newCategory);
        ticket.setCategory(newCategory);
        TicketEntity updated = ticketRepository.save(ticket);
        return TicketResponse.fromEntity(updated);
    }

    @Transactional(readOnly = true)
    public TicketStatsResponse getTicketStats() {
        long total = ticketRepository.count();
        long newTickets = ticketRepository.countByStatus(TicketStatus.NEW);
        long aiProcessing = ticketRepository.countByStatus(TicketStatus.AI_PROCESSING);
        long aiReplied = ticketRepository.countByStatus(TicketStatus.AI_REPLIED);
        long escalatedToHuman = ticketRepository.countByStatus(TicketStatus.ESCALATED_TO_HUMAN);
        long inProgress = ticketRepository.countByStatus(TicketStatus.IN_PROGRESS);
        long resolved = ticketRepository.countByStatus(TicketStatus.RESOLVED);
        long closed = ticketRepository.countByStatus(TicketStatus.CLOSED);

        Map<String, Long> byCategory = new HashMap<>();
        for (TicketCategory category : TicketCategory.values()) {
            byCategory.put(category.name(), ticketRepository.countByCategory(category));
        }

        return new TicketStatsResponse(
                total,
                newTickets,
                aiProcessing,
                aiReplied,
                escalatedToHuman,
                inProgress,
                resolved,
                closed,
                byCategory
        );
    }

    @Transactional
    public TicketEntity createInboundTicket(CustomerEntity customer, String subject, String body, String inboundMessageId) {
        TicketEntity ticket = TicketEntity.builder()
                .customer(customer)
                .subject(subject != null && !subject.isBlank() ? subject.trim() : "No Subject")
                .status(TicketStatus.NEW)
                .category(TicketCategory.UNKNOWN)
                .build();

        TicketEntity saved = ticketRepository.save(ticket);

        MessageEntity message = MessageEntity.builder()
                .ticket(saved)
                .senderType(MessageSenderType.CUSTOMER)
                .body(body)
                .isAiGenerated(false)
                .inboundMessageId(inboundMessageId)
                .createdAt(Instant.now())
                .build();

        messageRepository.save(message);

        log.info("Created inbound ticket '{}' from customer '{}'", saved.getId(), customer.getEmail());
        return saved;
    }

    @Transactional
    public MessageEntity appendCustomerMessage(TicketEntity ticket, String body, String inboundMessageId) {
        // If customer replies to an AI_REPLIED ticket, escalate to human
        if (ticket.getStatus() == TicketStatus.AI_REPLIED) {
            log.info("Customer replied to ticket '{}' with status AI_REPLIED. Escalating to ESCALATED_TO_HUMAN.", ticket.getId());
            ticket.setStatus(TicketStatus.ESCALATED_TO_HUMAN);
            ticketRepository.save(ticket);
        }

        MessageEntity message = MessageEntity.builder()
                .ticket(ticket)
                .senderType(MessageSenderType.CUSTOMER)
                .body(body)
                .isAiGenerated(false)
                .inboundMessageId(inboundMessageId)
                .createdAt(Instant.now())
                .build();

        return messageRepository.save(message);
    }

    @Transactional
    public MessageEntity appendAdminMessage(UUID ticketId, String body) {
        TicketEntity ticket = ticketRepository.findByIdWithCustomer(ticketId)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket not found with id: " + ticketId));

        if (ticket.getStatus() == TicketStatus.ESCALATED_TO_HUMAN || ticket.getStatus() == TicketStatus.NEW) {
            ticket.setStatus(TicketStatus.IN_PROGRESS);
            ticketRepository.save(ticket);
        }

        MessageEntity message = MessageEntity.builder()
                .ticket(ticket)
                .senderType(MessageSenderType.ADMIN)
                .body(body)
                .isAiGenerated(false)
                .createdAt(Instant.now())
                .build();

        return messageRepository.save(message);
    }
}
