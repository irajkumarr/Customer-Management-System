import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/ticket_detail_cubit.dart';
import '../bloc/ticket_detail_state.dart';
import '../widgets/admin_reply_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/ticket_header_card.dart';

class TicketDetailPage extends StatelessWidget {
  final String ticketId;

  const TicketDetailPage({
    super.key,
    required this.ticketId,
  });

  @override
  Widget build(BuildContext context) {
    try {
      context.read<TicketDetailCubit>();
      return _TicketDetailPageView(ticketId: ticketId);
    } catch (_) {
      return BlocProvider<TicketDetailCubit>(
        create: (_) => sl<TicketDetailCubit>()..loadTicket(ticketId),
        child: _TicketDetailPageView(ticketId: ticketId),
      );
    }
  }
}

class _TicketDetailPageView extends StatefulWidget {
  final String ticketId;

  const _TicketDetailPageView({
    required this.ticketId,
  });

  @override
  State<_TicketDetailPageView> createState() => _TicketDetailPageViewState();
}

class _TicketDetailPageViewState extends State<_TicketDetailPageView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Ensure loaded
    final cubit = context.read<TicketDetailCubit>();
    if (cubit.state.ticket?.id.toString() != widget.ticketId) {
      cubit.loadTicket(widget.ticketId);
    }
  }

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

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/tickets');
            }
          },
        ),
        title: Text(
          'Ticket #${widget.ticketId.length > 8 ? widget.ticketId.substring(0, 8) : widget.ticketId}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          // Manual refresh (Rule: No WebSockets/Polling)
          BlocBuilder<TicketDetailCubit, TicketDetailState>(
            builder: (context, state) {
              return IconButton(
                icon: state.isRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Thread',
                onPressed: state.isRefreshing
                    ? null
                    : () => context.read<TicketDetailCubit>().refresh(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<TicketDetailCubit, TicketDetailState>(
        listener: (context, state) {
          if (state.actionSuccessMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionSuccessMessage!),
                backgroundColor: AppColors.statusResolved,
                behavior: SnackBarBehavior.floating,
              ),
            );
            _scrollToBottom();
          } else if (state.errorMessage != null && state.ticket != null) {
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
          final cubit = context.read<TicketDetailCubit>();

          if (state.isLoading && state.ticket == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.hasError && state.ticket == null) {
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
                      onPressed: () => cubit.loadTicket(widget.ticketId),
                    ),
                  ],
                ),
              ),
            );
          }

          final ticket = state.ticket!;

          return Column(
            children: [
              // Header Card
              TicketHeaderCard(
                ticket: ticket,
                isUpdatingStatus: state.isUpdatingStatus,
                isUpdatingCategory: state.isUpdatingCategory,
                onStatusChanged: (newStatus) => cubit.updateStatus(newStatus),
                onCategoryChanged: (newCat) => cubit.updateCategory(newCat),
              ),

              // Message Thread
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => cubit.refresh(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: ticket.messages.length,
                    itemBuilder: (context, index) {
                      final message = ticket.messages[index];
                      return MessageBubble(message: message);
                    },
                  ),
                ),
              ),

              // Admin Reply Composer
              AdminReplyBar(
                isSending: state.isSendingReply,
                onSendReply: (text) => cubit.sendReply(text),
              ),
            ],
          );
        },
      ),
    );
  }
}
