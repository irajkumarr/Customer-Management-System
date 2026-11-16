import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top App Brand (Linear style)
            Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: tokens.dividerColor)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.neutral900,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AI Helpdesk',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: isDark ? Colors.white : AppColors.neutral950,
                    ),
                  ),
                ],
              ),
            ),

            // Navigation items & Queue views
            Expanded(
              child: BlocBuilder<TicketListCubit, TicketListState>(
                builder: (context, state) {
                  final cubit = context.read<TicketListCubit>();
                  final stats = state.stats;
                  final totalCount = stats?.total ?? state.totalElements;

                  String currentPath = '';
                  try {
                    currentPath = GoRouterState.of(context).matchedLocation;
                  } catch (_) {
                    currentPath = '/tickets';
                  }
                  final isOverviewRoute = currentPath == '/overview' || currentPath == '/';
                  final isTicketsRoute = currentPath.startsWith('/tickets');

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    children: [
                      // Overview Link
                      _SidebarNavItem(
                        icon: Icons.dashboard_outlined,
                        label: 'Overview',
                        isSelected: isOverviewRoute,
                        onTap: () {
                          cubit.setStatusFilter(null);
                          cubit.setCategoryFilter(null);
                          if (isDrawer) Navigator.of(context).maybePop();
                          try {
                            context.go('/overview');
                          } catch (_) {}
                        },
                      ),
                      const SizedBox(height: 2),

                      // Tickets Link
                      _SidebarNavItem(
                        icon: Icons.inbox_outlined,
                        label: 'All Tickets',
                        badgeText: totalCount > 0 ? '$totalCount' : null,
                        isSelected: isTicketsRoute &&
                            state.selectedStatus == null &&
                            state.selectedCategory == null,
                        onTap: () {
                          cubit.setStatusFilter(null);
                          cubit.setCategoryFilter(null);
                          if (isDrawer) Navigator.of(context).maybePop();
                          try {
                            context.go('/tickets');
                          } catch (_) {}
                        },
                      ),

                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Text(
                          'QUEUE VIEWS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: tokens.subtleText,
                          ),
                        ),
                      ),

                      // Escalated to Human
                      _QueueSubItem(
                        label: 'Escalated to Human',
                        count: stats?.escalatedToHuman,
                        dotColor: tokens.statusEscalated,
                        isSelected: isTicketsRoute &&
                            state.selectedStatus == TicketStatus.ESCALATED_TO_HUMAN,
                        onTap: () {
                          cubit.setStatusFilter(TicketStatus.ESCALATED_TO_HUMAN);
                          if (isDrawer) Navigator.of(context).maybePop();
                          try {
                            context.go('/tickets');
                          } catch (_) {}
                        },
                      ),

                      // In Progress
                      _QueueSubItem(
                        label: 'In Progress',
                        count: stats?.inProgress,
                        dotColor: tokens.statusInProgress,
                        isSelected: isTicketsRoute &&
                            state.selectedStatus == TicketStatus.IN_PROGRESS,
                        onTap: () {
                          cubit.setStatusFilter(TicketStatus.IN_PROGRESS);
                          if (isDrawer) Navigator.of(context).maybePop();
                          try {
                            context.go('/tickets');
                          } catch (_) {}
                        },
                      ),

                      // AI Replied
                      _QueueSubItem(
                        label: 'AI Replied',
                        count: stats?.aiReplied,
                        dotColor: tokens.statusAiReplied,
                        isSelected: isTicketsRoute &&
                            state.selectedStatus == TicketStatus.AI_REPLIED,
                        onTap: () {
                          cubit.setStatusFilter(TicketStatus.AI_REPLIED);
                          if (isDrawer) Navigator.of(context).maybePop();
                          try {
                            context.go('/tickets');
                          } catch (_) {}
                        },
                      ),

                      // Resolved
                      _QueueSubItem(
                        label: 'Resolved',
                        count: stats?.resolved,
                        dotColor: tokens.statusResolved,
                        isSelected: isTicketsRoute &&
                            state.selectedStatus == TicketStatus.RESOLVED,
                        onTap: () {
                          cubit.setStatusFilter(TicketStatus.RESOLVED);
                          if (isDrawer) Navigator.of(context).maybePop();
                          try {
                            context.go('/tickets');
                          } catch (_) {}
                        },
                      ),
                    ],
                  );
                },
              ),
            ),

            // Bottom Profile Box (Linear style)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: tokens.dividerColor)),
              ),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  final username =
                      authState is Authenticated ? authState.admin.username : 'Admin';

                  return Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.neutral200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          username.isNotEmpty
                              ? username.substring(0, 1).toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.neutral950,
                              ),
                            ),
                            Text(
                              'Admin Session',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: tokens.subtleText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, size: 16),
                        tooltip: 'Logout',
                        visualDensity: VisualDensity.compact,
                        color: tokens.subtleText,
                        onPressed: () {
                          context.read<AuthCubit>().logout();
                          context.go('/login');
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String? badgeText;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    this.badgeText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor = Colors.transparent;
    if (widget.isSelected) {
      bgColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    } else if (_isHovered) {
      bgColor = isDark ? const Color(0xFF1E1E22) : const Color(0xFFF4F4F5);
    }

    final textColor = widget.isSelected
        ? (isDark ? Colors.white : AppColors.neutral950)
        : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: widget.isSelected
                    ? (isDark ? Colors.white : AppColors.neutral950)
                    : tokens.subtleText,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (widget.badgeText != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.badgeText!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.neutral950,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueSubItem extends StatefulWidget {
  final String label;
  final int? count;
  final Color dotColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _QueueSubItem({
    required this.label,
    this.count,
    required this.dotColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_QueueSubItem> createState() => _QueueSubItemState();
}

class _QueueSubItemState extends State<_QueueSubItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor = Colors.transparent;
    if (widget.isSelected) {
      bgColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    } else if (_isHovered) {
      bgColor = isDark ? const Color(0xFF1E1E22) : const Color(0xFFF4F4F5);
    }

    final textColor = widget.isSelected
        ? (isDark ? Colors.white : AppColors.neutral950)
        : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          margin: const EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: widget.dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (widget.count != null && widget.count! > 0)
                Text(
                  '${widget.count}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                  ),
                ),
            ],
          ),
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
      width: 64,
      decoration: BoxDecoration(
        color: tokens.sidebarBg,
        border: Border(right: BorderSide(color: tokens.sidebarBorder)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.neutral900,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.dashboard_outlined, size: 20),
              tooltip: 'Overview',
              onPressed: () => context.go('/overview'),
            ),
            const SizedBox(height: 6),
            IconButton(
              icon: const Icon(Icons.inbox_outlined, size: 20),
              tooltip: 'Tickets',
              onPressed: () => context.go('/tickets'),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.logout_rounded, size: 18),
              tooltip: 'Logout',
              onPressed: () {
                context.read<AuthCubit>().logout();
                context.go('/login');
              },
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
