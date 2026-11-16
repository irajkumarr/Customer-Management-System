import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/ticket_enums.dart';
import '../../domain/entities/ticket_detail_entity.dart';

class TicketHeaderCard extends StatelessWidget {
  final TicketDetailEntity ticket;
  final ValueChanged<TicketStatus> onStatusChanged;
  final ValueChanged<TicketCategory> onCategoryChanged;
  final bool isUpdatingStatus;
  final bool isUpdatingCategory;

  const TicketHeaderCard({
    super.key,
    required this.ticket,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    this.isUpdatingStatus = false,
    this.isUpdatingCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with Subject and Timestamps
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  ticket.subject,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Created: ${DateFormatter.formatDateTime(ticket.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Updated: ${DateFormatter.formatDateTime(ticket.updatedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Customer info line
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                ticket.customer.name != null && ticket.customer.name!.isNotEmpty
                    ? '${ticket.customer.name} • '
                    : '',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              SelectableText(
                ticket.customer.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action row: Status changer, Category changer, and Quick "Take Over" action
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Status selector
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Status: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: ticket.status.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ticket.status.color.withValues(alpha: 0.3)),
                    ),
                    child: isUpdatingStatus
                        ? const Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<TicketStatus>(
                              value: ticket.status,
                              icon: const Icon(Icons.arrow_drop_down, size: 18),
                              style: TextStyle(
                                color: ticket.status.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              items: TicketStatus.values.map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: s.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        s.displayName,
                                        style: TextStyle(color: s.color),
                                      ),
                                    ],
                                  ),
                                ),
                              ).toList(),
                              onChanged: (newStatus) {
                                if (newStatus != null) onStatusChanged(newStatus);
                              },
                            ),
                          ),
                  ),
                ],
              ),

              // Category selector
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Category: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                    ),
                    child: isUpdatingCategory
                        ? const Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<TicketCategory>(
                              value: ticket.category,
                              icon: const Icon(Icons.arrow_drop_down, size: 18),
                              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                              items: TicketCategory.values.map(
                                (cat) => DropdownMenuItem(
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
                                      Text(cat.displayName),
                                    ],
                                  ),
                                ),
                              ).toList(),
                              onChanged: (newCat) {
                                if (newCat != null) onCategoryChanged(newCat);
                              },
                            ),
                          ),
                  ),
                ],
              ),

              // Quick action if Escalated to Human
              if (ticket.status == TicketStatus.ESCALATED_TO_HUMAN) ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.pan_tool_rounded, size: 14),
                  label: const Text('Take Over Ticket', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusEscalated,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: isUpdatingStatus
                      ? null
                      : () => onStatusChanged(TicketStatus.IN_PROGRESS),
                ),
              ],

              // Quick action if In Progress -> Resolve
              if (ticket.status == TicketStatus.IN_PROGRESS) ...[
                OutlinedButton.icon(
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.statusResolved),
                  label: const Text('Mark Resolved', style: TextStyle(fontSize: 12, color: AppColors.statusResolved)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: const BorderSide(color: AppColors.statusResolved),
                  ),
                  onPressed: isUpdatingStatus
                      ? null
                      : () => onStatusChanged(TicketStatus.RESOLVED),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
