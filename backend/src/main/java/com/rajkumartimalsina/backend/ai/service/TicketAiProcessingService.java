package com.rajkumartimalsina.backend.ai.service;

import com.rajkumartimalsina.backend.ai.dto.AiAgentResponse;
import com.rajkumartimalsina.backend.common.exception.ResourceNotFoundException;
import com.rajkumartimalsina.backend.email.dto.EmailSendRequest;
import com.rajkumartimalsina.backend.email.dto.EmailSendResult;
import com.rajkumartimalsina.backend.email.service.EmailService;
import com.rajkumartimalsina.backend.message.entity.MessageEntity;
import com.rajkumartimalsina.backend.message.enums.MessageSenderType;
import com.rajkumartimalsina.backend.message.repository.MessageRepository;
import com.rajkumartimalsina.backend.ticket.entity.TicketEntity;
import com.rajkumartimalsina.backend.ticket.enums.TicketCategory;
import com.rajkumartimalsina.backend.ticket.enums.TicketStatus;
import com.rajkumartimalsina.backend.ticket.repository.TicketRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class TicketAiProcessingService {

    private final TicketRepository ticketRepository;
    private final MessageRepository messageRepository;
    private final AiHelpdeskService aiHelpdeskService;
    private final EmailService emailService;
    private final TransactionTemplate transactionTemplate;

    @Async
    public void processTicketWithAiAsync(UUID ticketId) {
        try {
            transactionTemplate.executeWithoutResult(status -> processTicket(ticketId));
        } catch (Exception e) {
            log.error("Failed to process ticket '{}' with AI: {}", ticketId, e.getMessage(), e);
        }
    }

    public void processTicket(UUID ticketId) {
        TicketEntity ticket = null;
        for (int attempt = 1; attempt <= 3; attempt++) {
            var found = ticketRepository.findByIdWithCustomer(ticketId);
            if (found.isPresent()) {
                ticket = found.get();
                break;
            }
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }

        if (ticket == null) {
            throw new ResourceNotFoundException("Ticket not found: " + ticketId);
        }

        String customerEmail = ticket.getCustomer() != null ? ticket.getCustomer().getEmail() : "unknown@example.com";

        List<MessageEntity> messages = messageRepository.findByTicketIdOrderByCreatedAtAsc(ticketId);
        if (messages.isEmpty()) {
            log.warn("No messages found for ticket '{}'. Skipping AI processing.", ticketId);
            return;
        }

        // The latest customer message to reply to
        MessageEntity latestCustomerMessage = messages.stream()
                .filter(m -> m.getSenderType() == MessageSenderType.CUSTOMER)
                .reduce((first, second) -> second)
                .orElse(messages.get(0));

        log.info("Starting AI RAG pipeline for ticket '{}' (subject: '{}')", ticketId, ticket.getSubject());

        // Step 1: Call Gemini AI RAG
        AiAgentResponse aiResponse = aiHelpdeskService.analyzeAndGenerateReply(
                ticket.getSubject(),
                latestCustomerMessage.getBody()
        );

        // Step 2: Update Category
        TicketCategory parsedCategory = parseCategory(aiResponse.category());
        ticket.setCategory(parsedCategory);

        // Step 3: Determine next status
        TicketStatus targetStatus;
        if (aiResponse.requiresHuman()) {
            targetStatus = TicketStatus.ESCALATED_TO_HUMAN;
            log.info("Ticket '{}' escalated to human. Reason: {}", ticketId, aiResponse.escalationReason());
        } else {
            targetStatus = TicketStatus.AI_REPLIED;
            log.info("Ticket '{}' auto-replied by AI.", ticketId);
        }
        ticket.setStatus(targetStatus);
        ticket = ticketRepository.save(ticket);

        // Step 5: Save AI message in thread
        MessageEntity aiMessage = MessageEntity.builder()
                .ticket(ticket)
                .senderType(MessageSenderType.AI)
                .body(aiResponse.replyText())
                .isAiGenerated(true)
                .createdAt(Instant.now())
                .build();
        messageRepository.save(aiMessage);

        // Step 6: Dispatch outbound email to customer
        String subject = "Re: [Ticket #" + ticket.getId() + "] " + ticket.getSubject();
        String inReplyTo = latestCustomerMessage.getInboundMessageId();
        List<String> references = inReplyTo != null ? List.of(inReplyTo) : List.of();

        EmailSendRequest emailRequest = new EmailSendRequest(
                customerEmail,
                subject,
                aiResponse.replyText(),
                inReplyTo,
                references
        );

        EmailSendResult sendResult = emailService.sendEmail(emailRequest);
        if (sendResult.success()) {
            log.info("Outbound email dispatched successfully for ticket '{}' to '{}' (Message-ID: {})",
                    ticketId, customerEmail, sendResult.messageId());
        } else {
            log.error("Outbound email delivery failed for ticket '{}' to '{}': {}",
                    ticketId, customerEmail, sendResult.errorMessage());
        }
    }

    private TicketCategory parseCategory(String categoryStr) {
        if (categoryStr == null || categoryStr.isBlank()) {
            return TicketCategory.UNKNOWN;
        }
        try {
            return TicketCategory.valueOf(categoryStr.toUpperCase().trim());
        } catch (IllegalArgumentException e) {
            return TicketCategory.UNKNOWN;
        }
    }
}
