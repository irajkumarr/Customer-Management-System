package com.rajkumartimalsina.backend.knowledge.service;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.ai.document.Document;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import static org.assertj.core.api.Assertions.assertThat;

class KnowledgeBaseParserTest {

    private final KnowledgeBaseParser parser = new KnowledgeBaseParser();

    @Test
    @DisplayName("Should successfully parse knowledge_base.md into structured documents")
    void shouldParseKnowledgeBaseMarkdownFile() throws Exception {
        InputStream inputStream = getClass().getClassLoader().getResourceAsStream("knowledge_base.md");
        assertThat(inputStream).isNotNull();

        String content = new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
        List<Document> documents = parser.parseMarkdownToDocuments(content, "knowledge_base.md", "dummy-hash");

        assertThat(documents).isNotEmpty();
        assertThat(documents.size()).isGreaterThanOrEqualTo(30);

        Set<String> sections = documents.stream()
                .map(d -> (String) d.getMetadata().get("section"))
                .collect(Collectors.toSet());

        assertThat(sections).contains(
                "1. Billing & Subscriptions",
                "2. Technical Support",
                "3. Account Management",
                "4. General Policies & SLA"
        );

        for (Document doc : documents) {
            assertThat(doc.getText()).isNotBlank();
            assertThat(doc.getMetadata().get("title")).isNotNull();
            assertThat(doc.getMetadata().get("source")).isEqualTo("knowledge_base.md");
            assertThat(doc.getMetadata().get("contentHash")).isEqualTo("dummy-hash");
        }
    }
}
