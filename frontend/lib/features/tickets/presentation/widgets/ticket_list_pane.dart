import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
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
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<TicketListCubit>();

    return BlocConsumer<TicketListCubit, TicketListState>(
      listener: (context, state) {
        if (state.hasError && state.tickets.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to update tickets.'),
              backgroundColor: tokens.statusEscalated,
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
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    child: Row(
                      children: [
                        const Text(
                          'Tickets Queue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (state.totalElements > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
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
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh_rounded, size: 19),
                          tooltip: 'Refresh Queue',
                          onPressed: state.isRefreshing ? null : () => cubit.refresh(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Search Bar (with 300ms debouncing)
              SliverToBoxAdapter(
                child: TicketSearchBar(
                  initialQuery: state.searchQuery,
                  onSearch: (query) => cubit.setSearchQuery(query),
                ),
              ),

              // Filter Chips Strip
              SliverToBoxAdapter(
                child: TicketFilterChips(
                  selectedStatus: state.selectedStatus,
                  selectedCategory: state.selectedCategory,
                  onStatusChanged: (status) => cubit.setStatusFilter(status),
                  onCategoryChanged: (cat) => cubit.setCategoryFilter(cat),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 4)),

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
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 40,
                            color: tokens.statusEscalated,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Unable to load tickets',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.errorMessage ?? 'An unexpected error occurred.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: tokens.subtleText,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh_rounded, size: 16),
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
                            color: tokens.subtleText,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No tickets found',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.searchQuery.isNotEmpty ||
                                    state.selectedStatus != null ||
                                    state.selectedCategory != null
                                ? 'Try adjusting your filters or search terms.'
                                : 'No tickets in the system yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: tokens.subtleText,
                              fontSize: 13,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Page ${state.currentPage + 1} of ${state.totalPages == 0 ? 1 : state.totalPages} (${state.totalElements} total)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: tokens.subtleText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton.outlined(
                              icon: const Icon(Icons.chevron_left_rounded, size: 18),
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Previous page',
                              onPressed: state.currentPage > 0
                                  ? () => cubit.changePage(state.currentPage - 1)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            IconButton.outlined(
                              icon: const Icon(Icons.chevron_right_rounded, size: 18),
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Next page',
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            actions: [
              IconButton(
                icon: state.isRefreshing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
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
