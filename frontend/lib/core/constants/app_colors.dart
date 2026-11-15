import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary & Surface brand colors
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color backgroundDark = Color(0xFF020617);

  // Status Badge Colors
  static const Color statusNew = Color(0xFF3B82F6); // Blue
  static const Color statusAiProcessing = Color(0xFF8B5CF6); // Purple
  static const Color statusAiReplied = Color(0xFF10B981); // Emerald / Green
  static const Color statusEscalated = Color(0xFFEF4444); // Red / Alert
  static const Color statusInProgress = Color(0xFFF59E0B); // Amber
  static const Color statusResolved = Color(0xFF059669); // Dark Green
  static const Color statusClosed = Color(0xFF6B7280); // Gray

  // Category Badge Colors
  static const Color categoryBilling = Color(0xFF0D9488); // Teal
  static const Color categoryTechnical = Color(0xFF6366F1); // Indigo
  static const Color categoryAccount = Color(0xFF0284C7); // Light Blue
  static const Color categoryGeneral = Color(0xFF64748B); // Slate
  static const Color categoryUnknown = Color(0xFF94A3B8); // Muted Slate

  // Message Sender Colors
  static const Color senderCustomer = Color(0xFFE2E8F0); // Neutral light
  static const Color senderCustomerDark = Color(0xFF334155);
  static const Color senderAi = Color(0xFFEEF2FF); // Indigo tint
  static const Color senderAiBorder = Color(0xFFC7D2FE);
  static const Color senderAdmin = Color(0xFFEFF6FF); // Blue tint
  static const Color senderAdminBorder = Color(0xFFBFDBFE);
}
