package com.rajkumartimalsina.backend.knowledge.repository;

import com.rajkumartimalsina.backend.knowledge.entity.KnowledgeBaseMetadata;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface KnowledgeBaseMetadataRepository extends JpaRepository<KnowledgeBaseMetadata, String> {
}
