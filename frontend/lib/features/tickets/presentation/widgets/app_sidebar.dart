import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/ticket_enums.dart';
import '../bloc/ticket_list_cubit.dart';
import '../bloc/ticket_list_state.dart';

class AppSidebar extends StatelessWidget {
  final bool isDrawer;

  const AppSidebar({
    super.key,
    this.isDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: bgColor,
        border: isDrawer
            ? null
            : Border(
                right: BorderSide(color: borderColor),
              ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // App Header / Brand
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Helpdesk',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Admin Operations',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, indent: 16, endIndent: 16),

            // Admin Profile Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  final admin = authState is Authenticated ? authState.admin : null;
                  final adminUsername = admin?.username ?? 'admin';
                  final roleName = admin?.role.displayName ?? 'Administrator';

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            adminUsername.isNotEmpty ? adminUsername.substring(0, 1).toUpperCase() : 'A',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                adminUsername,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Single Admin Session',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            roleName,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1, indent: 16, endIndent: 16),

            // Navigation / Status Filters
            Expanded(
              child: BlocBuilder<TicketListCubit, TicketListState>(
                builder: (context, state) {
                  final cubit = context.read<TicketListCubit>();
                  final stats = state.stats;

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 8),
                        child: Text(
                          'TICKET VIEWS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),

                      // All Tickets
                      _SidebarNavItem(
                        icon: Icons.all_inbox_rounded,
                        label: 'All Tickets',
                        count: stats?.total,
                        isSelected: state.selectedStatus == null && state.selectedCategory == null,
                        onTap: () {
                          cubit.setStatusFilter(null);
                          cubit.setCategoryFilter(null);
                          if (isDrawer) Navigator.of(context).maybePop();
                        },
                      ),

                      // Escalated to Human
                      _SidebarNavItem(
                        icon: Icons.warning_amber_rounded,
                        label: 'Escalated to Human',
                        iconColor: AppColors.statusEscalated,
                        count: stats?.escalatedToHuman,
                        countBadgeColor: (stats?.escalatedToHuman ?? 0) > 0 ? AppColors.statusEscalated : null,
                        isSelected: state.selectedStatus == TicketStatus.ESCALATED_TO_HUMAN,
                        onTap: () {
                          cubit.setStatusFilter(TicketStatus.ESCALATED_TO_HUMAN);
                          if (isDrawer) Navigator.of(context).maybePop();
                        },
                      ),

                      // In Progress
                      _SidebarNavItem(
                        icon: Icons.hourglass_top_rounded,
                        label: 'In Progress',
                        iconColor: AppColors.statusInProgress,
                        count: stats?.inProgress,
                        isSelected: state.selectedStatus == TicketStatus.IN_PROGRESS,
                        onTap: () {
                          cubit.setStatusFilter(TicketStatus.IN_PROGRESS);
                          if (isDrawer) Navigator.of(context).maybePop();
                        },
                      ),

                      // New Tickets
                      _SidebarNavItem(
                        icon: Icons.mark_email_unread_rounded,
                        label: 'New Tickets',
                        iconColor: AppColors.statusNew,
                        count: stats?.newTickets,
                        isSelected: state.selectedStatus == TicketStatus.NEW,
                        onTap: () {
                          cubit.setStatusFilter(TicketStatus.NEW);
                          if (isDrawer) Navigator.of(context).maybePop();
                        },
                      ),

                      // AI Replied
                      _SidebarNavItem(
                        icon: Icons.auto_awesome_rounded,
                        label: 'AI Replied',
                        iconColor: AppColors.statusAiReplied,
                        count: stats?.aiReplied,
                        isSelected: state.selectedStatus == TicketStatus.AI_REPLIED,
                        onTap: () {
                          cubit.setStatusFilter(TicketStatus.AI_REPLIED);
                          if (isDrawer) Navigator.of(context).maybePop();
                        },
                      ),

                      // Resolved
                      _SidebarNavItem(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Resolved',
                        iconColor: AppColors.statusResolved,
                        count: stats?.resolved,
                        isSelected: state.selectedStatus == TicketStatus.RESOLVED,
                        onTap: () {
                          cubit.setStatusFilter(TicketStatus.RESOLVED);
                          if (isDrawer) Navigator.of(context).maybePop();
                        },
                      ),

                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 8),
                        child: Text(
                          'SYSTEM STATUS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),

                      // Integration Status Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          children: [
                            _SystemStatusRow(
                              name: 'Gemini 1.5 RAG',
                              status: 'Active',
                              isActive: true,
                              icon: Icons.auto_awesome,
                              iconColor: const Color(0xFF8B5CF6),
                            ),
                            const SizedBox(height: 8),
                            _SystemStatusRow(
                              name: 'Mailgun Webhooks',
                              status: 'Ingesting',
                              isActive: true,
                              icon: Icons.mark_email_read_rounded,
                              iconColor: const Color(0xFF10B981),
                            ),
                            const SizedBox(height: 8),
                            _SystemStatusRow(
                              name: 'Sync Mode',
                              status: 'Manual REST',
                              isActive: true,
                              icon: Icons.sync_rounded,
                              iconColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Bottom bar: Sign out and version
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor),
                ),
              ),
              child: Column(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      foregroundColor: AppColors.statusEscalated,
                      side: BorderSide(
                        color: AppColors.statusEscalated.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    label: const Text('Sign Out'),
                    onPressed: () {
                      if (isDrawer) Navigator.of(context).maybePop();
                      context.read<AuthCubit>().logout();
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI Helpdesk v1.0 • Clean Architecture',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final int? count;
  final Color? countBadgeColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    this.iconColor,
    this.count,
    this.countBadgeColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeBg = AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1);
    final activeTextColor = isDark ? Colors.white : AppColors.primary;
    final inactiveTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? AppColors.primary
                      : (iconColor ?? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? activeTextColor : inactiveTextColor,
                    ),
                  ),
                ),
                if (count != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: countBadgeColor?.withValues(alpha: 0.15) ??
                          (isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: countBadgeColor ??
                            (isSelected
                                ? AppColors.primary
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SystemStatusRow extends StatelessWidget {
  final String name;
  final String status;
  final bool isActive;
  final IconData icon;
  final Color iconColor;

  const _SystemStatusRow({
    required this.name,
    required this.status,
    required this.isActive,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
