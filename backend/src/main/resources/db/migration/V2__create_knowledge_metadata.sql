CREATE TABLE IF NOT EXISTS knowledge_metadata (
    id VARCHAR(100) PRIMARY KEY,
    content_hash VARCHAR(128) NOT NULL,
    chunk_count INT NOT NULL,
    ingested_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
