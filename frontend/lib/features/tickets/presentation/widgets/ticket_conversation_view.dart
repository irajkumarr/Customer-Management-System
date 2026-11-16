import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/ticket_enums.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/ticket_detail_entity.dart';
import '../bloc/ticket_detail_cubit.dart';
import '../bloc/ticket_detail_state.dart';
import '../bloc/ticket_list_cubit.dart';

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
  final TextEditingController _replyController = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _replyController.addListener(() {
      final hasText = _replyController.text.trim().isNotEmpty;
      if (hasText != _canSend) {
        setState(() => _canSend = hasText);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _submitReply() async {
    if (!_canSend) return;
    final cubit = context.read<TicketDetailCubit>();
    if (cubit.state.isSendingReply) return;

    final text = _replyController.text.trim();
    final success = await cubit.sendReply(text);
    if (success && mounted) {
      _replyController.clear();
      FocusScope.of(context).unfocus();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cubit = context.read<TicketDetailCubit>();

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState is Authenticated) {
          cubit.loadTicket(widget.ticketId);
        }
      },
      child: BlocConsumer<TicketDetailCubit, TicketDetailState>(
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
          if (state.isLoading && state.ticket == null) {
            return Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? Colors.white : AppColors.neutral900,
                ),
              ),
            );
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
                      size: 32,
                      color: tokens.statusEscalated,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Failed to load conversation',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.errorMessage!,
                      style: TextStyle(color: tokens.subtleText, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh_rounded, size: 14),
                      label: const Text('Retry'),
                      onPressed: () => cubit.loadTicket(widget.ticketId),
                    ),
                  ],
                ),
              ),
            );
          }

          final ticket = state.ticket!;

          return Container(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            child: Column(
              children: [
                // 1. Top Context & Action Bar (Intercom / Linear style)
                LayoutBuilder(
                  builder: (context, barConstraints) {
                    final isNarrow = barConstraints.maxWidth < 620;

                    if (isNarrow) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: tokens.dividerColor),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                if (widget.showBackButton) ...[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_rounded,
                                      size: 18,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    tooltip: 'Back to queue',
                                    onPressed: widget.onBack,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        ticket.customer.name ??
                                            ticket.customer.email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.neutral950,
                                        ),
                                      ),
                                      Text(
                                        ticket.subject,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: tokens.subtleText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: state.isRefreshing
                                      ? SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.8,
                                            color: isDark
                                                ? Colors.white
                                                : AppColors.neutral900,
                                          ),
                                        )
                                      : Icon(
                                          Icons.refresh_rounded,
                                          size: 17,
                                          color: tokens.subtleText,
                                        ),
                                  tooltip: 'Refresh Thread (REST)',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: state.isRefreshing
                                      ? null
                                      : () => cubit.refresh(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _buildStatusDropdown(
                                  cubit,
                                  ticket,
                                  tokens,
                                  isDark,
                                ),
                                _buildCategoryDropdown(
                                  cubit,
                                  ticket,
                                  tokens,
                                  isDark,
                                ),
                                if (ticket.status != TicketStatus.RESOLVED &&
                                    ticket.status != TicketStatus.CLOSED)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.neutral900,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: state.isUpdatingStatus
                                        ? null
                                        : () => cubit.updateStatus(
                                            TicketStatus.RESOLVED,
                                          ),
                                    child: const Text(
                                      'Resolve',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }

                    return Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: tokens.dividerColor),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (widget.showBackButton) ...[
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                              ),
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Back to queue',
                              onPressed: widget.onBack,
                            ),
                            const SizedBox(width: 4),
                          ],

                          // Breadcrumb: Customer > Ticket
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    ticket.customer.name ??
                                        ticket.customer.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.neutral950,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Text(
                                    '›',
                                    style: TextStyle(color: tokens.subtleText),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    ticket.subject,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: tokens.subtleText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Status Dropdown
                          _buildStatusDropdown(cubit, ticket, tokens, isDark),
                          const SizedBox(width: 6),

                          // Category Dropdown
                          _buildCategoryDropdown(cubit, ticket, tokens, isDark),
                          const SizedBox(width: 8),

                          // Resolve Button
                          if (ticket.status != TicketStatus.RESOLVED &&
                              ticket.status != TicketStatus.CLOSED)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.neutral900,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: state.isUpdatingStatus
                                  ? null
                                  : () => cubit.updateStatus(
                                      TicketStatus.RESOLVED,
                                    ),
                              child: const Text(
                                'Resolve',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),

                          const SizedBox(width: 4),

                          // Manual REST Refresh Button
                          IconButton(
                            icon: state.isRefreshing
                                ? SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.8,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.neutral900,
                                    ),
                                  )
                                : Icon(
                                    Icons.refresh_rounded,
                                    size: 17,
                                    color: tokens.subtleText,
                                  ),
                            tooltip: 'Refresh Thread (REST)',
                            visualDensity: VisualDensity.compact,
                            onPressed: state.isRefreshing
                                ? null
                                : () => cubit.refresh(),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // 2. Main Body Split: Conversation Column + Context Sidebar
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 780;

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left Thread & Composer
                            Expanded(
                              child: _buildTimelineAndComposer(
                                context,
                                ticket,
                                state,
                                cubit,
                                tokens,
                                isDark,
                              ),
                            ),

                            // Vertical divider
                            VerticalDivider(
                              width: 1,
                              thickness: 1,
                              color: tokens.dividerColor,
                            ),

                            // Right Context Rail
                            SizedBox(
                              width: 280,
                              child: _buildRightContextRail(
                                context,
                                ticket,
                                tokens,
                                isDark,
                                isScrollable: true,
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Stacked for narrower viewports
                        return _buildTimelineAndComposer(
                          context,
                          ticket,
                          state,
                          cubit,
                          tokens,
                          isDark,
                          extraBottomContent: _buildRightContextRail(
                            context,
                            ticket,
                            tokens,
                            isDark,
                            isScrollable: false,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineAndComposer(
    BuildContext context,
    TicketDetailEntity ticket,
    TicketDetailState state,
    TicketDetailCubit cubit,
    HelpdeskThemeTokens tokens,
    bool isDark, {
    Widget? extraBottomContent,
  }) {
    return Column(
      children: [
        // Scrollable message thread
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => cubit.refresh(),
            color: AppColors.neutral900,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Subject Line & Date Banner
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.subject,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : AppColors.neutral950,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Opened ${DateFormatter.formatDateTime(ticket.createdAt)} via Mailgun Inbound',
                        style: TextStyle(
                          fontSize: 12,
                          color: tokens.subtleText,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),
                const SizedBox(height: 16),

                // Chronological Messages
                ...ticket.messages.map(
                  (msg) => _buildMessageRow(context, msg, tokens, isDark),
                ),

                const SizedBox(height: 16),

                if (extraBottomContent != null) ...[
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  extraBottomContent,
                ],
              ],
            ),
          ),
        ),

        // Bottom Anchored Composer Box (Intercom style)
        _buildBottomComposer(context, ticket, state, tokens, isDark),
      ],
    );
  }

  Widget _buildMessageRow(
    BuildContext context,
    MessageEntity msg,
    HelpdeskThemeTokens tokens,
    bool isDark,
  ) {
    if (msg.isFromAi) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF18181B) : const Color(0xFFFBFBFE),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.statusAiProcessingBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 13,
                    color: AppColors.statusAiProcessing,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.neutral950,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusAiRepliedBg,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'Auto-reply',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.statusAiReplied,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormatter.formatDateTime(msg.createdAt),
                  style: TextStyle(color: tokens.subtleText, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            MarkdownBody(
              data: msg.body,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                    p: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: isDark
                          ? const Color(0xFFE4E4E7)
                          : AppColors.neutral800,
                    ),
                  ),
            ),
          ],
        ),
      );
    } else if (msg.isFromAdmin) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF27272A) : AppColors.neutral200,
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.neutral900,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'AD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Admin Ops',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.neutral950,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormatter.formatDateTime(msg.createdAt),
                  style: TextStyle(color: tokens.subtleText, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SelectableText(
              msg.body,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? const Color(0xFFE4E4E7) : AppColors.neutral800,
              ),
            ),
          ],
        ),
      );
    } else {
      // Customer message
      final initials = msg.body.length >= 2 ? 'CU' : 'C';

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF27272A) : AppColors.neutral200,
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Customer',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.neutral950,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormatter.formatDateTime(msg.createdAt),
                  style: TextStyle(color: tokens.subtleText, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SelectableText(
              msg.body,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? const Color(0xFFE4E4E7) : AppColors.neutral900,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBottomComposer(
    BuildContext context,
    TicketDetailEntity ticket,
    TicketDetailState state,
    HelpdeskThemeTokens tokens,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(top: BorderSide(color: tokens.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Reply target context + Delivery provider badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.reply_rounded,
                  size: 15,
                  color: isDark ? Colors.white70 : AppColors.neutral700,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Reply to ${ticket.customer.name ?? ticket.customer.email}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.neutral900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E22)
                        : const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: tokens.cardBorder, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.mail_outline_rounded,
                        size: 11,
                        color: tokens.subtleText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Mailgun',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: tokens.subtleText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Composer Text Input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                const SingleActivator(LogicalKeyboardKey.enter, control: true):
                    _submitReply,
                const SingleActivator(LogicalKeyboardKey.enter, meta: true):
                    _submitReply,
              },
              child: TextField(
                controller: _replyController,
                enabled: !state.isSendingReply,
                maxLines: 5,
                minLines: 3,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Write a reply to customer...',
                  hintStyle: TextStyle(
                    fontSize: 12.5,
                    color: tokens.subtleText,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF18181B)
                      : const Color(0xFFFAFAFA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: tokens.cardBorder,
                      width: 0.8,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: tokens.cardBorder,
                      width: 0.8,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: AppColors.neutral900,
                      width: 1.2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ),

          // Composer Toolbar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Ctrl+Enter to send',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: tokens.subtleText),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neutral900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: (_canSend && !state.isSendingReply)
                      ? _submitReply
                      : null,
                  icon: state.isSendingReply
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 13),
                  label: const Text(
                    'Send Reply',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightContextRail(
    BuildContext context,
    TicketDetailEntity ticket,
    HelpdeskThemeTokens tokens,
    bool isDark, {
    bool isScrollable = true,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ticket Attributes Section
        Text(
          'TICKET DETAILS',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: tokens.subtleText,
          ),
        ),
        const SizedBox(height: 12),

        _AttributeRow(label: 'Ticket ID', value: '#${ticket.id}'),
        const Divider(height: 16),
        _AttributeRow(label: 'Status', value: ticket.status.displayName),
        const Divider(height: 16),
        _AttributeRow(label: 'Category', value: ticket.category.displayName),
        const Divider(height: 16),
        _AttributeRow(
          label: 'Created',
          value: DateFormatter.formatDateTime(ticket.createdAt),
        ),
        const Divider(height: 16),
        _AttributeRow(
          label: 'Updated',
          value: DateFormatter.formatDateTime(ticket.updatedAt),
        ),

        const SizedBox(height: 24),

        // Customer Profile Section
        Text(
          'CUSTOMER',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: tokens.subtleText,
          ),
        ),
        const SizedBox(height: 12),

        _AttributeRow(
          label: 'Name',
          value: ticket.customer.name ?? 'Not provided',
        ),
        const Divider(height: 16),
        _AttributeRow(label: 'Email', value: ticket.customer.email),
        const Divider(height: 16),
        _AttributeRow(label: 'Customer ID', value: ticket.customer.id),

        const SizedBox(height: 24),

        // Channel & Protocol
        Text(
          'INTEGRATIONS',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: tokens.subtleText,
          ),
        ),
        const SizedBox(height: 12),
        const _AttributeRow(label: 'Email Ingestion', value: 'Mailgun Routes'),
        const Divider(height: 16),
        const _AttributeRow(
          label: 'RAG Pipeline',
          value: 'Spring AI + pgvector',
        ),
      ],
    );

    if (isScrollable) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: content,
      );
    }

    return Padding(padding: const EdgeInsets.all(16), child: content);
  }

  Widget _buildStatusDropdown(
    TicketDetailCubit cubit,
    TicketDetailEntity ticket,
    HelpdeskThemeTokens tokens,
    bool isDark,
  ) {
    return PopupMenuButton<TicketStatus>(
      tooltip: 'Change Status',
      onSelected: (s) => cubit.updateStatus(s),
      itemBuilder: (context) => TicketStatus.values
          .map(
            (s) => PopupMenuItem(
              value: s,
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: s.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(s.displayName, style: const TextStyle(fontSize: 12.5)),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF4F4F5),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: tokens.cardBorder, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: ticket.status.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              ticket.status.displayName,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.neutral950,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: tokens.subtleText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(
    TicketDetailCubit cubit,
    TicketDetailEntity ticket,
    HelpdeskThemeTokens tokens,
    bool isDark,
  ) {
    return PopupMenuButton<TicketCategory>(
      tooltip: 'Change Category',
      onSelected: (c) => cubit.updateCategory(c),
      itemBuilder: (context) => TicketCategory.values
          .map(
            (c) => PopupMenuItem(
              value: c,
              child: Text(
                c.displayName,
                style: const TextStyle(fontSize: 12.5),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF4F4F5),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: tokens.cardBorder, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ticket.category.displayName,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: tokens.subtleText,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: tokens.subtleText,
            ),
          ],
        ),
      ),
    );
  }
}

class _AttributeRow extends StatelessWidget {
  final String label;
  final String value;

  const _AttributeRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: tokens.subtleText)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppColors.neutral950,
            ),
          ),
        ),
      ],
    );
  }
}
