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
    final hasActiveFilters = selectedStatus != null || selectedCategory != null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          // Clear all filters if active
          if (hasActiveFilters) ...[
            ActionChip(
              avatar: const Icon(Icons.close_rounded, size: 14, color: AppColors.statusEscalated),
              label: const Text('Clear All', style: TextStyle(color: AppColors.statusEscalated, fontSize: 12)),
              backgroundColor: AppColors.statusEscalated.withValues(alpha: 0.08),
              side: BorderSide(color: AppColors.statusEscalated.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              onPressed: () {
                onStatusChanged(null);
                onCategoryChanged(null);
              },
            ),
            const SizedBox(width: 8),
          ],

          // All Status chip
          ChoiceChip(
            label: const Text('All Status'),
            selected: selectedStatus == null,
            onSelected: (_) => onStatusChanged(null),
          ),
          const SizedBox(width: 6),

          // Individual Status chips
          ...TicketStatus.values.map(
            (status) {
              final isSelected = selectedStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(status.displayName),
                  selected: isSelected,
                  selectedColor: status.color.withValues(alpha: isDark ? 0.25 : 0.15),
                  checkmarkColor: status.color,
                  avatar: isSelected
                      ? null
                      : Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: status.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                  labelStyle: TextStyle(
                    color: isSelected ? status.color : null,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected ? status.color : tokens.cardBorder,
                  ),
                  onSelected: (selected) {
                    onStatusChanged(selected ? status : null);
                  },
                ),
              );
            },
          ),

          const SizedBox(width: 4),
          Container(
            height: 20,
            width: 1,
            color: tokens.dividerColor,
          ),
          const SizedBox(width: 8),

          // Category Dropdown / Menu
          PopupMenuButton<TicketCategory?>(
            initialValue: selectedCategory,
            tooltip: 'Filter by Category',
            onSelected: onCategoryChanged,
            itemBuilder: (context) => [
              const PopupMenuItem<TicketCategory?>(
                value: null,
                child: Text('All Categories', style: TextStyle(fontSize: 13)),
              ),
              const PopupMenuDivider(height: 1),
              ...TicketCategory.values.map(
                (cat) => PopupMenuItem<TicketCategory?>(
                  value: cat,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cat.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(cat.displayName, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: selectedCategory != null
                    ? selectedCategory!.color.withValues(alpha: 0.1)
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedCategory != null
                      ? selectedCategory!.color
                      : tokens.cardBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedCategory != null) ...[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: selectedCategory!.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    selectedCategory?.displayName ?? 'Category',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selectedCategory != null ? FontWeight.w600 : FontWeight.w500,
                      color: selectedCategory?.color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
