package com.rajkumartimalsina.backend.webhook.service;

import com.rajkumartimalsina.backend.ai.service.TicketAiProcessingService;
import com.rajkumartimalsina.backend.customer.entity.CustomerEntity;
import com.rajkumartimalsina.backend.customer.service.CustomerService;
import com.rajkumartimalsina.backend.message.entity.MessageEntity;
import com.rajkumartimalsina.backend.message.repository.MessageRepository;
import com.rajkumartimalsina.backend.ticket.entity.TicketEntity;
import com.rajkumartimalsina.backend.ticket.repository.TicketRepository;
import com.rajkumartimalsina.backend.ticket.service.TicketService;
import com.rajkumartimalsina.backend.webhook.dto.InboundEmailPayload;
import com.rajkumartimalsina.backend.webhook.dto.ParsedEmailHeaders;
import com.rajkumartimalsina.backend.webhook.dto.ParsedEmailSender;
import com.rajkumartimalsina.backend.webhook.dto.WebhookProcessingResult;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
@Slf4j
public class SendGridInboundService {

    private static final Pattern TICKET_ID_SUBJECT_PATTERN = Pattern.compile("\\[(?:Ticket\\s*#|#)([a-f0-9\\-]{36})\\]", Pattern.CASE_INSENSITIVE);

    private final EmailHeaderParser headerParser;
    private final MessageRepository messageRepository;
    private final TicketRepository ticketRepository;
    private final TicketService ticketService;
    private final CustomerService customerService;
    private final TicketAiProcessingService ticketAiProcessingService;

    @Transactional
    public WebhookProcessingResult processInboundEmail(InboundEmailPayload payload) {
        ParsedEmailHeaders headers = headerParser.extractHeaders(payload.headers());

        // Extract sender
        String fromHeader = headers.from() != null && !headers.from().isBlank() ? headers.from() : payload.from();
        ParsedEmailSender sender = headerParser.parseSender(fromHeader);

        // Deduplication: prevent processing duplicate inbound messages
        String messageId = headers.messageId();
        if (messageId != null && messageRepository.findByInboundMessageId(messageId).isPresent()) {
            log.warn("Duplicate inbound message detected with Message-ID: '{}'. Skipping.", messageId);
            MessageEntity existing = messageRepository.findByInboundMessageId(messageId).get();
            return new WebhookProcessingResult(
                    existing.getTicket().getId(),
                    existing.getId(),
                    false,
                    true,
                    sender.email()
            );
        }

        // Determine plain text body content
        String body = resolveBody(payload.text(), payload.html());
        String subject = headers.subject() != null && !headers.subject().isBlank() ? headers.subject() : payload.subject();
        if (subject == null || subject.isBlank()) {
            subject = "No Subject";
        }

        // Thread matching
        Optional<TicketEntity> matchedTicket = findMatchingTicket(headers, subject);

        if (matchedTicket.isPresent()) {
            TicketEntity ticket = matchedTicket.get();
            log.info("Found existing ticket '{}' for reply with Message-ID '{}'", ticket.getId(), messageId);
            MessageEntity appended = ticketService.appendCustomerMessage(ticket, body, messageId);
            return new WebhookProcessingResult(ticket.getId(), appended.getId(), false, false, sender.email());
        }

        // No matching thread: Create new ticket and customer if needed
        CustomerEntity customer = customerService.findOrCreateCustomer(sender.email(), sender.name());
        TicketEntity newTicket = ticketService.createInboundTicket(customer, subject, body, messageId);

        // Dispatch asynchronous AI RAG processing
        ticketAiProcessingService.processTicketWithAiAsync(newTicket.getId());

        return new WebhookProcessingResult(
                newTicket.getId(),
                newTicket.getMessages().isEmpty() ? null : newTicket.getMessages().get(0).getId(),
                true,
                false,
                customer.getEmail()
        );
    }

    private Optional<TicketEntity> findMatchingTicket(ParsedEmailHeaders headers, String subject) {
        // 1. Try In-Reply-To header
        if (headers.inReplyTo() != null && !headers.inReplyTo().isBlank()) {
            Optional<MessageEntity> parentMessage = messageRepository.findByInboundMessageId(headers.inReplyTo());
            if (parentMessage.isPresent()) {
                return Optional.of(parentMessage.get().getTicket());
            }
        }

        // 2. Try References headers (traverse in reverse to find closest ancestor)
        if (headers.references() != null && !headers.references().isEmpty()) {
            for (int i = headers.references().size() - 1; i >= 0; i--) {
                String refId = headers.references().get(i);
                Optional<MessageEntity> refMessage = messageRepository.findByInboundMessageId(refId);
                if (refMessage.isPresent()) {
                    return Optional.of(refMessage.get().getTicket());
                }
            }
        }

        // 3. Fallback: Parse ticket UUID in Subject line, e.g. "Re: [Ticket #123e4567-e89b-12d3-a456-426614174000]"
        if (subject != null) {
            Matcher matcher = TICKET_ID_SUBJECT_PATTERN.matcher(subject);
            if (matcher.find()) {
                try {
                    UUID ticketId = UUID.fromString(matcher.group(1));
                    return ticketRepository.findById(ticketId);
                } catch (IllegalArgumentException ignored) {
                }
            }
        }

        return Optional.empty();
    }

    private String resolveBody(String text, String html) {
        if (text != null && !text.isBlank()) {
            return text.trim();
        }
        if (html != null && !html.isBlank()) {
            // Basic HTML strip to plain text
            return html
                    .replaceAll("<[^>]*>", "")
                    .replace("&nbsp;", " ")
                    .replace("&amp;", "&")
                    .replace("&lt;", "<")
                    .replace("&gt;", ">")
                    .trim();
        }
        return "(empty message)";
    }
}
