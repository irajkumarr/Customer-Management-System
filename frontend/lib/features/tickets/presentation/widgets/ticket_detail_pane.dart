import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/ticket_detail_cubit.dart';
import 'cognitive_desk_overview.dart';
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
      return CognitiveDeskOverview(
        onTicketSelected: (id) => context.go('/tickets/$id'),
        onViewAll: () => context.go('/tickets'),
      );
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
