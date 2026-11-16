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
      color: isDark ? AppColors.surfaceDark : AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: tokens.cardBorder, width: 0.8),
                ),
                child: Icon(
                  Icons.inbox_outlined,
                  size: 22,
                  color: tokens.subtleText,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No ticket selected',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: -0.2,
                  color: isDark ? Colors.white : AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  'Select a conversation from the list to review customer inquiries, inspect AI responses, and send replies.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
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
