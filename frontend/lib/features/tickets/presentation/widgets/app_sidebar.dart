import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
            // CognitiveDesk Brand Header (Image 1 & 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'CognitiveDesk',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: -0.4,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Navigation Items matching CognitiveDesk
            Expanded(
              child: BlocBuilder<TicketListCubit, TicketListState>(
                builder: (context, state) {
                  final cubit = context.read<TicketListCubit>();
                  final stats = state.stats;
                  final totalCount = stats?.total ?? 12;

                  String currentPath = '';
                  try {
                    currentPath = GoRouterState.of(context).matchedLocation;
                  } catch (_) {
                    currentPath = '/tickets';
                  }
                  final isOverviewRoute = currentPath == '/overview' || currentPath == '/';

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    children: [
                      // Overview Nav Item
                      _CognitiveDeskNavItem(
                        icon: Icons.bar_chart_rounded,
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

                      // Tickets Queue Nav Item
                      _CognitiveDeskNavItem(
                        icon: Icons.inbox_outlined,
                        label: 'Tickets',
                        badgeText: '$totalCount',
                        isSelected: !isOverviewRoute && state.selectedStatus == null && state.selectedCategory == null,
                        onTap: () {
                          cubit.setStatusFilter(null);
                          cubit.setCategoryFilter(null);
                          if (isDrawer) Navigator.of(context).maybePop();
                          try {
                            context.go('/tickets');
                          } catch (_) {}
                        },
                      ),
                      const SizedBox(height: 2),

                      // Knowledge Base Nav Item
                      _CognitiveDeskNavItem(
                        icon: Icons.psychology_outlined,
                        label: 'Knowledge',
                        isSelected: false,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Knowledge Base: Connected to Spring AI pgvector RAG store.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 2),

                      // Settings Nav Item
                      _CognitiveDeskNavItem(
                        icon: Icons.tune_rounded,
                        label: 'Settings',
                        isSelected: false,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Settings: Spring Boot session auth & Mailgun routes active.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, bottom: 6),
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
                        color: tokens.statusEscalated,
                        isSelected: !isOverviewRoute && state.selectedStatus == TicketStatus.ESCALATED_TO_HUMAN,
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
                        color: tokens.statusInProgress,
                        isSelected: !isOverviewRoute && state.selectedStatus == TicketStatus.IN_PROGRESS,
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
                        color: tokens.statusAiProcessing,
                        isSelected: !isOverviewRoute && state.selectedStatus == TicketStatus.AI_REPLIED,
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
                        color: tokens.statusResolved,
                        isSelected: !isOverviewRoute && state.selectedStatus == TicketStatus.RESOLVED,
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

            const Divider(height: 1),

            // CognitiveDesk Bottom Admin Profile (Image 1 & 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  return InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Admin Operations'),
                          content: const Text('Logged in via Spring Security Session with Mailgun email delivery.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Close'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                context.read<AuthCubit>().logout();
                              },
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        children: [
                          // Avatar Circle with AD
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFFEEF2FF),
                            child: const Text(
                              'AD',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Ops',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Gemini 1.5 Active',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Online Green Dot
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _AppSidebarRail extends StatelessWidget {
  final bool isDrawer;

  const _AppSidebarRail({required this.isDrawer});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    String currentPath = '';
    try {
      currentPath = GoRouterState.of(context).matchedLocation;
    } catch (_) {
      currentPath = '/tickets';
    }
    final isOverviewRoute = currentPath == '/overview' || currentPath == '/';

    return Container(
      width: 68,
      decoration: BoxDecoration(
        color: tokens.sidebarBg,
        border: Border(right: BorderSide(color: tokens.sidebarBorder)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            // Brand Icon
            Tooltip(
              message: 'CognitiveDesk',
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),

            // Rail Nav Icons
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _RailIconItem(
                    icon: Icons.bar_chart_rounded,
                    tooltip: 'Overview',
                    isSelected: isOverviewRoute,
                    onTap: () {
                      try {
                        context.go('/overview');
                      } catch (_) {}
                    },
                  ),
                  _RailIconItem(
                    icon: Icons.inbox_outlined,
                    tooltip: 'Tickets Queue',
                    isSelected: !isOverviewRoute,
                    onTap: () {
                      try {
                        context.go('/tickets');
                      } catch (_) {}
                    },
                  ),
                  _RailIconItem(
                    icon: Icons.psychology_outlined,
                    tooltip: 'Knowledge Base',
                    isSelected: false,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Knowledge Base: Connected to Spring AI pgvector RAG store.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  _RailIconItem(
                    icon: Icons.tune_rounded,
                    tooltip: 'Settings',
                    isSelected: false,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings: Spring Boot session auth & Mailgun routes active.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            // Admin Ops Circle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Tooltip(
                message: 'Admin Ops (Gemini 1.5 Active)',
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: const Text('AD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CognitiveDeskNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badgeText;
  final bool isSelected;
  final VoidCallback onTap;

  const _CognitiveDeskNavItem({
    required this.icon,
    required this.label,
    this.badgeText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
                  ),
                ),
              ),
              if (badgeText != null)
                Text(
                  badgeText!,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueSubItem extends StatelessWidget {
  final String label;
  final int? count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _QueueSubItem({
    required this.label,
    this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.circle, size: 6, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                ),
              ),
            ),
            if (count != null)
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : const Color(0xFF94A3B8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RailIconItem extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  const _RailIconItem({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
