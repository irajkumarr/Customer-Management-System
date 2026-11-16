import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // All Status chip
          ChoiceChip(
            label: const Text('All Status'),
            selected: selectedStatus == null,
            onSelected: (_) => onStatusChanged(null),
          ),
          const SizedBox(width: 8),

          // Individual Status chips
          ...TicketStatus.values.map(
            (status) {
              final isSelected = selectedStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(status.displayName),
                  selected: isSelected,
                  selectedColor: status.color.withValues(alpha: 0.2),
                  checkmarkColor: status.color,
                  labelStyle: TextStyle(
                    color: isSelected ? status.color : null,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: isSelected ? status.color : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                  ),
                  onSelected: (selected) {
                    onStatusChanged(selected ? status : null);
                  },
                ),
              );
            },
          ),

          const SizedBox(width: 8),
          Container(
            height: 24,
            width: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          const SizedBox(width: 12),

          // Category Dropdown
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedCategory != null
                    ? AppColors.primary
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TicketCategory?>(
                value: selectedCategory,
                hint: const Text('All Categories', style: TextStyle(fontSize: 13)),
                icon: const Icon(Icons.arrow_drop_down, size: 20),
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: [
                  const DropdownMenuItem<TicketCategory?>(
                    value: null,
                    child: Text('All Categories'),
                  ),
                  ...TicketCategory.values.map(
                    (cat) => DropdownMenuItem<TicketCategory?>(
                      value: cat,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                          Text(cat.displayName),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: onCategoryChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
