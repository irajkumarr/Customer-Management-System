import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Background selection & hover states
    Color bgColor = Colors.transparent;
    if (widget.isSelected) {
      bgColor = isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    } else if (_isHovered) {
      bgColor = isDark ? const Color(0xFF18181B) : const Color(0xFFFAFAFA);
    }

    final customerTitle = widget.ticket.customerName != null &&
            widget.ticket.customerName!.trim().isNotEmpty
        ? widget.ticket.customerName!.trim()
        : widget.ticket.customerEmail;

    final customerInitial = customerTitle.isNotEmpty
        ? customerTitle.substring(0, 1).toUpperCase()
        : 'C';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              bottom: BorderSide(color: tokens.dividerColor, width: 1),
              left: widget.isSelected
                  ? const BorderSide(color: AppColors.neutral900, width: 3)
                  : BorderSide.none,
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            widget.isSelected ? 13 : 16,
            12,
            16,
            12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top line: Avatar circle + Customer Name + Relative Timestamp
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      customerInitial,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      customerTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: widget.isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        letterSpacing: -0.1,
                        color: isDark ? Colors.white : AppColors.neutral950,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormatter.formatRelativeOrTime(widget.ticket.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: tokens.subtleText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // Middle line: Subject (truncated, scannable)
              Text(
                widget.ticket.subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                  color: isDark ? const Color(0xFFD4D4D8) : AppColors.neutral700,
                ),
              ),
              const SizedBox(height: 7),

              // Bottom line: Status Pill + Category Tag
              Row(
                children: [
                  _StatusPill(status: widget.ticket.status),
                  const SizedBox(width: 6),
                  _CategoryTag(category: widget.ticket.category),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final TicketStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;

    switch (status) {
      case TicketStatus.ESCALATED_TO_HUMAN:
        bg = AppColors.statusEscalatedBg;
        border = AppColors.statusEscalatedBorder;
        text = AppColors.statusEscalated;
        break;
      case TicketStatus.AI_REPLIED:
        bg = AppColors.statusAiRepliedBg;
        border = AppColors.statusAiRepliedBorder;
        text = AppColors.statusAiReplied;
        break;
      case TicketStatus.IN_PROGRESS:
        bg = AppColors.statusInProgressBg;
        border = AppColors.statusInProgressBorder;
        text = AppColors.statusInProgress;
        break;
      case TicketStatus.RESOLVED:
        bg = AppColors.statusResolvedBg;
        border = AppColors.statusResolvedBorder;
        text = AppColors.statusResolved;
        break;
      case TicketStatus.AI_PROCESSING:
        bg = AppColors.statusAiProcessingBg;
        border = AppColors.statusAiProcessingBorder;
        text = AppColors.statusAiProcessing;
        break;
      case TicketStatus.NEW:
        bg = AppColors.statusNewBg;
        border = AppColors.statusNewBorder;
        text = AppColors.statusNew;
        break;
      case TicketStatus.CLOSED:
        bg = AppColors.statusClosedBg;
        border = AppColors.statusClosedBorder;
        text = AppColors.statusClosed;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final TicketCategory category;

  const _CategoryTag({required this.category});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isDark ? const Color(0xFF27272A) : AppColors.neutral200,
          width: 0.8,
        ),
      ),
      child: Text(
        category.displayName,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
          color: tokens.subtleText,
        ),
      ),
    );
  }
}
