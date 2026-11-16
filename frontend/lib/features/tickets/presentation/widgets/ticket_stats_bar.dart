import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
import '../../data/models/ticket_enums.dart';
import '../../domain/entities/ticket_stats_entity.dart';

class TicketStatsBar extends StatelessWidget {
  final TicketStatsEntity? stats;
  final TicketStatus? selectedStatus;
  final ValueChanged<TicketStatus?> onStatusSelected;

  const TicketStatsBar({
    super.key,
    required this.stats,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const SizedBox.shrink();
    }

    final tokens = context.tokens;

    final cards = [
      _StatCard(
        title: 'Total Tickets',
        count: stats!.total,
        color: AppColors.primary,
        icon: Icons.inbox_rounded,
        isSelected: selectedStatus == null,
        onTap: () => onStatusSelected(null),
      ),
      _StatCard(
        title: 'Escalated to Human',
        count: stats!.escalatedToHuman,
        color: tokens.statusEscalated,
        icon: Icons.warning_amber_rounded,
        isSelected: selectedStatus == TicketStatus.ESCALATED_TO_HUMAN,
        onTap: () => onStatusSelected(
          selectedStatus == TicketStatus.ESCALATED_TO_HUMAN ? null : TicketStatus.ESCALATED_TO_HUMAN,
        ),
      ),
      _StatCard(
        title: 'AI Replied',
        count: stats!.aiReplied,
        color: tokens.statusAiProcessing,
        icon: Icons.auto_awesome_rounded,
        isSelected: selectedStatus == TicketStatus.AI_REPLIED,
        onTap: () => onStatusSelected(
          selectedStatus == TicketStatus.AI_REPLIED ? null : TicketStatus.AI_REPLIED,
        ),
      ),
      _StatCard(
        title: 'In Progress',
        count: stats!.inProgress,
        color: tokens.statusInProgress,
        icon: Icons.timelapse_rounded,
        isSelected: selectedStatus == TicketStatus.IN_PROGRESS,
        onTap: () => onStatusSelected(
          selectedStatus == TicketStatus.IN_PROGRESS ? null : TicketStatus.IN_PROGRESS,
        ),
      ),
      _StatCard(
        title: 'Resolved',
        count: stats!.resolved,
        color: tokens.statusResolved,
        icon: Icons.check_circle_outline_rounded,
        isSelected: selectedStatus == TicketStatus.RESOLVED,
        onTap: () => onStatusSelected(
          selectedStatus == TicketStatus.RESOLVED ? null : TicketStatus.RESOLVED,
        ),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: cards
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: 160,
                  child: c,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: isDark ? 0.2 : 0.08)
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : tokens.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 18, color: color),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: tokens.subtleText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
