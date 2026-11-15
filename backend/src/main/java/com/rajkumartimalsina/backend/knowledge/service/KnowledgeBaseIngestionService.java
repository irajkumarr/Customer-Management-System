package com.rajkumartimalsina.backend.knowledge.service;

import com.rajkumartimalsina.backend.knowledge.entity.KnowledgeBaseMetadata;
import com.rajkumartimalsina.backend.knowledge.repository.KnowledgeBaseMetadataRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.HexFormat;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class KnowledgeBaseIngestionService implements ApplicationRunner {

    private final ResourceLoader resourceLoader;
    private final KnowledgeBaseParser parser;
    private final KnowledgeBaseMetadataRepository metadataRepository;

    @Autowired(required = false)
    private VectorStore vectorStore;

    @Value("${app.ai.rag.knowledge-path:classpath:knowledge_base.md}")
    private String knowledgeBasePath;

    @Override
    public void run(ApplicationArguments args) {
        try {
            ingestKnowledgeBase();
        } catch (Exception e) {
            log.error("Failed to ingest knowledge base: {}", e.getMessage(), e);
        }
    }

    @Transactional
    public void ingestKnowledgeBase() {
        if (vectorStore == null) {
            log.warn("VectorStore bean not available. Skipping knowledge base ingestion.");
            return;
        }

        Resource resource = resourceLoader.getResource(knowledgeBasePath);
        if (!resource.exists()) {
            log.warn("Knowledge base resource not found at '{}'. Ingestion skipped.", knowledgeBasePath);
            return;
        }

        String markdownContent;
        String contentHash;

        try (InputStream is = resource.getInputStream()) {
            byte[] bytes = is.readAllBytes();
            markdownContent = new String(bytes, StandardCharsets.UTF_8);
            contentHash = computeSha256(bytes);
        } catch (Exception e) {
            log.error("Could not read knowledge base file: {}", e.getMessage());
            return;
        }

        String documentId = "knowledge_base.md";
        Optional<KnowledgeBaseMetadata> existing = metadataRepository.findById(documentId);

        if (existing.isPresent() && existing.get().getContentHash().equals(contentHash)) {
            log.info("Knowledge base is already up-to-date (hash: {}). Skipping re-indexing.", contentHash.substring(0, 10));
            return;
        }

        log.info("Ingesting knowledge base '{}' with hash: {}", documentId, contentHash);
        List<Document> documents = parser.parseMarkdownToDocuments(markdownContent, documentId, contentHash);

        if (documents.isEmpty()) {
            log.warn("No documents parsed from knowledge base. Ingestion skipped.");
            return;
        }

        try {
            vectorStore.add(documents);
            log.info("Successfully indexed {} knowledge base chunks in pgvector.", documents.size());

            KnowledgeBaseMetadata metadata = KnowledgeBaseMetadata.builder()
                    .id(documentId)
                    .contentHash(contentHash)
                    .chunkCount(documents.size())
                    .ingestedAt(Instant.now())
                    .build();

            metadataRepository.save(metadata);
        } catch (Exception e) {
            log.error("Failed to add documents to vector store: {}", e.getMessage());
        }
    }

    private String computeSha256(byte[] data) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(data);
            return HexFormat.of().formatHex(hash);
        } catch (Exception e) {
            return UUID.randomUUID().toString();
        }
    }
}
