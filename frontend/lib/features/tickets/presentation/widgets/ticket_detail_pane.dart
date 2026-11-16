import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
import '../bloc/ticket_detail_cubit.dart';
import 'ticket_conversation_view.dart';

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
      child: TicketConversationView(
        ticketId: ticketId!,
        showBackButton: false,
        onBack: () => context.go('/tickets'),
      ),
    );
  }
}

class _EmptyTicketDetailPlaceholder extends StatelessWidget {
  const _EmptyTicketDetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Ticket Selected',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Text(
                  'Select a ticket from the list to view its complete conversation thread, inspect AI responses, and reply to the customer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
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
