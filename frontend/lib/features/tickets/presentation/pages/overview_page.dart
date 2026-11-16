import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
import '../bloc/ticket_list_cubit.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/cognitive_desk_overview.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<TicketListCubit>().loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final width = MediaQuery.sizeOf(context).width;
        final isDesktopOrMedium = width >= 840;
        final isMedium = width >= 840 && width < 1200;

        if (isDesktopOrMedium) {
          final sidebarWidth = isMedium ? 68.0 : 240.0;

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

                // Main Column: Full-Width CognitiveDesk Overview Dashboard
                Expanded(
                  child: CognitiveDeskOverview(
                    onTicketSelected: (ticketId) => context.go('/tickets/$ticketId'),
                    onViewAll: () => context.go('/tickets'),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
            drawer: const Drawer(
              child: AppSidebar(isDrawer: true),
            ),
            appBar: AppBar(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: const Text(
                'Workspace / Overview',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            body: CognitiveDeskOverview(
              onTicketSelected: (ticketId) => context.go('/tickets/$ticketId'),
              onViewAll: () => context.go('/tickets'),
            ),
          );
        }
      },
    );
  }
}
