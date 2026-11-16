import 'package:flutter/material.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
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
    final tokens = context.tokens;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.cardBorder),
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
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Created: ${DateFormatter.formatDateTime(ticket.createdAt)}',
                    style: TextStyle(
                      color: tokens.subtleText,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Updated: ${DateFormatter.formatDateTime(ticket.updatedAt)}',
                    style: TextStyle(
                      color: tokens.subtleText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Customer Info Row
          Row(
            children: [
              Icon(Icons.person_pin_circle_rounded, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              if (ticket.customer.name != null && ticket.customer.name!.isNotEmpty) ...[
                Text(
                  '${ticket.customer.name!} • ',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
              SelectableText(
                ticket.customer.email,
                style: TextStyle(
                  color: tokens.subtleText,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Action row: Status selector, Category selector, Quick action buttons
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Status selector popup
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Status: ', style: TextStyle(fontSize: 12, color: tokens.subtleText, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 4),
                  if (isUpdatingStatus)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    PopupMenuButton<TicketStatus>(
                      tooltip: 'Change Status',
                      onSelected: onStatusChanged,
                      itemBuilder: (context) => TicketStatus.values.map(
                        (s) => PopupMenuItem(
                          value: s,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(s.displayName, style: TextStyle(color: s.color, fontSize: 13)),
                            ],
                          ),
                        ),
                      ).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: ticket.status.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: ticket.status.color.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(color: ticket.status.color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              ticket.status.displayName,
                              style: TextStyle(
                                color: ticket.status.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: ticket.status.color),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Category selector popup
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Category: ', style: TextStyle(fontSize: 12, color: tokens.subtleText, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 4),
                  if (isUpdatingCategory)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    PopupMenuButton<TicketCategory>(
                      tooltip: 'Change Category',
                      onSelected: onCategoryChanged,
                      itemBuilder: (context) => TicketCategory.values.map(
                        (c) => PopupMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(c.displayName, style: TextStyle(color: c.color, fontSize: 13)),
                            ],
                          ),
                        ),
                      ).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: ticket.category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: ticket.category.color.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(color: ticket.category.color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              ticket.category.displayName,
                              style: TextStyle(
                                color: ticket.category.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: ticket.category.color),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Quick action if Escalated to Human
              if (ticket.status == TicketStatus.ESCALATED_TO_HUMAN) ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.pan_tool_rounded, size: 13),
                  label: const Text('Take Over Ticket', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.statusEscalated,
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
                  icon: Icon(Icons.check_circle_outline_rounded, size: 14, color: tokens.statusResolved),
                  label: Text('Mark Resolved', style: TextStyle(fontSize: 12, color: tokens.statusResolved)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: BorderSide(color: tokens.statusResolved),
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
