import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/ticket_detail_cubit.dart';
import '../widgets/ticket_conversation_view.dart';

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
      return Scaffold(
        body: TicketConversationView(
          ticketId: ticketId,
          showBackButton: true,
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/tickets');
            }
          },
        ),
      );
    } catch (_) {
      return BlocProvider<TicketDetailCubit>(
        create: (_) => sl<TicketDetailCubit>()..loadTicket(ticketId),
        child: Scaffold(
          body: TicketConversationView(
            ticketId: ticketId,
            showBackButton: true,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/tickets');
              }
            },
          ),
        ),
      );
    }
  }
}
