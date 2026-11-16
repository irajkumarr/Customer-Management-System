import 'package:flutter/material.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/ticket_enums.dart';
import '../../domain/entities/ticket_entity.dart';

class TicketListItem extends StatefulWidget {
  final TicketEntity ticket;
  final VoidCallback onTap;
  final bool isSelected;

  const TicketListItem({
    super.key,
    required this.ticket,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<TicketListItem> createState() => _TicketListItemState();
}

class _TicketListItemState extends State<TicketListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final isDark = theme.brightness == Brightness.dark;
    final isEscalated = widget.ticket.status == TicketStatus.ESCALATED_TO_HUMAN;

    Color borderColor;
    if (widget.isSelected) {
      borderColor = theme.colorScheme.primary;
    } else if (_isHovered) {
      borderColor = tokens.cardHoverBorder;
    } else {
      borderColor = tokens.cardBorder;
    }

    Color bgColor;
    if (widget.isSelected) {
      bgColor = theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.05);
    } else if (_isHovered) {
      bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    } else {
      bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: widget.isSelected ? 1.5 : 1,
          ),
          boxShadow: _isHovered && !widget.isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // Left accent line if escalated
                if (isEscalated)
                  Positioned(
                    top: 10,
                    bottom: 10,
                    left: 0,
                    child: Container(
                      width: 3.5,
                      decoration: BoxDecoration(
                        color: tokens.statusEscalated,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(2),
                          bottomRight: Radius.circular(2),
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Status, Category, and Timestamp
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: widget.ticket.status.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: widget.ticket.status.color.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: widget.ticket.status.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          widget.ticket.status.displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: widget.ticket.status.color,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Category Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: widget.ticket.category.color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    widget.ticket.category.displayName,
                                    style: TextStyle(
                                      color: widget.ticket.category.color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Relative Time
                          Text(
                            DateFormatter.formatRelativeOrTime(widget.ticket.updatedAt),
                            style: TextStyle(
                              color: tokens.subtleText,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Subject
                      Text(
                        widget.ticket.subject,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                          letterSpacing: -0.2,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Customer Info
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: tokens.subtleText,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.ticket.customerName != null && widget.ticket.customerName!.isNotEmpty
                                  ? '${widget.ticket.customerName} (${widget.ticket.customerEmail})'
                                  : widget.ticket.customerEmail,
                              style: TextStyle(
                                color: tokens.subtleText,
                                fontSize: 11.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
