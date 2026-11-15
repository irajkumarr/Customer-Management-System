package com.rajkumartimalsina.backend.webhook.controller;

import com.rajkumartimalsina.backend.admin.service.AdminDetailsService;
import com.rajkumartimalsina.backend.common.config.CorsConfig;
import com.rajkumartimalsina.backend.common.config.SecurityConfig;
import com.rajkumartimalsina.backend.webhook.dto.MailgunInboundPayload;
import com.rajkumartimalsina.backend.webhook.dto.WebhookProcessingResult;
import com.rajkumartimalsina.backend.webhook.security.MailgunSignatureVerifier;
import com.rajkumartimalsina.backend.webhook.service.MailgunInboundService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(MailgunWebhookController.class)
@Import({SecurityConfig.class, CorsConfig.class})
class MailgunWebhookControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private MailgunSignatureVerifier signatureVerifier;

    @MockitoBean
    private MailgunInboundService inboundService;

    @MockitoBean
    private AdminDetailsService adminDetailsService;

    @Test
    @DisplayName("Should process inbound webhook successfully when signature is valid")
    void shouldProcessInboundWebhookWhenValid() throws Exception {
        when(signatureVerifier.isVerificationEnabled()).thenReturn(true);
        when(signatureVerifier.verify(any(), any(), any())).thenReturn(true);

        UUID ticketId = UUID.randomUUID();
        UUID messageId = UUID.randomUUID();
        WebhookProcessingResult result = new WebhookProcessingResult(ticketId, messageId, true, false, "alice@example.com");
        when(inboundService.processInboundEmail(any(MailgunInboundPayload.class))).thenReturn(result);

        mockMvc.perform(post("/api/webhooks/mailgun")
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .param("from", "Alice <alice@example.com>")
                        .param("sender", "alice@example.com")
                        .param("subject", "Billing Inquiry")
                        .param("body-plain", "I have a question about my invoice.")
                        .param("timestamp", "1700000000")
                        .param("token", "token-xyz")
                        .param("signature", "valid-signature"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.ticketId").value(ticketId.toString()))
                .andExpect(jsonPath("$.data.isNewTicket").value(true))
                .andExpect(jsonPath("$.data.customerEmail").value("alice@example.com"));
    }

    @Test
    @DisplayName("Should reject webhook with 401 when signature verification fails")
    void shouldRejectWebhookWhenSignatureFails() throws Exception {
        when(signatureVerifier.isVerificationEnabled()).thenReturn(true);
        when(signatureVerifier.verify(any(), any(), any())).thenReturn(false);

        mockMvc.perform(post("/api/webhooks/mailgun")
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .param("from", "Attacker <evil@example.com>")
                        .param("timestamp", "1700000000")
                        .param("token", "bad-token")
                        .param("signature", "bad-signature"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value("Invalid webhook signature."));
    }
}
