import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
import '../bloc/ticket_detail_cubit.dart';
import '../bloc/ticket_detail_state.dart';
import '../bloc/ticket_list_cubit.dart';
import 'admin_reply_bar.dart';
import 'message_bubble.dart';
import 'ticket_header_card.dart';

class TicketConversationView extends StatefulWidget {
  final String ticketId;
  final bool showBackButton;
  final VoidCallback? onBack;

  const TicketConversationView({
    super.key,
    required this.ticketId,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  State<TicketConversationView> createState() => _TicketConversationViewState();
}

class _TicketConversationViewState extends State<TicketConversationView> {
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
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<TicketDetailCubit>();

    return BlocConsumer<TicketDetailCubit, TicketDetailState>(
      listener: (context, state) {
        if (state.actionSuccessMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionSuccessMessage!),
              backgroundColor: tokens.statusResolved,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          // Sync with list pane and stats
          try {
            context.read<TicketListCubit>().refresh();
          } catch (_) {}
          _scrollToBottom();
        }

        if (state.errorMessage != null && state.ticket != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
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
              // Detail Pane Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  border: Border(
                    bottom: BorderSide(color: tokens.cardBorder),
                  ),
                ),
                child: Row(
                  children: [
                    if (widget.showBackButton) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: 'Back to Tickets',
                        onPressed: widget.onBack,
                      ),
                      const SizedBox(width: 4),
                    ],
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
                                  fontSize: 15,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (state.ticket != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: state.ticket!.status.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(5),
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
                                fontSize: 12.5,
                                color: tokens.subtleText,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Manual Refresh Button (Strict rule: No WebSockets/Polling)
                    IconButton(
                      icon: state.isRefreshing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded, size: 20),
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
                              Icon(
                                Icons.error_outline_rounded,
                                size: 44,
                                color: tokens.statusEscalated,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Failed to load ticket',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                state.errorMessage!,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

                          // Conversation Thread Section Header
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    children: [
                                      Icon(Icons.history_rounded, size: 14, color: tokens.subtleText),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Conversation Thread (${ticket.messages.length})',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: tokens.subtleText,
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

                          const SizedBox(height: 16),
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
