import 'package:flutter/material.dart';

@immutable
class HelpdeskThemeTokens extends ThemeExtension<HelpdeskThemeTokens> {
  // Status Colors
  final Color statusNew;
  final Color statusAiProcessing;
  final Color statusAiReplied;
  final Color statusEscalated;
  final Color statusInProgress;
  final Color statusResolved;
  final Color statusClosed;

  // Category Colors
  final Color categoryBilling;
  final Color categoryTechnical;
  final Color categoryAccount;
  final Color categoryGeneral;
  final Color categoryUnknown;

  // Message Sender Styling
  final Color customerBubbleBg;
  final Color customerBubbleBorder;
  final Color aiBubbleBg;
  final Color aiBubbleBorder;
  final Color adminBubbleBg;
  final Color adminBubbleBorder;

  // Shell & Surface Elements
  final Color sidebarBg;
  final Color sidebarBorder;
  final Color cardBorder;
  final Color cardHoverBorder;
  final Color subtleText;
  final Color dividerColor;

  const HelpdeskThemeTokens({
    required this.statusNew,
    required this.statusAiProcessing,
    required this.statusAiReplied,
    required this.statusEscalated,
    required this.statusInProgress,
    required this.statusResolved,
    required this.statusClosed,
    required this.categoryBilling,
    required this.categoryTechnical,
    required this.categoryAccount,
    required this.categoryGeneral,
    required this.categoryUnknown,
    required this.customerBubbleBg,
    required this.customerBubbleBorder,
    required this.aiBubbleBg,
    required this.aiBubbleBorder,
    required this.adminBubbleBg,
    required this.adminBubbleBorder,
    required this.sidebarBg,
    required this.sidebarBorder,
    required this.cardBorder,
    required this.cardHoverBorder,
    required this.subtleText,
    required this.dividerColor,
  });

  static const HelpdeskThemeTokens light = HelpdeskThemeTokens(
    statusNew: Color(0xFF2563EB),
    statusAiProcessing: Color(0xFF7C3AED),
    statusAiReplied: Color(0xFF059669),
    statusEscalated: Color(0xFFDC2626),
    statusInProgress: Color(0xFFD97706),
    statusResolved: Color(0xFF059669),
    statusClosed: Color(0xFF4B5563),
    categoryBilling: Color(0xFF0D9488),
    categoryTechnical: Color(0xFF6366F1),
    categoryAccount: Color(0xFF0284C7),
    categoryGeneral: Color(0xFF64748B),
    categoryUnknown: Color(0xFF94A3B8),
    customerBubbleBg: Colors.white,
    customerBubbleBorder: Color(0xFFE2E8F0),
    aiBubbleBg: Color(0xFFF5F3FF),
    aiBubbleBorder: Color(0xFFDDD6FE),
    adminBubbleBg: Color(0xFFEFF6FF),
    adminBubbleBorder: Color(0xFFBFDBFE),
    sidebarBg: Color(0xFFF8FAFC),
    sidebarBorder: Color(0xFFE2E8F0),
    cardBorder: Color(0xFFE2E8F0),
    cardHoverBorder: Color(0xFFCBD5E1),
    subtleText: Color(0xFF64748B),
    dividerColor: Color(0xFFE2E8F0),
  );

  static const HelpdeskThemeTokens dark = HelpdeskThemeTokens(
    statusNew: Color(0xFF60A5FA),
    statusAiProcessing: Color(0xFFA78BFA),
    statusAiReplied: Color(0xFF34D399),
    statusEscalated: Color(0xFFF87171),
    statusInProgress: Color(0xFFFBBF24),
    statusResolved: Color(0xFF34D399),
    statusClosed: Color(0xFF9CA3AF),
    categoryBilling: Color(0xFF2DD4BF),
    categoryTechnical: Color(0xFF818CF8),
    categoryAccount: Color(0xFF38BDF8),
    categoryGeneral: Color(0xFF94A3B8),
    categoryUnknown: Color(0xFF64748B),
    customerBubbleBg: Color(0xFF1E293B),
    customerBubbleBorder: Color(0xFF334155),
    aiBubbleBg: Color(0xFF1E1B4B),
    aiBubbleBorder: Color(0xFF4338CA),
    adminBubbleBg: Color(0xFF172554),
    adminBubbleBorder: Color(0xFF1E40AF),
    sidebarBg: Color(0xFF0B132B),
    sidebarBorder: Color(0xFF1E293B),
    cardBorder: Color(0xFF334155),
    cardHoverBorder: Color(0xFF475569),
    subtleText: Color(0xFF94A3B8),
    dividerColor: Color(0xFF1E293B),
  );

  @override
  ThemeExtension<HelpdeskThemeTokens> copyWith({
    Color? statusNew,
    Color? statusAiProcessing,
    Color? statusAiReplied,
    Color? statusEscalated,
    Color? statusInProgress,
    Color? statusResolved,
    Color? statusClosed,
    Color? categoryBilling,
    Color? categoryTechnical,
    Color? categoryAccount,
    Color? categoryGeneral,
    Color? categoryUnknown,
    Color? customerBubbleBg,
    Color? customerBubbleBorder,
    Color? aiBubbleBg,
    Color? aiBubbleBorder,
    Color? adminBubbleBg,
    Color? adminBubbleBorder,
    Color? sidebarBg,
    Color? sidebarBorder,
    Color? cardBorder,
    Color? cardHoverBorder,
    Color? subtleText,
    Color? dividerColor,
  }) {
    return HelpdeskThemeTokens(
      statusNew: statusNew ?? this.statusNew,
      statusAiProcessing: statusAiProcessing ?? this.statusAiProcessing,
      statusAiReplied: statusAiReplied ?? this.statusAiReplied,
      statusEscalated: statusEscalated ?? this.statusEscalated,
      statusInProgress: statusInProgress ?? this.statusInProgress,
      statusResolved: statusResolved ?? this.statusResolved,
      statusClosed: statusClosed ?? this.statusClosed,
      categoryBilling: categoryBilling ?? this.categoryBilling,
      categoryTechnical: categoryTechnical ?? this.categoryTechnical,
      categoryAccount: categoryAccount ?? this.categoryAccount,
      categoryGeneral: categoryGeneral ?? this.categoryGeneral,
      categoryUnknown: categoryUnknown ?? this.categoryUnknown,
      customerBubbleBg: customerBubbleBg ?? this.customerBubbleBg,
      customerBubbleBorder: customerBubbleBorder ?? this.customerBubbleBorder,
      aiBubbleBg: aiBubbleBg ?? this.aiBubbleBg,
      aiBubbleBorder: aiBubbleBorder ?? this.aiBubbleBorder,
      adminBubbleBg: adminBubbleBg ?? this.adminBubbleBg,
      adminBubbleBorder: adminBubbleBorder ?? this.adminBubbleBorder,
      sidebarBg: sidebarBg ?? this.sidebarBg,
      sidebarBorder: sidebarBorder ?? this.sidebarBorder,
      cardBorder: cardBorder ?? this.cardBorder,
      cardHoverBorder: cardHoverBorder ?? this.cardHoverBorder,
      subtleText: subtleText ?? this.subtleText,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }

  @override
  ThemeExtension<HelpdeskThemeTokens> lerp(
    covariant ThemeExtension<HelpdeskThemeTokens>? other,
    double t,
  ) {
    if (other is! HelpdeskThemeTokens) return this;
    return HelpdeskThemeTokens(
      statusNew: Color.lerp(statusNew, other.statusNew, t)!,
      statusAiProcessing: Color.lerp(statusAiProcessing, other.statusAiProcessing, t)!,
      statusAiReplied: Color.lerp(statusAiReplied, other.statusAiReplied, t)!,
      statusEscalated: Color.lerp(statusEscalated, other.statusEscalated, t)!,
      statusInProgress: Color.lerp(statusInProgress, other.statusInProgress, t)!,
      statusResolved: Color.lerp(statusResolved, other.statusResolved, t)!,
      statusClosed: Color.lerp(statusClosed, other.statusClosed, t)!,
      categoryBilling: Color.lerp(categoryBilling, other.categoryBilling, t)!,
      categoryTechnical: Color.lerp(categoryTechnical, other.categoryTechnical, t)!,
      categoryAccount: Color.lerp(categoryAccount, other.categoryAccount, t)!,
      categoryGeneral: Color.lerp(categoryGeneral, other.categoryGeneral, t)!,
      categoryUnknown: Color.lerp(categoryUnknown, other.categoryUnknown, t)!,
      customerBubbleBg: Color.lerp(customerBubbleBg, other.customerBubbleBg, t)!,
      customerBubbleBorder: Color.lerp(customerBubbleBorder, other.customerBubbleBorder, t)!,
      aiBubbleBg: Color.lerp(aiBubbleBg, other.aiBubbleBg, t)!,
      aiBubbleBorder: Color.lerp(aiBubbleBorder, other.aiBubbleBorder, t)!,
      adminBubbleBg: Color.lerp(adminBubbleBg, other.adminBubbleBg, t)!,
      adminBubbleBorder: Color.lerp(adminBubbleBorder, other.adminBubbleBorder, t)!,
      sidebarBg: Color.lerp(sidebarBg, other.sidebarBg, t)!,
      sidebarBorder: Color.lerp(sidebarBorder, other.sidebarBorder, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardHoverBorder: Color.lerp(cardHoverBorder, other.cardHoverBorder, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
    );
  }
}

extension HelpdeskThemeContext on BuildContext {
  HelpdeskThemeTokens get tokens =>
      Theme.of(this).extension<HelpdeskThemeTokens>() ?? HelpdeskThemeTokens.light;
}
