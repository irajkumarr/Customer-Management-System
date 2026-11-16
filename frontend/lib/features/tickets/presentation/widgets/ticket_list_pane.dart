import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../bloc/ticket_list_cubit.dart';
import '../bloc/ticket_list_state.dart';
import 'ticket_filter_chips.dart';
import 'ticket_list_item.dart';
import 'ticket_search_bar.dart';

class TicketListPane extends StatelessWidget {
  final String? selectedTicketId;
  final ValueChanged<String> onTicketSelected;
  final bool isDesktop;
  final VoidCallback? onOpenDrawer;

  const TicketListPane({
    super.key,
    this.selectedTicketId,
    required this.onTicketSelected,
    this.isDesktop = true,
    this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cubit = context.read<TicketListCubit>();

    return BlocConsumer<TicketListCubit, TicketListState>(
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
        final content = RefreshIndicator(
          onRefresh: () => cubit.refresh(),
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Desktop Header Bar
              if (isDesktop) ...[
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        const Text(
                          'Tickets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (state.totalElements > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${state.totalElements}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        const Spacer(),
                        // Manual Refresh Button (Rule: No WebSockets/Polling)
                        IconButton(
                          icon: state.isRefreshing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh_rounded, size: 20),
                          tooltip: 'Refresh Tickets',
                          onPressed: state.isRefreshing ? null : () => cubit.refresh(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

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

              // Main List Content
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
                            size: 40,
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
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 40,
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
                            state.searchQuery.isNotEmpty ||
                                    state.selectedStatus != null ||
                                    state.selectedCategory != null
                                ? 'Try adjusting your filters or search.'
                                : 'No tickets in the system yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Ticket Items
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ticket = state.tickets[index];
                      final isSelected = selectedTicketId != null &&
                          selectedTicketId == ticket.id.toString();

                      return TicketListItem(
                        ticket: ticket,
                        isSelected: isSelected,
                        onTap: () => onTicketSelected(ticket.id.toString()),
                      );
                    },
                    childCount: state.tickets.length,
                  ),
                ),

                // Pagination Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Page ${state.currentPage + 1} of ${state.totalPages == 0 ? 1 : state.totalPages} (${state.totalElements} total)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton.outlined(
                              icon: const Icon(Icons.chevron_left_rounded, size: 18),
                              visualDensity: VisualDensity.compact,
                              onPressed: state.currentPage > 0
                                  ? () => cubit.changePage(state.currentPage - 1)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            IconButton.outlined(
                              icon: const Icon(Icons.chevron_right_rounded, size: 18),
                              visualDensity: VisualDensity.compact,
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

        if (isDesktop) {
          return Container(
            color: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
            child: content,
          );
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'Open Menu',
              onPressed: onOpenDrawer,
            ),
            title: const Text(
              'Tickets Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: state.isRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Tickets',
                onPressed: state.isRefreshing ? null : () => cubit.refresh(),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Sign Out',
                onPressed: () => context.read<AuthCubit>().logout(),
              ),
            ],
          ),
          body: content,
        );
      },
    );
  }
}
