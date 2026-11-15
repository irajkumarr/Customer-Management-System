package com.rajkumartimalsina.backend.ticket.dto;

import java.util.Map;

public record TicketStatsResponse(
        long total,
        long newTickets,
        long aiProcessing,
        long aiReplied,
        long escalatedToHuman,
        long inProgress,
        long resolved,
        long closed,
        Map<String, Long> byCategory
) {}
