import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/ticket_detail_cubit.dart';
import '../bloc/ticket_detail_state.dart';
import '../bloc/ticket_list_cubit.dart';
import 'admin_reply_bar.dart';
import 'message_bubble.dart';
import 'ticket_header_card.dart';

class TicketDetailPane extends StatelessWidget {
  final String? ticketId;

  const TicketDetailPane({
    super.key,
    this.ticketId,
  });

  @override
  Widget build(BuildContext context) {
    if (ticketId == null) {
      return const _EmptyTicketDetailPlaceholder();
    }

    return BlocProvider<TicketDetailCubit>(
      key: ValueKey(ticketId),
      create: (_) => sl<TicketDetailCubit>()..loadTicket(ticketId!),
      child: _TicketDetailView(ticketId: ticketId!),
    );
  }
}

class _TicketDetailView extends StatefulWidget {
  final String ticketId;

  const _TicketDetailView({required this.ticketId});

  @override
  State<_TicketDetailView> createState() => _TicketDetailViewState();
}

class _TicketDetailViewState extends State<_TicketDetailView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cubit = context.read<TicketDetailCubit>();

    return BlocConsumer<TicketDetailCubit, TicketDetailState>(
      listener: (context, state) {
        if (state.actionSuccessMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionSuccessMessage!),
              backgroundColor: AppColors.statusResolved,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          // Sync with ticket list pane & stats
          try {
            context.read<TicketListCubit>().refresh();
          } catch (_) {}
          _scrollToBottom();
        }

        if (state.errorMessage != null && state.ticket != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.statusEscalated,
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
              // Detail Pane Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Ticket #${widget.ticketId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (state.ticket != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: state.ticket!.status.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    state.ticket!.status.displayName,
                                    style: TextStyle(
                                      color: state.ticket!.status.color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (state.ticket != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              state.ticket!.subject,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Manual Refresh Button (Rule: Manual refresh only!)
                    IconButton(
                      icon: state.isRefreshing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                      tooltip: 'Refresh Thread',
                      onPressed: state.isRefreshing ? null : () => cubit.refresh(),
                    ),
                  ],
                ),
              ),

              // Detail Body
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state.isLoading && state.ticket == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.errorMessage != null && state.ticket == null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: AppColors.statusEscalated,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Failed to load ticket',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                state.errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Retry'),
                                onPressed: () => cubit.loadTicket(widget.ticketId),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final ticket = state.ticket!;
                    return RefreshIndicator(
                      onRefresh: () => cubit.refresh(),
                      color: AppColors.primary,
                      child: ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        children: [
                          // Header Card with metadata & dropdowns
                          TicketHeaderCard(
                            ticket: ticket,
                            isUpdatingStatus: state.isUpdatingStatus,
                            isUpdatingCategory: state.isUpdatingCategory,
                            onStatusChanged: (newStatus) => cubit.updateStatus(newStatus),
                            onCategoryChanged: (newCategory) => cubit.updateCategory(newCategory),
                          ),

                          const SizedBox(height: 16),

                          // Conversation Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.history_rounded, size: 14, color: Color(0xFF64748B)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Conversation Thread (${ticket.messages.length})',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                          ),

                          // Chronological Message History
                          ...ticket.messages.map((message) => MessageBubble(message: message)),

                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Admin Reply Bar
              if (state.ticket != null)
                AdminReplyBar(
                  isSending: state.isSendingReply,
                  onSendReply: (text) => cubit.sendReply(text),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyTicketDetailPlaceholder extends StatelessWidget {
  const _EmptyTicketDetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Ticket Selected',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  'Select a ticket from the list to view its complete conversation thread, inspect AI responses, update status, and reply directly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
