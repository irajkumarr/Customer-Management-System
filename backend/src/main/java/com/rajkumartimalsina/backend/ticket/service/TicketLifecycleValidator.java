package com.rajkumartimalsina.backend.ticket.service;

import com.rajkumartimalsina.backend.common.exception.InvalidOperationException;
import com.rajkumartimalsina.backend.ticket.enums.TicketStatus;

public class TicketLifecycleValidator {

    public static void validateTransition(TicketStatus currentStatus, TicketStatus targetStatus) {
        if (currentStatus == targetStatus) {
            return;
        }

        boolean allowed = switch (currentStatus) {
            case NEW -> targetStatus == TicketStatus.AI_PROCESSING
                    || targetStatus == TicketStatus.ESCALATED_TO_HUMAN
                    || targetStatus == TicketStatus.IN_PROGRESS
                    || targetStatus == TicketStatus.CLOSED;

            case AI_PROCESSING -> targetStatus == TicketStatus.AI_REPLIED
                    || targetStatus == TicketStatus.ESCALATED_TO_HUMAN;

            case AI_REPLIED -> targetStatus == TicketStatus.ESCALATED_TO_HUMAN
                    || targetStatus == TicketStatus.IN_PROGRESS
                    || targetStatus == TicketStatus.RESOLVED
                    || targetStatus == TicketStatus.CLOSED;

            case ESCALATED_TO_HUMAN -> targetStatus == TicketStatus.IN_PROGRESS
                    || targetStatus == TicketStatus.RESOLVED
                    || targetStatus == TicketStatus.CLOSED;

            case IN_PROGRESS -> targetStatus == TicketStatus.RESOLVED
                    || targetStatus == TicketStatus.CLOSED
                    || targetStatus == TicketStatus.ESCALATED_TO_HUMAN;

            case RESOLVED -> targetStatus == TicketStatus.CLOSED
                    || targetStatus == TicketStatus.IN_PROGRESS; // Reopen

            case CLOSED -> targetStatus == TicketStatus.IN_PROGRESS; // Reopen
        };

        if (!allowed) {
            throw new InvalidOperationException(
                    "Invalid ticket status transition from '" + currentStatus + "' to '" + targetStatus + "'."
            );
        }
    }
}
