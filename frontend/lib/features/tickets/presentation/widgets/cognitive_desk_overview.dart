import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/ticket_enums.dart';
import '../../domain/entities/ticket_entity.dart';
import '../bloc/ticket_list_cubit.dart';
import '../bloc/ticket_list_state.dart';

class CognitiveDeskOverview extends StatefulWidget {
  final ValueChanged<String> onTicketSelected;
  final VoidCallback? onViewAll;

  const CognitiveDeskOverview({
    super.key,
    required this.onTicketSelected,
    this.onViewAll,
  });

  @override
  State<CognitiveDeskOverview> createState() => _CognitiveDeskOverviewState();
}

class _CognitiveDeskOverviewState extends State<CognitiveDeskOverview> {
  TicketStatus? _selectedStatusFilter;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<TicketListCubit, TicketListState>(
      builder: (context, state) {
        final stats = state.stats;
        final totalCount = stats?.total ?? state.tickets.length;
        final aiCount = stats?.aiReplied ?? 0;
        final escalatedCount = stats?.escalatedToHuman ?? 0;
        final inProgressCount = stats?.inProgress ?? 0;
        final resolvedCount = (stats?.resolved ?? 0) + (stats?.closed ?? 0);

        final autoResolvedRate = totalCount > 0
            ? ((aiCount / totalCount) * 100).toStringAsFixed(1)
            : '0.0';
        final escalatedRate = totalCount > 0
            ? ((escalatedCount / totalCount) * 100).toStringAsFixed(1)
            : '0.0';

        // Filter tickets for the table
        final filteredTickets = _selectedStatusFilter == null
            ? state.tickets
            : state.tickets
                  .where((t) => t.status == _selectedStatusFilter)
                  .toList();

        // Compute real category breakdown from stats or tickets
        final categoryCounts = <String, int>{};
        if (stats?.byCategory != null && stats!.byCategory.isNotEmpty) {
          categoryCounts.addAll(stats.byCategory);
        } else {
          for (final t in state.tickets) {
            final cat = t.category.displayName;
            categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
          }
        }

        final screenWidth = MediaQuery.sizeOf(context).width;
        final hPadding = screenWidth < 640 ? 14.0 : 24.0;
        final vPadding = screenWidth < 640 ? 14.0 : 20.0;

        return Container(
          color: isDark ? const Color(0xFF09090B) : const Color(0xFFF8FAFC),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
            children: [
              // 1. Top Breadcrumb & Actions Bar
              _buildTopHeaderBar(context, state, tokens, isDark),
              const SizedBox(height: 18),

              // 2. Metric KPI Cards Strip (ShipNova / Linear style with vertical bar distribution)
              _buildKpiMetricsStrip(
                totalCount: totalCount,
                aiCount: aiCount,
                escalatedCount: escalatedCount,
                inProgressCount: inProgressCount,
                resolvedCount: resolvedCount,
                autoResolvedRate: autoResolvedRate,
                escalatedRate: escalatedRate,
                tokens: tokens,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // 3. Main Dashboard Body: Left Ticket Table (65%) + Right Activity/Segments (35%)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 960;

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Ticket Activity Table
                        Expanded(
                          flex: 65,
                          child: _buildTicketsTableCard(
                            context: context,
                            tickets: filteredTickets,
                            tokens: tokens,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right: Recent Interactions & Category Segments
                        Expanded(
                          flex: 35,
                          child: Column(
                            children: [
                              _buildRecentActivityCard(
                                context: context,
                                tickets: state.tickets,
                                tokens: tokens,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              _buildCategorySegmentsCard(
                                categoryCounts: categoryCounts,
                                totalCount: totalCount,
                                tokens: tokens,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildTicketsTableCard(
                          context: context,
                          tickets: filteredTickets,
                          tokens: tokens,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildRecentActivityCard(
                          context: context,
                          tickets: state.tickets,
                          tokens: tokens,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildCategorySegmentsCard(
                          categoryCounts: categoryCounts,
                          totalCount: totalCount,
                          tokens: tokens,
                          isDark: isDark,
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 1. Top Header Bar
  Widget _buildTopHeaderBar(
    BuildContext context,
    TicketListState state,
    HelpdeskThemeTokens tokens,
    bool isDark,
  ) {
    final now = DateTime.now();
    final dateRangeStr =
        '${DateFormat('MMM d').format(now.subtract(const Duration(days: 30)))} - ${DateFormat('MMM d, yyyy').format(now)}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 640;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF18181B) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: tokens.cardBorder, width: 0.8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.dashboard_outlined,
                      size: 17,
                      color: isDark ? Colors.white : AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Support Overview',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : AppColors.neutral950,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Live helpdesk queue telemetry',
                          style: TextStyle(fontSize: 11, color: tokens.subtleText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Refresh Telemetry',
                    icon: state.isRefreshing
                        ? const SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(strokeWidth: 1.8),
                          )
                        : const Icon(Icons.refresh_rounded, size: 15),
                    onPressed: state.isRefreshing
                        ? null
                        : () => context.read<TicketListCubit>().refresh(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18181B) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: tokens.cardBorder, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: tokens.subtleText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateRangeStr,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppColors.neutral800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            // Title with Icon
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF18181B) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: tokens.cardBorder, width: 0.8),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.dashboard_outlined,
                size: 18,
                color: isDark ? Colors.white : AppColors.neutral900,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Support Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Live helpdesk queue telemetry & operational insights',
                  style: TextStyle(fontSize: 11.5, color: tokens.subtleText),
                ),
              ],
            ),
            const Spacer(),

            // Date Range Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF18181B) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: tokens.cardBorder, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: tokens.subtleText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateRangeStr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.neutral800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // REST Refresh Button
            IconButton.outlined(
              visualDensity: VisualDensity.compact,
              tooltip: 'Refresh Telemetry',
              icon: state.isRefreshing
                  ? const SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(strokeWidth: 1.8),
                    )
                  : const Icon(Icons.refresh_rounded, size: 15),
              onPressed: state.isRefreshing
                  ? null
                  : () => context.read<TicketListCubit>().refresh(),
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }

  // 2. KPI Metrics Strip (5 Connected Cards with Vertical Bar Distributions)
  Widget _buildKpiMetricsStrip({
    required int totalCount,
    required int aiCount,
    required int escalatedCount,
    required int inProgressCount,
    required int resolvedCount,
    required String autoResolvedRate,
    required String escalatedRate,
    required HelpdeskThemeTokens tokens,
    required bool isDark,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : 600.0;
        final cardWidth = availableWidth >= 1000
            ? (availableWidth - (4 * 10)) / 5
            : (availableWidth >= 540
                ? (availableWidth - 10) / 2
                : availableWidth);

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: cardWidth,
              child: _MetricCardItem(
                icon: Icons.people_outline_rounded,
                iconColor: const Color(0xFFF59E0B),
                label: 'Total Customers / Inbound',
                value: '$totalCount',
                trendText: 'All ingested tickets',
                trendColor: tokens.subtleText,
                barColor: const Color(0xFFF59E0B),
                barFillRatio: 0.85,
                tokens: tokens,
                isDark: isDark,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCardItem(
                icon: Icons.auto_awesome_rounded,
                iconColor: const Color(0xFF8B5CF6),
                label: 'AI Auto-Replied',
                value: '$aiCount',
                trendText: '$autoResolvedRate% resolution rate',
                trendColor: const Color(0xFF10B981),
                barColor: const Color(0xFF8B5CF6),
                barFillRatio: (totalCount > 0 ? aiCount / totalCount : 0.4)
                    .clamp(0.1, 1.0),
                tokens: tokens,
                isDark: isDark,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCardItem(
                icon: Icons.support_agent_rounded,
                iconColor: const Color(0xFFEF4444),
                label: 'Escalated to Human',
                value: '$escalatedCount',
                trendText: '$escalatedRate% handoff queue',
                trendColor: const Color(0xFFEF4444),
                barColor: const Color(0xFFEF4444),
                barFillRatio:
                    (totalCount > 0 ? escalatedCount / totalCount : 0.25).clamp(
                      0.1,
                      1.0,
                    ),
                tokens: tokens,
                isDark: isDark,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCardItem(
                icon: Icons.pending_actions_rounded,
                iconColor: const Color(0xFF3B82F6),
                label: 'Active In Progress',
                value: '$inProgressCount',
                trendText: 'Under investigation',
                trendColor: const Color(0xFF3B82F6),
                barColor: const Color(0xFF3B82F6),
                barFillRatio:
                    (totalCount > 0 ? inProgressCount / totalCount : 0.15)
                        .clamp(0.1, 1.0),
                tokens: tokens,
                isDark: isDark,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _MetricCardItem(
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF10B981),
                label: 'Resolved Cases',
                value: '$resolvedCount',
                trendText: 'Completed workflows',
                trendColor: const Color(0xFF10B981),
                barColor: const Color(0xFF10B981),
                barFillRatio:
                    (totalCount > 0 ? resolvedCount / totalCount : 0.6).clamp(
                      0.1,
                      1.0,
                    ),
                tokens: tokens,
                isDark: isDark,
              ),
            ),
          ],
        );
      },
    );
  }

  // 3. Left Table Card: Recent Ticket Activity with Filter Pills
  Widget _buildTicketsTableCard({
    required BuildContext context,
    required List<TicketEntity> tickets,
    required HelpdeskThemeTokens tokens,
    required bool isDark,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : 650.0;
        final isNarrow = availableWidth < 620;
        final tableWidth = availableWidth > 650 ? availableWidth : 650.0;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: tokens.cardBorder, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table Card Header
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                child: isNarrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Support Queue',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: isDark ? Colors.white : AppColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Live inbound ticket activity and triage status',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: tokens.subtleText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildFilterPill(
                                  label: 'All',
                                  status: null,
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 4),
                                _buildFilterPill(
                                  label: 'AI Replied',
                                  status: TicketStatus.AI_REPLIED,
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 4),
                                _buildFilterPill(
                                  label: 'Escalated',
                                  status: TicketStatus.ESCALATED_TO_HUMAN,
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 4),
                                _buildFilterPill(
                                  label: 'In Progress',
                                  status: TicketStatus.IN_PROGRESS,
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer Support Queue',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: isDark ? Colors.white : AppColors.neutral950,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Live inbound ticket activity and triage status',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: tokens.subtleText,
                                ),
                              ),
                            ],
                          ),

                          // Filter Pills (All, AI Replied, Escalated, In Progress, New)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildFilterPill(
                                label: 'All',
                                status: null,
                                isDark: isDark,
                              ),
                              const SizedBox(width: 4),
                              _buildFilterPill(
                                label: 'AI Replied',
                                status: TicketStatus.AI_REPLIED,
                                isDark: isDark,
                              ),
                              const SizedBox(width: 4),
                              _buildFilterPill(
                                label: 'Escalated',
                                status: TicketStatus.ESCALATED_TO_HUMAN,
                                isDark: isDark,
                              ),
                              const SizedBox(width: 4),
                              _buildFilterPill(
                                label: 'In Progress',
                                status: TicketStatus.IN_PROGRESS,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              const Divider(height: 1),

              // Table Body with Horizontal Scroll Container on Narrow Displays
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Column Headers
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        color: isDark ? const Color(0xFF141416) : const Color(0xFFFAFAFA),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: _colHeader('CUSTOMER')),
                            Expanded(flex: 4, child: _colHeader('SUBJECT')),
                            Expanded(flex: 2, child: _colHeader('CATEGORY')),
                            Expanded(flex: 3, child: _colHeader('STATUS')),
                            Expanded(
                              flex: 2,
                              child: _colHeader('TIME', align: TextAlign.right),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Table Rows
                      if (tickets.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No tickets match the selected filter.',
                              style: TextStyle(color: tokens.subtleText, fontSize: 12.5),
                            ),
                          ),
                        )
                      else
                        ...tickets.take(8).map((ticket) {
                          return _TableRowItem(
                            ticket: ticket,
                            tokens: tokens,
                            isDark: isDark,
                            onTap: () => widget.onTicketSelected(ticket.id),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterPill({
    required String label,
    required TicketStatus? status,
    required bool isDark,
  }) {
    final isSelected = _selectedStatusFilter == status;

    return InkWell(
      onTap: () => setState(() => _selectedStatusFilter = status),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : AppColors.neutral900)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark
                      ? const Color(0xFF27272A)
                      : const Color(0xFFE4E4E7),
                  width: 0.8,
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? (isDark ? AppColors.neutral950 : Colors.white)
                : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF52525B)),
          ),
        ),
      ),
    );
  }

  Widget _colHeader(String title, {TextAlign align = TextAlign.left}) {
    return Text(
      title,
      textAlign: align,
      style: const TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Color(0xFF71717A),
      ),
    );
  }

  // 4. Right Side Card: Recent Activity Feed
  Widget _buildRecentActivityCard({
    required BuildContext context,
    required List<TicketEntity> tickets,
    required HelpdeskThemeTokens tokens,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: isDark ? Colors.white : AppColors.neutral950,
                ),
              ),
              const Spacer(),
              Text(
                'Latest interactions',
                style: TextStyle(fontSize: 11, color: tokens.subtleText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          if (tickets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No activity yet',
                  style: TextStyle(color: tokens.subtleText, fontSize: 12),
                ),
              ),
            )
          else
            ...tickets.take(4).map((t) {
              final isAi = t.status == TicketStatus.AI_REPLIED;
              final isEscalated = t.status == TicketStatus.ESCALATED_TO_HUMAN;

              final iconColor = isAi
                  ? const Color(0xFF10B981)
                  : (isEscalated
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF3B82F6));
              final iconData = isAi
                  ? Icons.auto_awesome_rounded
                  : (isEscalated
                        ? Icons.warning_amber_rounded
                        : Icons.mail_outline_rounded);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Icon(iconData, size: 13, color: iconColor),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.neutral900,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${t.customerName ?? t.customerEmail} • ${DateFormatter.formatRelativeOrTime(t.updatedAt)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: tokens.subtleText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // 5. Right Side Card: Category Segments with Linear Progress Bars (ShipNova reference style)
  Widget _buildCategorySegmentsCard({
    required Map<String, int> categoryCounts,
    required int totalCount,
    required HelpdeskThemeTokens tokens,
    required bool isDark,
  }) {
    final colors = [
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Emerald
      const Color(0xFF71717A), // Zinc
    ];

    final entries = categoryCounts.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Ticket Categories',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: isDark ? Colors.white : AppColors.neutral950,
                ),
              ),
              const Spacer(),
              Text(
                'Volume distribution',
                style: TextStyle(fontSize: 11, color: tokens.subtleText),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No categories recorded',
                  style: TextStyle(color: tokens.subtleText, fontSize: 12),
                ),
              ),
            )
          else
            ...entries.asMap().entries.map((mapEntry) {
              final index = mapEntry.key;
              final entry = mapEntry.value;
              final color = colors[index % colors.length];
              final count = entry.value;
              final percentage = totalCount > 0 ? (count / totalCount) : 0.0;
              final pctStr = '${(percentage * 100).toStringAsFixed(0)}%';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          entry.key.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white70
                                : AppColors.neutral800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$count ($pctStr)',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.neutral950,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 5,
                        backgroundColor: isDark
                            ? const Color(0xFF1E1E22)
                            : const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// Subcomponent: Individual Metric Card with Vertical Soundwave/Barcode Bars
class _MetricCardItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String trendText;
  final Color trendColor;
  final Color barColor;
  final double barFillRatio;
  final HelpdeskThemeTokens tokens;
  final bool isDark;

  const _MetricCardItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.trendText,
    required this.trendColor,
    required this.barColor,
    required this.barFillRatio,
    required this.tokens,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Icon + Label Row
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 12, color: iconColor),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: tokens.subtleText,
                  ),
                ),
              ),
              // Icon(Icons.more_vert_rounded, size: 13, color: tokens.subtleText),
            ],
          ),
          const SizedBox(height: 10),

          // Big Bold Value
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: isDark ? Colors.white : AppColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),

          // Mini Vertical Soundwave / Barcode Distribution Chart
          SizedBox(
            height: 14,
            width: double.infinity,
            child: CustomPaint(
              painter: _VerticalBarDistributionPainter(
                accentColor: barColor,
                fillRatio: barFillRatio,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Trend Subtitle
          Text(
            trendText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Vertical Soundwave / Barcode Bars (matching ShipNova reference)
class _VerticalBarDistributionPainter extends CustomPainter {
  final Color accentColor;
  final double fillRatio;
  final bool isDark;

  _VerticalBarDistributionPainter({
    required this.accentColor,
    required this.fillRatio,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const totalBars = 22;
    final barSpacing = size.width / totalBars;
    final barWidth = barSpacing * 0.55;

    final filledBarsCount = (totalBars * fillRatio).round().clamp(1, totalBars);

    // Predefined rhythm of heights (matching reference soundwave density)
    final heights = [
      0.4,
      0.6,
      0.8,
      0.5,
      0.9,
      1.0,
      0.7,
      0.85,
      0.6,
      0.75,
      0.9,
      0.8,
      0.65,
      0.7,
      0.85,
      0.95,
      0.6,
      0.5,
      0.7,
      0.8,
      0.6,
      0.4,
    ];

    for (int i = 0; i < totalBars; i++) {
      final isFilled = i < filledBarsCount;
      final heightRatio = heights[i % heights.length];
      final barHeight = size.height * heightRatio;
      final left = i * barSpacing;
      final top = size.height - barHeight;

      final paint = Paint()
        ..color = isFilled
            ? accentColor
            : (isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, barHeight),
          const Radius.circular(1.5),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalBarDistributionPainter oldDelegate) {
    return oldDelegate.fillRatio != fillRatio ||
        oldDelegate.accentColor != accentColor;
  }
}

// Subcomponent: Table Row Item for Recent Tickets
class _TableRowItem extends StatelessWidget {
  final TicketEntity ticket;
  final HelpdeskThemeTokens tokens;
  final bool isDark;
  final VoidCallback onTap;

  const _TableRowItem({
    required this.ticket,
    required this.tokens,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final customerName =
        ticket.customerName != null && ticket.customerName!.isNotEmpty
        ? ticket.customerName!
        : ticket.customerEmail.split('@').first;

    final initials = customerName.length >= 2
        ? customerName.substring(0, 2).toUpperCase()
        : customerName.isNotEmpty
        ? customerName.substring(0, 1).toUpperCase()
        : 'CU';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: isDark ? const Color(0xFF141416) : const Color(0xFFF8FAFC),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: tokens.cardBorder, width: 0.8),
            ),
          ),
          child: Row(
            children: [
              // Customer Avatar and Name
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF27272A)
                            : const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : AppColors.neutral900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : AppColors.neutral950,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Subject
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    ticket.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFD4D4D8)
                          : AppColors.neutral800,
                    ),
                  ),
                ),
              ),

              // Category
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF18181B)
                          : const Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: tokens.cardBorder,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      ticket.category.displayName,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: tokens.subtleText,
                      ),
                    ),
                  ),
                ),
              ),

              // Status Pill
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: ticket.status.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: ticket.status.color.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: ticket.status.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            ticket.status.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: ticket.status.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Time
              Expanded(
                flex: 2,
                child: Text(
                  DateFormatter.formatRelativeOrTime(ticket.updatedAt),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    color: tokens.subtleText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
