package com.rajkumartimalsina.backend.webhook.controller;

import com.rajkumartimalsina.backend.common.response.ApiResponse;
import com.rajkumartimalsina.backend.webhook.dto.InboundEmailPayload;
import com.rajkumartimalsina.backend.webhook.dto.WebhookProcessingResult;
import com.rajkumartimalsina.backend.webhook.security.SendGridSignatureVerifier;
import com.rajkumartimalsina.backend.webhook.service.SendGridInboundService;
import jakarta.servlet.http.HttpServletRequest;
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
public class SendGridWebhookController {

    private final SendGridSignatureVerifier signatureVerifier;
    private final SendGridInboundService inboundService;

    @PostMapping(value = "/sendgrid", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<WebhookProcessingResult>> handleSendGridInbound(
            @RequestHeader(value = "X-Twilio-Email-Event-Webhook-Signature", required = false) String signature,
            @RequestHeader(value = "X-Twilio-Email-Event-Webhook-Timestamp", required = false) String timestamp,
            @RequestParam(value = "from", required = false) String from,
            @RequestParam(value = "to", required = false) String to,
            @RequestParam(value = "subject", required = false) String subject,
            @RequestParam(value = "text", required = false) String text,
            @RequestParam(value = "html", required = false) String html,
            @RequestParam(value = "headers", required = false) String headers,
            @RequestParam(value = "envelope", required = false) String envelope,
            HttpServletRequest request
    ) {
        log.info("Received SendGrid Inbound Parse webhook from: '{}', subject: '{}'", from, subject);

        // Signature verification if configured
        if (signatureVerifier.isVerificationEnabled()) {
            try {
                byte[] rawBody = request.getInputStream().readAllBytes();
                boolean verified = signatureVerifier.verify(rawBody, signature, timestamp);
                if (!verified) {
                    log.warn("SendGrid Inbound webhook signature verification rejected.");
                    return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                            .body(ApiResponse.error("Invalid webhook signature."));
                }
            } catch (Exception e) {
                log.error("Failed to read raw body for webhook signature verification: {}", e.getMessage());
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(ApiResponse.error("Failed to verify webhook signature."));
            }
        }

        InboundEmailPayload payload = new InboundEmailPayload(
                from,
                to,
                subject,
                text,
                html,
                headers,
                envelope
        );

        WebhookProcessingResult result = inboundService.processInboundEmail(payload);

        log.info("SendGrid Inbound Parse processed: ticketId={}, isNewTicket={}, isDuplicate={}",
                result.ticketId(), result.isNewTicket(), result.isDuplicate());

        return ResponseEntity.ok(ApiResponse.success("Inbound email processed successfully", result));
    }
}
