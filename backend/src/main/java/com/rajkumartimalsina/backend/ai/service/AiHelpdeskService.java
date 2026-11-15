package com.rajkumartimalsina.backend.ai.service;

import com.rajkumartimalsina.backend.ai.dto.AiAgentResponse;
import com.rajkumartimalsina.backend.ai.dto.RagContext;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class AiHelpdeskService {

    @Autowired(required = false)
    private ChatClient chatClient;

    @Autowired(required = false)
    private VectorStore vectorStore;

    @Value("${app.ai.rag.top-k:3}")
    private int topK;

    @Value("${app.ai.rag.similarity-threshold:0.65}")
    private double similarityThreshold;

    @Value("${spring.ai.google.genai.api-key:}")
    private String apiKey;

    public AiAgentResponse analyzeAndGenerateReply(String subject, String customerQuery) {
        String combinedQuery = subject + " " + customerQuery;

        // Retrieve relevant knowledge context from pgvector
        RagContext ragContext = retrieveContext(combinedQuery);

        // If ChatClient is unavailable or API key is dummy/missing, return safe fallback
        if (chatClient == null || apiKey == null || apiKey.isBlank() || apiKey.startsWith("dummy-key")) {
            log.info("[DEV MODE] Gemini API key not configured or ChatClient absent. Returning fallback AI response.");
            return createFallbackResponse(subject, customerQuery, "Gemini API key not configured in development environment.");
        }

        try {
            String systemPrompt = buildSystemPrompt(ragContext.formattedContext());
            String userPrompt = "Customer Subject: " + subject + "\n\nCustomer Message:\n" + customerQuery;

            log.info("Sending RAG request to Gemini with {} retrieved knowledge chunks...", ragContext.chunkTitles().size());

            AiAgentResponse response = chatClient.prompt()
                    .system(systemPrompt)
                    .user(userPrompt)
                    .call()
                    .entity(AiAgentResponse.class);

            if (response == null) {
                return createFallbackResponse(subject, customerQuery, "Empty response from Gemini.");
            }

            log.info("Gemini response: requiresHuman={}, category={}, escalationReason='{}'",
                    response.requiresHuman(), response.category(), response.escalationReason());

            return normalizeResponse(response);
        } catch (Exception e) {
            log.error("Error executing Gemini RAG pipeline: {}", e.getMessage(), e);
            return createFallbackResponse(subject, customerQuery, "AI processing error: " + e.getMessage());
        }
    }

    public RagContext retrieveContext(String query) {
        if (vectorStore == null) {
            return new RagContext(query, "No vector store available.", List.of());
        }

        try {
            SearchRequest request = SearchRequest.builder()
                    .query(query)
                    .topK(topK)
                    .similarityThreshold(similarityThreshold)
                    .build();

            List<Document> similarDocuments = vectorStore.similaritySearch(request);
            if (similarDocuments.isEmpty()) {
                // Try fallback without strict threshold
                similarDocuments = vectorStore.similaritySearch(
                        SearchRequest.builder().query(query).topK(topK).build()
                );
            }

            List<String> titles = new ArrayList<>();
            StringBuilder contextBuilder = new StringBuilder();

            for (Document doc : similarDocuments) {
                String title = (String) doc.getMetadata().getOrDefault("title", "Untitled");
                titles.add(title);
                contextBuilder.append("---\n")
                        .append(doc.getText())
                        .append("\n\n");
            }

            return new RagContext(query, contextBuilder.toString().trim(), titles);
        } catch (Exception e) {
            log.warn("Vector store similarity search failed: {}", e.getMessage());
            return new RagContext(query, "No context retrieved due to an error.", List.of());
        }
    }

    private String buildSystemPrompt(String context) {
        return """
                You are an intelligent, empathetic customer support AI agent for a SaaS customer management platform.
                
                Your job is to:
                1. Answer customer queries clearly and accurately using the provided KNOWLEDGE BASE CONTEXT.
                2. Categorize the ticket into one of the following exact categories:
                   - BILLING: Invoices, payments, refunds, subscription plans, cancellations.
                   - TECHNICAL: Bugs, slow loading, 500 errors, password resets, 2FA, logins.
                   - ACCOUNT: Profile updates, email changes, multiple users, account deletion.
                   - GENERAL: General questions about the company or product.
                   - UNKNOWN: Cannot be determined.
                3. Determine if human escalation is required (`requiresHuman: true`).
                
                RULES:
                - Base your answers strictly on the facts in the KNOWLEDGE BASE CONTEXT below.
                - DO NOT hallucinate, guess, or make up company policies, pricing, or refund terms.
                - If the context does not provide a direct or confident answer, set `requiresHuman = true`, provide an explanation in `escalationReason`, and write a polite holding reply reassuring the customer that a human agent has been assigned.
                - If the customer requests account deletion, a custom enterprise plan, or a refund beyond 30 days, set `requiresHuman = true`.
                - Format `replyText` in clean, professional Markdown.
                
                KNOWLEDGE BASE CONTEXT:
                """ + context;
    }

    private AiAgentResponse createFallbackResponse(String subject, String query, String reason) {
        String category = guessCategory(subject + " " + query);
        String holdingMessage = """
                Hello,
                
                Thank you for contacting our support team. We have received your request regarding **"%s"**.
                
                A support specialist has been assigned to your ticket and will follow up with you shortly.
                
                Best regards,  
                **Customer Support Team**
                """.formatted(subject);

        return new AiAgentResponse(
                holdingMessage,
                true,
                reason,
                category
        );
    }

    private String guessCategory(String text) {
        String lower = text.toLowerCase();
        if (lower.contains("bill") || lower.contains("invoice") || lower.contains("refund") || lower.contains("payment") || lower.contains("subscription") || lower.contains("cancel")) {
            return "BILLING";
        }
        if (lower.contains("error") || lower.contains("password") || lower.contains("bug") || lower.contains("slow") || lower.contains("500") || lower.contains("2fa") || lower.contains("login")) {
            return "TECHNICAL";
        }
        if (lower.contains("account") || lower.contains("email") || lower.contains("profile") || lower.contains("user")) {
            return "ACCOUNT";
        }
        return "GENERAL";
    }

    private AiAgentResponse normalizeResponse(AiAgentResponse response) {
        String category = response.category() != null ? response.category().toUpperCase().trim() : "UNKNOWN";
        if (!List.of("BILLING", "TECHNICAL", "ACCOUNT", "GENERAL", "UNKNOWN").contains(category)) {
            category = "UNKNOWN";
        }
        return new AiAgentResponse(
                response.replyText(),
                response.requiresHuman(),
                response.escalationReason(),
                category
        );
    }
}
