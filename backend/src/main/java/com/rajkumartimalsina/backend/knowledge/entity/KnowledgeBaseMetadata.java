package com.rajkumartimalsina.backend.knowledge.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

import java.time.Instant;

@Entity
@Table(name = "knowledge_metadata")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class KnowledgeBaseMetadata {

    @Id
    @Column(nullable = false, length = 100)
    private String id;

    @Column(name = "content_hash", nullable = false, length = 128)
    private String contentHash;

    @Column(name = "chunk_count", nullable = false)
    private int chunkCount;

    @Column(name = "ingested_at", nullable = false)
    private Instant ingestedAt;
}
