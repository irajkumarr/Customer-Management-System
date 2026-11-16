import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/ticket_list_cubit.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/ticket_detail_pane.dart';
import '../widgets/ticket_list_pane.dart';
import 'ticket_detail_page.dart';

class TicketDashboardPage extends StatefulWidget {
  final String? selectedTicketId;

  const TicketDashboardPage({
    super.key,
    this.selectedTicketId,
  });

  @override
  State<TicketDashboardPage> createState() => _TicketDashboardPageState();
}

class _TicketDashboardPageState extends State<TicketDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<TicketListCubit>().loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final isDesktop = MediaQuery.sizeOf(context).width > 900;

        if (isDesktop) {
          return _DesktopLayout(
            selectedTicketId: widget.selectedTicketId,
          );
        } else {
          if (widget.selectedTicketId != null) {
            return TicketDetailPage(ticketId: widget.selectedTicketId!);
          }

          return Scaffold(
            key: _scaffoldKey,
            drawer: const Drawer(
              child: AppSidebar(isDrawer: true),
            ),
            body: TicketListPane(
              isDesktop: false,
              selectedTicketId: null,
              onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              onTicketSelected: (ticketId) => context.go('/tickets/$ticketId'),
            ),
          );
        }
      },
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final String? selectedTicketId;

  const _DesktopLayout({this.selectedTicketId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Column: App Sidebar (260px)
          const SizedBox(
            width: 260,
            child: AppSidebar(isDrawer: false),
          ),

          // Divider
          VerticalDivider(width: 1, thickness: 1, color: dividerColor),

          // Center Column: Ticket List Pane (420px)
          SizedBox(
            width: 420,
            child: TicketListPane(
              isDesktop: true,
              selectedTicketId: selectedTicketId,
              onTicketSelected: (ticketId) => context.go('/tickets/$ticketId'),
            ),
          ),

          // Divider
          VerticalDivider(width: 1, thickness: 1, color: dividerColor),

          // Right Column: Ticket Detail Pane (Expanded)
          Expanded(
            child: TicketDetailPane(ticketId: selectedTicketId),
          ),
        ],
      ),
    );
  }
}
