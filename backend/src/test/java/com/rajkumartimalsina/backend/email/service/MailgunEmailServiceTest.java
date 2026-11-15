package com.rajkumartimalsina.backend.email.service;

import com.rajkumartimalsina.backend.email.dto.EmailSendRequest;
import com.rajkumartimalsina.backend.email.dto.EmailSendResult;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class MailgunEmailServiceTest {

    private MailgunEmailService emailService;

    @BeforeEach
    void setUp() {
        emailService = new MailgunEmailService();
        ReflectionTestUtils.setField(emailService, "apiKey", "key-dummy-12345");
        ReflectionTestUtils.setField(emailService, "domain", "test.mailgun.org");
        ReflectionTestUtils.setField(emailService, "fromEmail", "support@test.mailgun.org");
    }

    @Test
    @DisplayName("Should simulate email delivery successfully in dev mode when API key is dummy")
    void shouldSimulateSuccessInDevMode() {
        EmailSendRequest request = new EmailSendRequest(
                "customer@example.com",
                "Re: [Ticket #12345] Assistance",
                "Hello, **we have resolved your issue**.",
                "<parent-msg-id@domain.com>",
                List.of("<ref-msg-id@domain.com>")
        );

        EmailSendResult result = emailService.sendEmail(request);

        assertThat(result.success()).isTrue();
        assertThat(result.statusCode()).isEqualTo(200);
        assertThat(result.messageId()).startsWith("<");
        assertThat(result.messageId()).contains("@test.mailgun.org>");
        assertThat(result.errorMessage()).isNull();
    }
}
