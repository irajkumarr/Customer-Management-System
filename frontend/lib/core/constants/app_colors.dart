import 'package:flutter/material.dart';

/// Design tokens calibrated for a Linear/Intercom enterprise aesthetic.
/// Monochromatic structure, hairline borders, and restrained semantic accents.
class AppColors {
  AppColors._();

  // Neutral Structure (Zinc / Slate scale)
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF4F4F5);
  static const Color neutral200 = Color(0xFFE4E4E7); // Standard hairline border
  static const Color neutral300 = Color(0xFFD4D4D8);
  static const Color neutral400 = Color(0xFFA1A1AA);
  static const Color neutral500 = Color(0xFF71717A); // Secondary text
  static const Color neutral600 = Color(0xFF52525B);
  static const Color neutral700 = Color(0xFF3F3F46);
  static const Color neutral800 = Color(0xFF27272A);
  static const Color neutral900 = Color(0xFF18181B); // Dark surface
  static const Color neutral950 = Color(0xFF09090B); // Primary text

  // Surfaces
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFFBFBFB);
  static const Color surfaceDark = Color(0xFF121215);
  static const Color backgroundDark = Color(0xFF09090B);

  // Primary Brand / Action
  static const Color primary = Color(0xFF18181B); // High-contrast primary (Linear/Vercel)
  static const Color primaryAccent = Color(0xFF4F46E5); // Indigo accent for active cues
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color primaryBorder = Color(0xFFC7D2FE);

  // Restrained Semantic Status Colors (Subtle tint + crisp border + high contrast text)
  // New
  static const Color statusNewBg = Color(0xFFEEF2FF);
  static const Color statusNewBorder = Color(0xFFC7D2FE);
  static const Color statusNew = Color(0xFF4338CA);

  // AI Processing
  static const Color statusAiProcessingBg = Color(0xFFF5F3FF);
  static const Color statusAiProcessingBorder = Color(0xFFDDD6FE);
  static const Color statusAiProcessing = Color(0xFF6D28D9);

  // AI Replied
  static const Color statusAiRepliedBg = Color(0xFFF0FDF4);
  static const Color statusAiRepliedBorder = Color(0xFFBBF7D0);
  static const Color statusAiReplied = Color(0xFF15803D);

  // Escalated to Human (Urgent alert)
  static const Color statusEscalatedBg = Color(0xFFFEF2F2);
  static const Color statusEscalatedBorder = Color(0xFFFECACA);
  static const Color statusEscalated = Color(0xFFB91C1C);

  // In Progress
  static const Color statusInProgressBg = Color(0xFFEFF6FF);
  static const Color statusInProgressBorder = Color(0xFFBFDBFE);
  static const Color statusInProgress = Color(0xFF1D4ED8);

  // Resolved
  static const Color statusResolvedBg = Color(0xFFF0FDF4);
  static const Color statusResolvedBorder = Color(0xFFBBF7D0);
  static const Color statusResolved = Color(0xFF15803D);

  // Closed
  static const Color statusClosedBg = Color(0xFFF4F4F5);
  static const Color statusClosedBorder = Color(0xFFE4E4E7);
  static const Color statusClosed = Color(0xFF71717A);

  // Categories (Restrained neutral badges)
  static const Color categoryBilling = Color(0xFF4338CA);
  static const Color categoryTechnical = Color(0xFF0F766E);
  static const Color categoryAccount = Color(0xFF1D4ED8);
  static const Color categoryGeneral = Color(0xFF52525B);
  static const Color categoryUnknown = Color(0xFF71717A);

  // Message Bubbles
  static const Color senderCustomer = Colors.white;
  static const Color senderCustomerDark = Color(0xFF18181B);
  static const Color senderAi = Color(0xFFF8FAFC); // Very subtle slate tint
  static const Color senderAiBorder = Color(0xFFE2E8F0);
  static const Color senderAdmin = Color(0xFFF8FAFC);
  static const Color senderAdminBorder = Color(0xFFE2E8F0);
}
