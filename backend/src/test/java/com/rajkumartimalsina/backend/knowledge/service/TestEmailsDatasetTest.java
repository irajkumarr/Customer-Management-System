package com.rajkumartimalsina.backend.knowledge.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;

class TestEmailsDatasetTest {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    @DisplayName("Should successfully load and validate test_emails.json dataset")
    void shouldLoadTestEmailsDataset() throws Exception {
        InputStream is = getClass().getClassLoader().getResourceAsStream("test_emails.json");
        assertThat(is).isNotNull();

        List<Map<String, Object>> testEmails = objectMapper.readValue(is, new TypeReference<>() {});
        assertThat(testEmails).isNotEmpty();
        assertThat(testEmails.size()).isGreaterThanOrEqualTo(20);

        Set<String> categories = testEmails.stream()
                .map(e -> (String) e.get("expectedCategory"))
                .collect(Collectors.toSet());

        assertThat(categories).contains("BILLING", "TECHNICAL", "ACCOUNT", "GENERAL", "UNKNOWN");

        long autoReplyCount = testEmails.stream()
                .filter(e -> Boolean.FALSE.equals(e.get("expectedRequiresHuman")))
                .count();

        long humanEscalationCount = testEmails.stream()
                .filter(e -> Boolean.TRUE.equals(e.get("expectedRequiresHuman")))
                .count();

        assertThat(autoReplyCount).isGreaterThan(5);
        assertThat(humanEscalationCount).isGreaterThan(5);

        for (Map<String, Object> email : testEmails) {
            assertThat(email.get("id")).isNotNull();
            assertThat(email.get("subject")).isNotNull();
            assertThat(email.get("bodyPlain")).isNotNull();
            assertThat(email.get("sender")).isNotNull();
            assertThat(email.get("expectedCategory")).isNotNull();
            assertThat(email.get("expectedRequiresHuman")).isNotNull();
        }
    }
}
