import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../bloc/ticket_list_cubit.dart';
import '../bloc/ticket_list_state.dart';
import '../widgets/ticket_filter_chips.dart';
import '../widgets/ticket_list_item.dart';
import '../widgets/ticket_search_bar.dart';
import '../widgets/ticket_stats_bar.dart';

class TicketDashboardPage extends StatefulWidget {
  const TicketDashboardPage({super.key});

  @override
  State<TicketDashboardPage> createState() => _TicketDashboardPageState();
}

class _TicketDashboardPageState extends State<TicketDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<TicketListCubit>().loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Tickets Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          // Manual Refresh Button (Explicit REST requirement: No WebSockets/Polling)
          BlocBuilder<TicketListCubit, TicketListState>(
            builder: (context, state) {
              return IconButton(
                icon: state.isRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Tickets',
                onPressed: state.isRefreshing
                    ? null
                    : () => context.read<TicketListCubit>().refresh(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<TicketListCubit, TicketListState>(
        listener: (context, state) {
          if (state.hasError && state.tickets.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to update tickets.'),
                backgroundColor: AppColors.statusEscalated,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<TicketListCubit>();

          return RefreshIndicator(
            onRefresh: () => cubit.refresh(),
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Stats summary bar
                SliverToBoxAdapter(
                  child: TicketStatsBar(
                    stats: state.stats,
                    selectedStatus: state.selectedStatus,
                    onStatusSelected: (status) => cubit.setStatusFilter(status),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: TicketSearchBar(
                    initialQuery: state.searchQuery,
                    onSearch: (query) => cubit.setSearchQuery(query),
                  ),
                ),

                // Filters Bar
                SliverToBoxAdapter(
                  child: TicketFilterChips(
                    selectedStatus: state.selectedStatus,
                    selectedCategory: state.selectedCategory,
                    onStatusChanged: (status) => cubit.setStatusFilter(status),
                    onCategoryChanged: (cat) => cubit.setCategoryFilter(cat),
                  ),
                ),

                // Main Content
                if (state.isLoading && state.tickets.isEmpty) ...[
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ] else if (state.hasError && state.tickets.isEmpty) ...[
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 48,
                              color: AppColors.statusEscalated,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Unable to load tickets',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              state.errorMessage ?? 'An unexpected error occurred.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Retry'),
                              onPressed: () => cubit.loadInitialData(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else if (state.isEmpty) ...[
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No tickets found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.searchQuery.isNotEmpty || state.selectedStatus != null || state.selectedCategory != null
                                ? 'Try adjusting your filters or search terms.'
                                : 'No customer tickets in the system yet.',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // List of ticket cards
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final ticket = state.tickets[index];
                        return TicketListItem(
                          ticket: ticket,
                          onTap: () => context.go('/tickets/${ticket.id}'),
                        );
                      },
                      childCount: state.tickets.length,
                    ),
                  ),

                  // Pagination controls
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${state.tickets.length} of ${state.totalElements} tickets (Page ${state.currentPage + 1} of ${state.totalPages == 0 ? 1 : state.totalPages})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton.outlined(
                                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                                onPressed: state.currentPage > 0
                                    ? () => cubit.changePage(state.currentPage - 1)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              IconButton.outlined(
                                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                                onPressed: state.currentPage < state.totalPages - 1
                                    ? () => cubit.changePage(state.currentPage + 1)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
