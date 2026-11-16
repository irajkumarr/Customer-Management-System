import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // CognitiveDesk Brand Colors
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryDark = Color(0xFF4338CA); // Indigo 700
  static const Color primaryLight = Color(0xFFEEF2FF); // Indigo 50
  static const Color primaryBorder = Color(0xFFC7D2FE); // Indigo 200

  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color backgroundDark = Color(0xFF020617);

  // Status Badge Colors (CognitiveDesk Palette)
  static const Color statusNew = Color(0xFF4F46E5); // Indigo
  static const Color statusAiProcessing = Color(0xFF8B5CF6); // Purple
  static const Color statusAiReplied = Color(0xFF10B981); // Emerald
  static const Color statusEscalated = Color(0xFFF59E0B); // Amber / Alert
  static const Color statusInProgress = Color(0xFF3B82F6); // Blue (In Review)
  static const Color statusResolved = Color(0xFF10B981); // Emerald Green
  static const Color statusClosed = Color(0xFF6B7280); // Slate Gray

  // Category Badge Colors
  static const Color categoryBilling = Color(0xFF4F46E5); // Indigo
  static const Color categoryTechnical = Color(0xFF0D9488); // Teal
  static const Color categoryAccount = Color(0xFF3B82F6); // Blue
  static const Color categoryGeneral = Color(0xFF64748B); // Slate
  static const Color categoryUnknown = Color(0xFF94A3B8); // Muted Slate

  // Message Sender Colors
  static const Color senderCustomer = Color(0xFFFFFFFF);
  static const Color senderCustomerDark = Color(0xFF1E293B);
  static const Color senderAi = Color(0xFFF5F3FF); // Light Purple Tint
  static const Color senderAiBorder = Color(0xFFDDD6FE);
  static const Color senderAdmin = Color(0xFFEEF2FF); // Indigo Tint
  static const Color senderAdminBorder = Color(0xFFC7D2FE);
}
