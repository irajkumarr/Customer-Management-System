import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
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
        return Container(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          child: Column(
            children: [
              // Queue Header Bar
              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: tokens.dividerColor)),
                ),
                child: Row(
                  children: [
                    if (!isDesktop && onOpenDrawer != null) ...[
                      IconButton(
                        icon: const Icon(Icons.menu_rounded, size: 20),
                        onPressed: onOpenDrawer,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      'Tickets',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : AppColors.neutral950,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (state.totalElements > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: tokens.cardBorder, width: 0.8),
                        ),
                        child: Text(
                          '${state.totalElements}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.neutral950,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Manual REST Refresh Button
                    IconButton(
                      icon: state.isRefreshing
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.8,
                                color: isDark ? Colors.white : AppColors.neutral950,
                              ),
                            )
                          : Icon(
                              Icons.refresh_rounded,
                              size: 17,
                              color: tokens.subtleText,
                            ),
                      tooltip: 'Refresh Queue (REST)',
                      visualDensity: VisualDensity.compact,
                      onPressed: state.isRefreshing ? null : () => cubit.refresh(),
                    ),
                  ],
                ),
              ),

              // Search Box
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                child: TicketSearchBar(
                  initialQuery: state.searchQuery,
                  onSearch: (q) => cubit.setSearchQuery(q),
                ),
              ),

              // Filter Dropdowns
              TicketFilterChips(
                selectedStatus: state.selectedStatus,
                selectedCategory: state.selectedCategory,
                onStatusChanged: (s) => cubit.setStatusFilter(s),
                onCategoryChanged: (c) => cubit.setCategoryFilter(c),
              ),

              // Hairline separator before list
              Divider(height: 1, thickness: 1, color: tokens.dividerColor),

              // Ticket List Stream
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => cubit.refresh(),
                  color: AppColors.neutral900,
                  child: _buildQueueContent(context, state, cubit, tokens, isDark),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQueueContent(
    BuildContext context,
    TicketListState state,
    TicketListCubit cubit,
    HelpdeskThemeTokens tokens,
    bool isDark,
  ) {
    if (state.isLoading && state.tickets.isEmpty) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: isDark ? Colors.white : AppColors.neutral900,
          ),
        ),
      );
    }

    if (state.hasError && state.tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: tokens.statusEscalated,
              ),
              const SizedBox(height: 10),
              Text(
                'Unable to load tickets',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.errorMessage ?? 'Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: tokens.subtleText),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Retry'),
                onPressed: () => cubit.refresh(),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 32,
                color: tokens.subtleText,
              ),
              const SizedBox(height: 10),
              Text(
                'No tickets found',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.searchQuery.isNotEmpty || state.selectedStatus != null
                    ? 'Try clearing your filters or search query.'
                    : 'The ticket queue is currently empty.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: tokens.subtleText),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.tickets.length,
      itemBuilder: (context, index) {
        final ticket = state.tickets[index];
        final isSelected = ticket.id == selectedTicketId;

        return TicketListItem(
          ticket: ticket,
          isSelected: isSelected,
          onTap: () => onTicketSelected(ticket.id),
        );
      },
    );
  }
}
