package com.rajkumartimalsina.backend.knowledge.service;

import org.springframework.ai.document.Document;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.StringReader;
import java.util.*;

@Component
public class KnowledgeBaseParser {

    public List<Document> parseMarkdownToDocuments(String markdownContent, String sourceName, String contentHash) {
        List<Document> documents = new ArrayList<>();
        if (markdownContent == null || markdownContent.isBlank()) {
            return documents;
        }

        try (BufferedReader reader = new BufferedReader(new StringReader(markdownContent))) {
            String line;
            String currentSection = "General";
            String currentTitle = null;
            StringBuilder currentBody = new StringBuilder();

            while ((line = reader.readLine()) != null) {
                String trimmed = line.trim();

                // Section heading (## ...)
                if (trimmed.startsWith("## ") && !trimmed.startsWith("### ")) {
                    // Flush existing chunk
                    if (currentTitle != null && !currentBody.isEmpty()) {
                        documents.add(createDocument(sourceName, currentSection, currentTitle, currentBody.toString().trim(), contentHash));
                        currentBody = new StringBuilder();
                        currentTitle = null;
                    }
                    currentSection = trimmed.substring(3).trim();
                }
                // Topic / Question heading (### ...)
                else if (trimmed.startsWith("### ")) {
                    // Flush existing chunk
                    if (currentTitle != null && !currentBody.isEmpty()) {
                        documents.add(createDocument(sourceName, currentSection, currentTitle, currentBody.toString().trim(), contentHash));
                        currentBody = new StringBuilder();
                    }
                    currentTitle = trimmed.substring(4).trim();
                }
                // Separator or content
                else if (!trimmed.equals("---")) {
                    if (currentTitle != null) {
                        currentBody.append(line).append("\n");
                    }
                }
            }

            // Flush final chunk
            if (currentTitle != null && !currentBody.isEmpty()) {
                documents.add(createDocument(sourceName, currentSection, currentTitle, currentBody.toString().trim(), contentHash));
            }

            // If no headings found, treat whole document as one chunk
            if (documents.isEmpty() && !markdownContent.isBlank()) {
                documents.add(createDocument(sourceName, "General", sourceName, markdownContent.trim(), contentHash));
            }
        } catch (Exception ignored) {
        }

        return documents;
    }

    private Document createDocument(String source, String section, String title, String body, String contentHash) {
        String formattedContent = "Section: " + section + "\nTopic: " + title + "\n\n" + body;

        Map<String, Object> metadata = new HashMap<>();
        metadata.put("source", source);
        metadata.put("section", section);
        metadata.put("title", title);
        metadata.put("contentHash", contentHash);

        return Document.builder()
                .text(formattedContent)
                .metadata(metadata)
                .build();
    }
}
