import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState is Authenticated) {
          context.read<TicketListCubit>().loadInitialData();
        }
      },
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          final width = MediaQuery.sizeOf(context).width;
          final isDesktopOrMedium = width >= 840;
          final isMedium = width >= 840 && width < 1120;

          if (isDesktopOrMedium) {
            return _DesktopThreeRegionLayout(
              selectedTicketId: widget.selectedTicketId,
              isMedium: isMedium,
            );
          } else {
            // Mobile flow: If ticket selected -> detail screen, else list screen with drawer
            if (widget.selectedTicketId != null) {
              return TicketDetailPage(ticketId: widget.selectedTicketId!);
            }

            return Scaffold(
              key: _scaffoldKey,
              drawer: const Drawer(
                child: AppSidebar(isDrawer: true),
              ),
              body: SafeArea(
                child: TicketListPane(
                  isDesktop: false,
                  selectedTicketId: null,
                  onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                  onTicketSelected: (ticketId) => context.go('/tickets/$ticketId'),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _DesktopThreeRegionLayout extends StatelessWidget {
  final String? selectedTicketId;
  final bool isMedium;

  const _DesktopThreeRegionLayout({
    this.selectedTicketId,
    this.isMedium = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sidebarWidth = isMedium ? 64.0 : 240.0;
    final listWidth = isMedium ? 340.0 : 380.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Region 1: Navigation Sidebar (Full or Compact Rail)
          SizedBox(
            width: sidebarWidth,
            child: AppSidebar(
              isDrawer: false,
              isRail: isMedium,
            ),
          ),

          // Hairline separator
          VerticalDivider(width: 1, thickness: 1, color: tokens.dividerColor),

          // 2. Region 2: Ticket Queue List
          SizedBox(
            width: listWidth,
            child: TicketListPane(
              isDesktop: true,
              selectedTicketId: selectedTicketId,
              onTicketSelected: (ticketId) => context.go('/tickets/$ticketId'),
            ),
          ),

          // Hairline separator
          VerticalDivider(width: 1, thickness: 1, color: tokens.dividerColor),

          // 3. Region 3: Conversation Workspace (Expanded)
          Expanded(
            child: TicketDetailPane(ticketId: selectedTicketId),
          ),
        ],
      ),
    );
  }
}
