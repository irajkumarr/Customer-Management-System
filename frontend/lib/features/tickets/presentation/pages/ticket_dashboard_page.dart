import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
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
        final width = MediaQuery.sizeOf(context).width;
        final isDesktopOrMedium = width >= 840;
        final isMedium = width >= 840 && width < 1200;

        if (isDesktopOrMedium) {
          return _DesktopLayout(
            selectedTicketId: widget.selectedTicketId,
            isMedium: isMedium,
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
  final bool isMedium;

  const _DesktopLayout({
    this.selectedTicketId,
    this.isMedium = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sidebarWidth = isMedium ? 68.0 : 240.0;
    final listWidth = isMedium ? 380.0 : 400.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Column: App Sidebar (Full or Compact Rail)
          SizedBox(
            width: sidebarWidth,
            child: AppSidebar(
              isDrawer: false,
              isRail: isMedium,
            ),
          ),

          // Divider
          VerticalDivider(width: 1, thickness: 1, color: tokens.dividerColor),

          // Center Column: Ticket List Pane
          SizedBox(
            width: listWidth,
            child: TicketListPane(
              isDesktop: true,
              selectedTicketId: selectedTicketId,
              onTicketSelected: (ticketId) => context.go('/tickets/$ticketId'),
            ),
          ),

          // Divider
          VerticalDivider(width: 1, thickness: 1, color: tokens.dividerColor),

          // Right Column: Ticket Detail Pane (Expanded Workspace)
          Expanded(
            child: TicketDetailPane(ticketId: selectedTicketId),
          ),
        ],
      ),
    );
  }
}
