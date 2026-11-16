import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
import '../../data/models/ticket_enums.dart';

class TicketFilterChips extends StatelessWidget {
  final TicketStatus? selectedStatus;
  final TicketCategory? selectedCategory;
  final ValueChanged<TicketStatus?> onStatusChanged;
  final ValueChanged<TicketCategory?> onCategoryChanged;

  const TicketFilterChips({
    super.key,
    required this.selectedStatus,
    required this.selectedCategory,
    required this.onStatusChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasActiveFilter = selectedStatus != null || selectedCategory != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Selector Dropdown / Menu
          PopupMenuButton<TicketStatus?>(
            onSelected: onStatusChanged,
            tooltip: 'Filter by Status',
            position: PopupMenuPosition.under,
            itemBuilder: (context) => [
              const PopupMenuItem<TicketStatus?>(
                value: null,
                child: Text('All Statuses', style: TextStyle(fontSize: 12.5)),
              ),
              const PopupMenuDivider(height: 1),
              ...TicketStatus.values.map(
                (status) => PopupMenuItem<TicketStatus?>(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: status.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(status.displayName, style: const TextStyle(fontSize: 12.5)),
                    ],
                  ),
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: selectedStatus != null
                    ? (isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7))
                    : (isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selectedStatus != null
                      ? AppColors.neutral900
                      : tokens.cardBorder,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedStatus?.displayName ?? 'Status',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: selectedStatus != null
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: tokens.subtleText,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Category Selector Dropdown / Menu
          PopupMenuButton<TicketCategory?>(
            onSelected: onCategoryChanged,
            tooltip: 'Filter by Category',
            position: PopupMenuPosition.under,
            itemBuilder: (context) => [
              const PopupMenuItem<TicketCategory?>(
                value: null,
                child: Text('All Categories', style: TextStyle(fontSize: 12.5)),
              ),
              const PopupMenuDivider(height: 1),
              ...TicketCategory.values.map(
                (cat) => PopupMenuItem<TicketCategory?>(
                  value: cat,
                  child: Text(cat.displayName, style: const TextStyle(fontSize: 12.5)),
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: selectedCategory != null
                    ? (isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7))
                    : (isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selectedCategory != null
                      ? AppColors.neutral900
                      : tokens.cardBorder,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedCategory?.displayName ?? 'Category',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: selectedCategory != null
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: tokens.subtleText,
                  ),
                ],
              ),
            ),
          ),

          if (hasActiveFilter) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: () {
                onStatusChanged(null);
                onCategoryChanged(null);
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: tokens.subtleText,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
