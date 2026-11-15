package com.rajkumartimalsina.backend.webhook.controller;

import com.rajkumartimalsina.backend.common.response.ApiResponse;
import com.rajkumartimalsina.backend.webhook.dto.MailgunInboundPayload;
import com.rajkumartimalsina.backend.webhook.dto.WebhookProcessingResult;
import com.rajkumartimalsina.backend.webhook.security.MailgunSignatureVerifier;
import com.rajkumartimalsina.backend.webhook.service.MailgunInboundService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/webhooks")
@RequiredArgsConstructor
@Slf4j
public class MailgunWebhookController {

    private final MailgunSignatureVerifier signatureVerifier;
    private final MailgunInboundService inboundService;

    @PostMapping(
            value = "/mailgun",
            consumes = {MediaType.MULTIPART_FORM_DATA_VALUE, MediaType.APPLICATION_FORM_URLENCODED_VALUE}
    )
    public ResponseEntity<ApiResponse<WebhookProcessingResult>> handleMailgunInbound(
            @RequestParam(value = "from", required = false) String from,
            @RequestParam(value = "sender", required = false) String sender,
            @RequestParam(value = "recipient", required = false) String recipient,
            @RequestParam(value = "to", required = false) String to,
            @RequestParam(value = "subject", required = false) String subject,
            @RequestParam(value = "body-plain", required = false) String bodyPlain,
            @RequestParam(value = "stripped-text", required = false) String strippedText,
            @RequestParam(value = "body-html", required = false) String bodyHtml,
            @RequestParam(value = "stripped-html", required = false) String strippedHtml,
            @RequestParam(value = "message-headers", required = false) String messageHeaders,
            @RequestParam(value = "Message-Id", required = false) String messageId,
            @RequestParam(value = "In-Reply-To", required = false) String inReplyTo,
            @RequestParam(value = "References", required = false) String references,
            @RequestParam(value = "timestamp", required = false) String timestamp,
            @RequestParam(value = "token", required = false) String token,
            @RequestParam(value = "signature", required = false) String signature
    ) {
        log.info("Received Mailgun inbound webhook from: '{}' (sender: '{}'), subject: '{}'",
                from, sender, subject);

        // Verify HMAC-SHA256 signature if configured
        if (signatureVerifier.isVerificationEnabled()) {
            boolean verified = signatureVerifier.verify(timestamp, token, signature);
            if (!verified) {
                log.warn("Mailgun inbound webhook signature verification rejected.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(ApiResponse.error("Invalid webhook signature."));
            }
        }

        MailgunInboundPayload payload = new MailgunInboundPayload(
                from,
                sender,
                recipient,
                to,
                subject,
                bodyPlain,
                strippedText,
                bodyHtml,
                strippedHtml,
                messageHeaders,
                messageId,
                inReplyTo,
                references,
                timestamp,
                token,
                signature
        );

        WebhookProcessingResult result = inboundService.processInboundEmail(payload);

        log.info("Mailgun inbound email processed successfully: ticketId={}, isNewTicket={}, isDuplicate={}",
                result.ticketId(), result.isNewTicket(), result.isDuplicate());

        return ResponseEntity.ok(ApiResponse.success("Inbound email processed successfully", result));
    }
}
