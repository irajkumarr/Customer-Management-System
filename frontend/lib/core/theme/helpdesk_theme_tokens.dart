import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

@immutable
class HelpdeskThemeTokens extends ThemeExtension<HelpdeskThemeTokens> {
  // Status Foreground Colors
  final Color statusNew;
  final Color statusAiProcessing;
  final Color statusAiReplied;
  final Color statusEscalated;
  final Color statusInProgress;
  final Color statusResolved;
  final Color statusClosed;

  // Status Backgrounds & Borders
  final Color statusEscalatedBg;
  final Color statusEscalatedBorder;
  final Color statusAiRepliedBg;
  final Color statusAiRepliedBorder;
  final Color statusInProgressBg;
  final Color statusInProgressBorder;

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
    required this.statusEscalatedBg,
    required this.statusEscalatedBorder,
    required this.statusAiRepliedBg,
    required this.statusAiRepliedBorder,
    required this.statusInProgressBg,
    required this.statusInProgressBorder,
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
    statusNew: AppColors.statusNew,
    statusAiProcessing: AppColors.statusAiProcessing,
    statusAiReplied: AppColors.statusAiReplied,
    statusEscalated: AppColors.statusEscalated,
    statusInProgress: AppColors.statusInProgress,
    statusResolved: AppColors.statusResolved,
    statusClosed: AppColors.statusClosed,
    statusEscalatedBg: AppColors.statusEscalatedBg,
    statusEscalatedBorder: AppColors.statusEscalatedBorder,
    statusAiRepliedBg: AppColors.statusAiRepliedBg,
    statusAiRepliedBorder: AppColors.statusAiRepliedBorder,
    statusInProgressBg: AppColors.statusInProgressBg,
    statusInProgressBorder: AppColors.statusInProgressBorder,
    categoryBilling: AppColors.categoryBilling,
    categoryTechnical: AppColors.categoryTechnical,
    categoryAccount: AppColors.categoryAccount,
    categoryGeneral: AppColors.categoryGeneral,
    categoryUnknown: AppColors.categoryUnknown,
    customerBubbleBg: Colors.white,
    customerBubbleBorder: AppColors.neutral200,
    aiBubbleBg: Color(0xFFFAFAFA),
    aiBubbleBorder: AppColors.neutral200,
    adminBubbleBg: Color(0xFFFAFAFA),
    adminBubbleBorder: AppColors.neutral200,
    sidebarBg: Color(0xFFFAFAFA),
    sidebarBorder: AppColors.neutral200,
    cardBorder: AppColors.neutral200,
    cardHoverBorder: AppColors.neutral300,
    subtleText: AppColors.neutral500,
    dividerColor: AppColors.neutral200,
  );

  static const HelpdeskThemeTokens dark = HelpdeskThemeTokens(
    statusNew: Color(0xFFA5B4FC),
    statusAiProcessing: Color(0xFFC4B5FD),
    statusAiReplied: Color(0xFF86EFAC),
    statusEscalated: Color(0xFFFCA5A5),
    statusInProgress: Color(0xFF93C5FD),
    statusResolved: Color(0xFF86EFAC),
    statusClosed: Color(0xFFA1A1AA),
    statusEscalatedBg: Color(0xFF450A0A),
    statusEscalatedBorder: Color(0xFF991B1B),
    statusAiRepliedBg: Color(0xFF052E16),
    statusAiRepliedBorder: Color(0xFF166534),
    statusInProgressBg: Color(0xFF172554),
    statusInProgressBorder: Color(0xFF1E40AF),
    categoryBilling: Color(0xFFA5B4FC),
    categoryTechnical: Color(0xFF5EEAD4),
    categoryAccount: Color(0xFF93C5FD),
    categoryGeneral: Color(0xFFA1A1AA),
    categoryUnknown: Color(0xFF71717A),
    customerBubbleBg: Color(0xFF18181B),
    customerBubbleBorder: Color(0xFF27272A),
    aiBubbleBg: Color(0xFF121215),
    aiBubbleBorder: Color(0xFF27272A),
    adminBubbleBg: Color(0xFF121215),
    adminBubbleBorder: Color(0xFF27272A),
    sidebarBg: Color(0xFF121215),
    sidebarBorder: Color(0xFF27272A),
    cardBorder: Color(0xFF27272A),
    cardHoverBorder: Color(0xFF3F3F46),
    subtleText: Color(0xFFA1A1AA),
    dividerColor: Color(0xFF27272A),
  );

  @override
  HelpdeskThemeTokens copyWith({
    Color? statusNew,
    Color? statusAiProcessing,
    Color? statusAiReplied,
    Color? statusEscalated,
    Color? statusInProgress,
    Color? statusResolved,
    Color? statusClosed,
    Color? statusEscalatedBg,
    Color? statusEscalatedBorder,
    Color? statusAiRepliedBg,
    Color? statusAiRepliedBorder,
    Color? statusInProgressBg,
    Color? statusInProgressBorder,
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
      statusEscalatedBg: statusEscalatedBg ?? this.statusEscalatedBg,
      statusEscalatedBorder: statusEscalatedBorder ?? this.statusEscalatedBorder,
      statusAiRepliedBg: statusAiRepliedBg ?? this.statusAiRepliedBg,
      statusAiRepliedBorder: statusAiRepliedBorder ?? this.statusAiRepliedBorder,
      statusInProgressBg: statusInProgressBg ?? this.statusInProgressBg,
      statusInProgressBorder: statusInProgressBorder ?? this.statusInProgressBorder,
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
  HelpdeskThemeTokens lerp(ThemeExtension<HelpdeskThemeTokens>? other, double t) {
    if (other is! HelpdeskThemeTokens) return this;
    return HelpdeskThemeTokens(
      statusNew: Color.lerp(statusNew, other.statusNew, t)!,
      statusAiProcessing: Color.lerp(statusAiProcessing, other.statusAiProcessing, t)!,
      statusAiReplied: Color.lerp(statusAiReplied, other.statusAiReplied, t)!,
      statusEscalated: Color.lerp(statusEscalated, other.statusEscalated, t)!,
      statusInProgress: Color.lerp(statusInProgress, other.statusInProgress, t)!,
      statusResolved: Color.lerp(statusResolved, other.statusResolved, t)!,
      statusClosed: Color.lerp(statusClosed, other.statusClosed, t)!,
      statusEscalatedBg: Color.lerp(statusEscalatedBg, other.statusEscalatedBg, t)!,
      statusEscalatedBorder: Color.lerp(statusEscalatedBorder, other.statusEscalatedBorder, t)!,
      statusAiRepliedBg: Color.lerp(statusAiRepliedBg, other.statusAiRepliedBg, t)!,
      statusAiRepliedBorder: Color.lerp(statusAiRepliedBorder, other.statusAiRepliedBorder, t)!,
      statusInProgressBg: Color.lerp(statusInProgressBg, other.statusInProgressBg, t)!,
      statusInProgressBorder: Color.lerp(statusInProgressBorder, other.statusInProgressBorder, t)!,
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
