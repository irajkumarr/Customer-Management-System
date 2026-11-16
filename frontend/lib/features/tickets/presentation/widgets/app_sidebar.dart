import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/ticket_enums.dart';
import '../bloc/ticket_list_cubit.dart';
import '../bloc/ticket_list_state.dart';

class AppSidebar extends StatelessWidget {
  final bool isDrawer;
  final bool isRail;

  const AppSidebar({
    super.key,
    this.isDrawer = false,
    this.isRail = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isRail) {
      return _AppSidebarRail(isDrawer: isDrawer);
    }
    return _AppSidebarFull(isDrawer: isDrawer);
  }
}

class _AppSidebarFull extends StatelessWidget {
  final bool isDrawer;

  const _AppSidebarFull({required this.isDrawer});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: isDrawer ? 280 : 240,
      decoration: BoxDecoration(
        color: tokens.sidebarBg,
        border: isDrawer
            ? null
            : Border(
                right: BorderSide(color: tokens.sidebarBorder),
              ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Brand Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 6,
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
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Helpdesk',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
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

            const Divider(height: 1),

            // Admin User Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  final admin = authState is Authenticated ? authState.admin : null;
                  final adminUsername = admin?.username ?? 'admin';
                  final roleName = admin?.role.displayName ?? 'Administrator';

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: tokens.cardBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            adminUsername.isNotEmpty ? adminUsername.substring(0, 1).toUpperCase() : 'A',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Single Session',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: tokens.subtleText,
                                ),
                              ),
                            ],
                          ),
                        ),
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

            const Divider(height: 1),

            // Navigation Queue Views
            Expanded(
              child: BlocBuilder<TicketListCubit, TicketListState>(
                builder: (context, state) {
                  final cubit = context.read<TicketListCubit>();
                  final stats = state.stats;

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 6, bottom: 6),
                        child: Text(
                          'TICKET QUEUES',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: tokens.subtleText,
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

                      // Escalated to Human (High Priority)
                      _SidebarNavItem(
                        icon: Icons.warning_amber_rounded,
                        label: 'Escalated to Human',
                        iconColor: tokens.statusEscalated,
                        count: stats?.escalatedToHuman,
                        countBadgeColor: (stats?.escalatedToHuman ?? 0) > 0 ? tokens.statusEscalated : null,
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
                        iconColor: tokens.statusInProgress,
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
                        iconColor: tokens.statusNew,
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
                        iconColor: tokens.statusAiProcessing,
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
                        iconColor: tokens.statusResolved,
                        count: stats?.resolved,
                        isSelected: state.selectedStatus == TicketStatus.RESOLVED,
                        onTap: () {
                          cubit.setStatusFilter(TicketStatus.RESOLVED);
                          if (isDrawer) Navigator.of(context).maybePop();
                        },
                      ),

                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(left: 6, bottom: 6),
                        child: Text(
                          'SYSTEM TELEMETRY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: tokens.subtleText,
                          ),
                        ),
                      ),

                      // Operational telemetry info
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: tokens.cardBorder),
                        ),
                        child: Column(
                          children: [
                            _SystemTelemetryRow(
                              name: 'AI Engine',
                              value: 'Gemini 1.5 RAG',
                              icon: Icons.auto_awesome,
                              iconColor: tokens.statusAiProcessing,
                            ),
                            const SizedBox(height: 6),
                            _SystemTelemetryRow(
                              name: 'Email Gateway',
                              value: 'Mailgun REST',
                              icon: Icons.email_outlined,
                              iconColor: tokens.statusResolved,
                            ),
                            const SizedBox(height: 6),
                            _SystemTelemetryRow(
                              name: 'Sync Protocol',
                              value: 'Manual Refresh',
                              icon: Icons.refresh_rounded,
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

            // Sign Out Footer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: tokens.sidebarBorder)),
              ),
              child: Column(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(36),
                      foregroundColor: tokens.statusEscalated,
                      side: BorderSide(color: tokens.statusEscalated.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 15),
                    label: const Text('Sign Out', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      if (isDrawer) Navigator.of(context).maybePop();
                      context.read<AuthCubit>().logout();
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'AI Helpdesk • Clean Architecture',
                    style: TextStyle(fontSize: 10, color: tokens.subtleText),
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

class _AppSidebarRail extends StatelessWidget {
  final bool isDrawer;

  const _AppSidebarRail({required this.isDrawer});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      width: 68,
      decoration: BoxDecoration(
        color: tokens.sidebarBg,
        border: Border(right: BorderSide(color: tokens.sidebarBorder)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Brand Icon
            Tooltip(
              message: 'AI Helpdesk',
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),

            // Nav Icons
            Expanded(
              child: BlocBuilder<TicketListCubit, TicketListState>(
                builder: (context, state) {
                  final cubit = context.read<TicketListCubit>();
                  final stats = state.stats;

                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _RailNavItem(
                        icon: Icons.all_inbox_rounded,
                        tooltip: 'All Tickets (${stats?.total ?? 0})',
                        count: stats?.total,
                        isSelected: state.selectedStatus == null && state.selectedCategory == null,
                        onTap: () {
                          cubit.setStatusFilter(null);
                          cubit.setCategoryFilter(null);
                        },
                      ),
                      _RailNavItem(
                        icon: Icons.warning_amber_rounded,
                        tooltip: 'Escalated to Human (${stats?.escalatedToHuman ?? 0})',
                        iconColor: tokens.statusEscalated,
                        count: stats?.escalatedToHuman,
                        badgeColor: (stats?.escalatedToHuman ?? 0) > 0 ? tokens.statusEscalated : null,
                        isSelected: state.selectedStatus == TicketStatus.ESCALATED_TO_HUMAN,
                        onTap: () => cubit.setStatusFilter(TicketStatus.ESCALATED_TO_HUMAN),
                      ),
                      _RailNavItem(
                        icon: Icons.hourglass_top_rounded,
                        tooltip: 'In Progress (${stats?.inProgress ?? 0})',
                        iconColor: tokens.statusInProgress,
                        count: stats?.inProgress,
                        isSelected: state.selectedStatus == TicketStatus.IN_PROGRESS,
                        onTap: () => cubit.setStatusFilter(TicketStatus.IN_PROGRESS),
                      ),
                      _RailNavItem(
                        icon: Icons.mark_email_unread_rounded,
                        tooltip: 'New Tickets (${stats?.newTickets ?? 0})',
                        iconColor: tokens.statusNew,
                        count: stats?.newTickets,
                        isSelected: state.selectedStatus == TicketStatus.NEW,
                        onTap: () => cubit.setStatusFilter(TicketStatus.NEW),
                      ),
                      _RailNavItem(
                        icon: Icons.auto_awesome_rounded,
                        tooltip: 'AI Replied (${stats?.aiReplied ?? 0})',
                        iconColor: tokens.statusAiProcessing,
                        count: stats?.aiReplied,
                        isSelected: state.selectedStatus == TicketStatus.AI_REPLIED,
                        onTap: () => cubit.setStatusFilter(TicketStatus.AI_REPLIED),
                      ),
                      _RailNavItem(
                        icon: Icons.check_circle_outline_rounded,
                        tooltip: 'Resolved (${stats?.resolved ?? 0})',
                        iconColor: tokens.statusResolved,
                        count: stats?.resolved,
                        isSelected: state.selectedStatus == TicketStatus.RESOLVED,
                        onTap: () => cubit.setStatusFilter(TicketStatus.RESOLVED),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Sign out icon
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: IconButton(
                icon: Icon(Icons.logout_rounded, size: 20, color: tokens.statusEscalated),
                tooltip: 'Sign Out',
                onPressed: () => context.read<AuthCubit>().logout(),
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
    final tokens = context.tokens;
    final isDark = theme.brightness == Brightness.dark;

    final activeBg = AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08);
    final activeTextColor = isDark ? Colors.white : AppColors.primary;
    final inactiveTextColor = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Material(
        color: isSelected ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isSelected
                      ? AppColors.primary
                      : (iconColor ?? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? activeTextColor : inactiveTextColor,
                    ),
                  ),
                ),
                if (count != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: countBadgeColor?.withValues(alpha: 0.15) ??
                          (isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: countBadgeColor ??
                            (isSelected ? AppColors.primary : tokens.subtleText),
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

class _RailNavItem extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color? iconColor;
  final int? count;
  final Color? badgeColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _RailNavItem({
    required this.icon,
    required this.tooltip,
    this.iconColor,
    this.count,
    this.badgeColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? AppColors.primary
                        : (iconColor ?? tokens.subtleText),
                  ),
                ),
                if (count != null && count! > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: badgeColor ?? AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      child: Text(
                        count! > 99 ? '99+' : count.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

class _SystemTelemetryRow extends StatelessWidget {
  final String name;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _SystemTelemetryRow({
    required this.name,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: tokens.subtleText,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
