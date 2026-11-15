// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum TicketStatus {
  NEW,
  AI_PROCESSING,
  AI_REPLIED,
  ESCALATED_TO_HUMAN,
  IN_PROGRESS,
  RESOLVED,
  CLOSED;

  String get displayName {
    switch (this) {
      case TicketStatus.NEW:
        return 'New';
      case TicketStatus.AI_PROCESSING:
        return 'AI Processing';
      case TicketStatus.AI_REPLIED:
        return 'AI Replied';
      case TicketStatus.ESCALATED_TO_HUMAN:
        return 'Escalated to Human';
      case TicketStatus.IN_PROGRESS:
        return 'In Progress';
      case TicketStatus.RESOLVED:
        return 'Resolved';
      case TicketStatus.CLOSED:
        return 'Closed';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.NEW:
        return AppColors.statusNew;
      case TicketStatus.AI_PROCESSING:
        return AppColors.statusAiProcessing;
      case TicketStatus.AI_REPLIED:
        return AppColors.statusAiReplied;
      case TicketStatus.ESCALATED_TO_HUMAN:
        return AppColors.statusEscalated;
      case TicketStatus.IN_PROGRESS:
        return AppColors.statusInProgress;
      case TicketStatus.RESOLVED:
        return AppColors.statusResolved;
      case TicketStatus.CLOSED:
        return AppColors.statusClosed;
    }
  }
}

enum TicketCategory {
  BILLING,
  TECHNICAL,
  ACCOUNT,
  GENERAL,
  UNKNOWN;

  String get displayName {
    switch (this) {
      case TicketCategory.BILLING:
        return 'Billing';
      case TicketCategory.TECHNICAL:
        return 'Technical';
      case TicketCategory.ACCOUNT:
        return 'Account';
      case TicketCategory.GENERAL:
        return 'General';
      case TicketCategory.UNKNOWN:
        return 'Unknown';
    }
  }

  Color get color {
    switch (this) {
      case TicketCategory.BILLING:
        return AppColors.categoryBilling;
      case TicketCategory.TECHNICAL:
        return AppColors.categoryTechnical;
      case TicketCategory.ACCOUNT:
        return AppColors.categoryAccount;
      case TicketCategory.GENERAL:
        return AppColors.categoryGeneral;
      case TicketCategory.UNKNOWN:
        return AppColors.categoryUnknown;
    }
  }
}

enum MessageSenderType {
  CUSTOMER,
  AI,
  ADMIN;

  String get displayName {
    switch (this) {
      case MessageSenderType.CUSTOMER:
        return 'Customer';
      case MessageSenderType.AI:
        return 'AI Assistant';
      case MessageSenderType.ADMIN:
        return 'Support Agent';
    }
  }
}
