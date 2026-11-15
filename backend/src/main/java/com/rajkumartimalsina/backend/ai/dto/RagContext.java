package com.rajkumartimalsina.backend.ai.dto;

import java.util.List;

public record RagContext(
        String query,
        String formattedContext,
        List<String> chunkTitles
) {}
