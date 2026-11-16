import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
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
            color: AppColors.statusEscalated,
            icon: Icons.warning_amber_rounded,
            isSelected: selectedStatus == TicketStatus.ESCALATED_TO_HUMAN,
            onTap: () => onStatusSelected(
              selectedStatus == TicketStatus.ESCALATED_TO_HUMAN ? null : TicketStatus.ESCALATED_TO_HUMAN,
            ),
          ),
          _StatCard(
            title: 'AI Replied',
            count: stats!.aiReplied,
            color: AppColors.statusAiReplied,
            icon: Icons.auto_awesome_rounded,
            isSelected: selectedStatus == TicketStatus.AI_REPLIED,
            onTap: () => onStatusSelected(
              selectedStatus == TicketStatus.AI_REPLIED ? null : TicketStatus.AI_REPLIED,
            ),
          ),
          _StatCard(
            title: 'In Progress',
            count: stats!.inProgress,
            color: AppColors.statusInProgress,
            icon: Icons.timelapse_rounded,
            isSelected: selectedStatus == TicketStatus.IN_PROGRESS,
            onTap: () => onStatusSelected(
              selectedStatus == TicketStatus.IN_PROGRESS ? null : TicketStatus.IN_PROGRESS,
            ),
          ),
          _StatCard(
            title: 'Resolved',
            count: stats!.resolved,
            color: AppColors.statusResolved,
            icon: Icons.check_circle_outline_rounded,
            isSelected: selectedStatus == TicketStatus.RESOLVED,
            onTap: () => onStatusSelected(
              selectedStatus == TicketStatus.RESOLVED ? null : TicketStatus.RESOLVED,
            ),
          ),
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: cards
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 170,
                      child: c,
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: isDark ? 0.2 : 0.1)
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 20, color: color),
                  Text(
                    '$count',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
