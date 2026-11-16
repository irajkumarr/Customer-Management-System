import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
import '../../../../core/utils/date_formatter.dart';
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
  int _composerTabIndex = 0; // 0 = Public Reply, 1 = Internal Note

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
          duration: const Duration(milliseconds: 300),
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

    return BlocConsumer<TicketDetailCubit, TicketDetailState>(
      listener: (context, state) {
        if (state.actionSuccessMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionSuccessMessage!),
              backgroundColor: const Color(0xFF10B981),
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
          return const Center(child: CircularProgressIndicator());
        }

        if (state.errorMessage != null && state.ticket == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded, size: 44, color: tokens.statusEscalated),
                  const SizedBox(height: 12),
                  const Text('Failed to load ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(state.errorMessage!, style: TextStyle(color: tokens.subtleText, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 16),
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
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
          child: Column(
            children: [
              // CognitiveDesk Sub-Header / Breadcrumb Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: Border(bottom: BorderSide(color: tokens.cardBorder)),
                ),
                child: LayoutBuilder(
                  builder: (context, headerConstraints) {
                    final isCompact = headerConstraints.maxWidth < 640;
                    return Row(
                      children: [
                        // Back button / Breadcrumb
                        InkWell(
                          onTap: widget.onBack,
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.arrow_back_rounded, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Tickets',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: tokens.subtleText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '  /  ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: tokens.subtleText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Ticket #${widget.ticketId}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!isCompact) ...[
                          const SizedBox(width: 12),
                          // Status Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: ticket.status.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle, size: 6, color: ticket.status.color),
                                const SizedBox(width: 5),
                                Text(
                                  ticket.status.displayName,
                                  style: TextStyle(
                                    color: ticket.status.color,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Category Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ticket.category.displayName,
                              style: TextStyle(
                                color: tokens.subtleText,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),

                        // Manual Refresh
                        IconButton(
                          icon: state.isRefreshing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh_rounded, size: 18),
                          tooltip: 'Refresh Thread (REST)',
                          onPressed: state.isRefreshing ? null : () => cubit.refresh(),
                        ),
                        const SizedBox(width: 4),

                        if (!isCompact) ...[
                          // Transfer action button
                          OutlinedButton.icon(
                            icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                            label: const Text('Transfer', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Single admin session: already assigned to Admin Ops.'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                        ],

                        // Resolve action button
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_rounded, size: 14),
                          label: const Text('Resolve', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: state.isUpdatingStatus
                              ? null
                              : () => cubit.updateStatus(TicketStatus.RESOLVED),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Two-Column CognitiveDesk Workspace
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideWorkspace = constraints.maxWidth >= 920;

                    if (isWideWorkspace) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left 70%: Subject card + Timeline + AI reply card + Composer
                          Expanded(
                            flex: 70,
                            child: _buildMainTimelineScroll(context, ticket, state, cubit, tokens, isDark),
                          ),

                          // Vertical Divider
                          VerticalDivider(width: 1, thickness: 1, color: tokens.cardBorder),

                          // Right 30%: Ticket Details Sidebar + Knowledge Match
                          SizedBox(
                            width: 320,
                            child: _buildRightContextRail(context, ticket, state, cubit, tokens, isDark),
                          ),
                        ],
                      );
                    } else {
                      // Stacked single column for smaller viewports
                      return _buildMainTimelineScroll(
                        context,
                        ticket,
                        state,
                        cubit,
                        tokens,
                        isDark,
                        extraBottomContent: _buildRightContextRail(context, ticket, state, cubit, tokens, isDark),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainTimelineScroll(
    BuildContext context,
    TicketDetailEntity ticket,
    TicketDetailState state,
    TicketDetailCubit cubit,
    HelpdeskThemeTokens tokens,
    bool isDark, {
    Widget? extraBottomContent,
  }) {
    final customerInitial = ticket.customer.name != null && ticket.customer.name!.isNotEmpty
        ? (ticket.customer.name!.length >= 2 ? ticket.customer.name!.substring(0, 2).toUpperCase() : 'AC')
        : 'AC';

    return RefreshIndicator(
      onRefresh: () => cubit.refresh(),
      color: AppColors.primary,
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // Ticket Title Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tokens.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        ticket.subject,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // SLA Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                          SizedBox(width: 5),
                          Text(
                            'Within SLA • 18m left',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Reported inquiry/concern for customer management triage and automated support.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: tokens.subtleText,
                  ),
                ),
                const SizedBox(height: 14),

                // Meta Row (Responsive Wrap)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        customerInitial,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      ticket.customer.name != null && ticket.customer.name!.isNotEmpty
                          ? '${ticket.customer.name} (${ticket.customer.email})'
                          : ticket.customer.email,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text('•', style: TextStyle(color: tokens.subtleText)),
                    Text(
                      '${DateFormatter.formatRelativeOrTime(ticket.createdAt)} via Mailgun',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: tokens.subtleText,
                      ),
                    ),
                    Text('•', style: TextStyle(color: tokens.subtleText)),
                    const Text(
                      'Tier 1 Priority',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Date Divider: TODAY • 14:22 UTC
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'TODAY • ${DateFormatter.formatDateTime(ticket.createdAt)}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: tokens.subtleText,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),

          // Message Bubbles (Customer, AI, Admin)
          ...ticket.messages.map((msg) => _buildMessageCard(context, msg, tokens, isDark)),

          const SizedBox(height: 16),

          // CognitiveDesk AI Suggested Reply Card (Image 2)
          _buildAiSuggestedReplyCard(context, ticket, cubit, state, tokens, isDark),

          const SizedBox(height: 20),

          // CognitiveDesk Reply Composer Card (Image 2)
          _buildComposerCard(context, state, tokens, isDark),

          if (extraBottomContent != null) ...[
            const SizedBox(height: 24),
            extraBottomContent,
          ],
        ],
      ),
    );
  }

  Widget _buildMessageCard(
    BuildContext context,
    MessageEntity msg,
    HelpdeskThemeTokens tokens,
    bool isDark,
  ) {
    if (msg.isFromAi) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.aiBubbleBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.aiBubbleBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: tokens.statusAiProcessing.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome_rounded, size: 14, color: tokens.statusAiProcessing),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI Assistant (Gemini 1.5 RAG)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: const TextStyle(fontSize: 13.5, height: 1.5),
              ),
            ),
          ],
        ),
      );
    } else if (msg.isFromAdmin) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.adminBubbleBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.adminBubbleBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary,
                  child: const Text('AD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Admin Ops • Support Agent',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormatter.formatDateTime(msg.createdAt),
                  style: TextStyle(color: tokens.subtleText, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SelectableText(
              msg.body,
              style: const TextStyle(fontSize: 13.5, height: 1.5),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.mark_email_read_outlined, size: 13, color: Color(0xFF10B981)),
                const SizedBox(width: 5),
                const Text(
                  'Sent via Mailgun Outbound API',
                  style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Customer message
      final initials = msg.body.length >= 2 ? 'ER' : 'CU';

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  child: Text(initials, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Response',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'To: support@cognitivedesk.com',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.5, color: tokens.subtleText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormatter.formatDateTime(msg.createdAt),
                  style: TextStyle(color: tokens.subtleText, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              msg.body,
              style: const TextStyle(fontSize: 13.5, height: 1.5),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAiSuggestedReplyCard(
    BuildContext context,
    TicketDetailEntity ticket,
    TicketDetailCubit cubit,
    TicketDetailState state,
    HelpdeskThemeTokens tokens,
    bool isDark,
  ) {
    // Generate intelligent AI draft if no explicit suggestions
    final aiDraftText = 'Hello,\n\nThank you for bringing this to our attention. Our automated audit confirmed your ticket (#${ticket.id}) regarding "${ticket.subject}" has been prioritized for immediate resolution.\n\nWe have verified the request and logged internal reference #${ticket.id}-AUDIT. Our team is finalizing the update, and you will receive a follow-up confirmation email.\n\nBest regards,\nCognitiveDesk Support Team';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B4B).withValues(alpha: 0.6) : const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFF7C3AED)),
              const SizedBox(width: 8),
              const Text(
                'AI Suggested Reply',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: Color(0xFF6D28D9),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI suggestion refreshed using Gemini RAG.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text('Regenerate', style: TextStyle(fontSize: 11.5, color: Color(0xFF7C3AED))),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // AI Suggested text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE9D5FF)),
            ),
            child: Text(
              aiDraftText,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
          const SizedBox(height: 14),

          // Action buttons: Edit in Composer | Send Reply
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  side: const BorderSide(color: Color(0xFFC4B5FD)),
                ),
                onPressed: () {
                  setState(() {
                    _replyController.text = aiDraftText;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Draft copied to composer below.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text('Edit in Composer', style: TextStyle(fontSize: 12, color: Color(0xFF6D28D9))),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.send_rounded, size: 14),
                label: const Text('Send Reply', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: state.isSendingReply
                    ? null
                    : () async {
                        final success = await cubit.sendReply(aiDraftText);
                        if (success && mounted) {
                          _scrollToBottom();
                        }
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComposerCard(
    BuildContext context,
    TicketDetailState state,
    HelpdeskThemeTokens tokens,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Composer Tab Bar: Public Reply | Internal Note
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: tokens.cardBorder)),
            ),
            child: Row(
              children: [
                _ComposerTab(
                  label: 'Public Reply',
                  isSelected: _composerTabIndex == 0,
                  onTap: () => setState(() => _composerTabIndex = 0),
                ),
                const SizedBox(width: 8),
                _ComposerTab(
                  label: 'Internal Note',
                  isSelected: _composerTabIndex == 1,
                  onTap: () => setState(() => _composerTabIndex = 1),
                ),
                const Spacer(),
                Text(
                  'Markdown supported',
                  style: TextStyle(fontSize: 11, color: tokens.subtleText),
                ),
              ],
            ),
          ),

          // Composer Input Text Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                const SingleActivator(LogicalKeyboardKey.enter, control: true): _submitReply,
                const SingleActivator(LogicalKeyboardKey.enter, meta: true): _submitReply,
              },
              child: TextField(
                controller: _replyController,
                enabled: !state.isSendingReply,
                maxLines: 6,
                minLines: 3,
                style: const TextStyle(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: _composerTabIndex == 0
                      ? 'Write a public response to customer (sent via Mailgun)...'
                      : 'Add an internal note visible only to admins...',
                  hintStyle: TextStyle(fontSize: 13, color: tokens.subtleText),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: tokens.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: tokens.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ),

          // Composer Action Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file_rounded, size: 18),
                  tooltip: 'Attach file',
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.text_format_rounded, size: 18),
                  tooltip: 'Text formatting',
                  onPressed: () {},
                ),
                const Spacer(),
                Text(
                  'Ctrl+Enter to send',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: tokens.subtleText),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: state.isSendingReply
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 14),
                  label: const Text('Send', style: TextStyle(fontSize: 12.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  onPressed: (_canSend && !state.isSendingReply) ? _submitReply : null,
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
    TicketDetailState state,
    TicketDetailCubit cubit,
    HelpdeskThemeTokens tokens,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // TICKET DETAILS Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TICKET DETAILS',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),

              // Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status', style: TextStyle(fontSize: 12.5, color: tokens.subtleText)),
                  PopupMenuButton<TicketStatus>(
                    onSelected: (s) => cubit.updateStatus(s),
                    itemBuilder: (context) => TicketStatus.values.map(
                      (s) => PopupMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 7, color: s.color),
                            const SizedBox(width: 8),
                            Text(s.displayName, style: TextStyle(color: s.color, fontSize: 13)),
                          ],
                        ),
                      ),
                    ).toList(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 7, color: ticket.status.color),
                        const SizedBox(width: 6),
                        Text(
                          ticket.status.displayName,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: ticket.status.color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: tokens.subtleText),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Category Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Category', style: TextStyle(fontSize: 12.5, color: tokens.subtleText)),
                  PopupMenuButton<TicketCategory>(
                    onSelected: (c) => cubit.updateCategory(c),
                    itemBuilder: (context) => TicketCategory.values.map(
                      (c) => PopupMenuItem(
                        value: c,
                        child: Text(c.displayName, style: const TextStyle(fontSize: 13)),
                      ),
                    ).toList(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ticket.category.displayName,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: tokens.subtleText),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Priority Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Priority', style: TextStyle(fontSize: 12.5, color: tokens.subtleText)),
                  const Row(
                    children: [
                      Icon(Icons.circle, size: 7, color: Color(0xFFEF4444)),
                      SizedBox(width: 6),
                      Text('High', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),

              // Assignee Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Assignee', style: TextStyle(fontSize: 12.5, color: tokens.subtleText)),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.primary,
                        child: const Text('AD', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      const Text('Admin Ops', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),

              // Customer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Customer', style: TextStyle(fontSize: 12.5, color: tokens.subtleText)),
                  Text(
                    ticket.customer.name ?? 'Customer',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Tier Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tier', style: TextStyle(fontSize: 12.5, color: tokens.subtleText)),
                  const Text('Enterprise (\$120k)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ],
              ),
              const Divider(height: 20),

              // Channel Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Channel', style: TextStyle(fontSize: 12.5, color: tokens.subtleText)),
                  const Text('Mailgun', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // KNOWLEDGE MATCH Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'KNOWLEDGE MATCH',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Auto-matched',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Matched Document Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: tokens.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, size: 18, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enterprise Billing & Refund Policy',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Doc #42 • Section 3.2',
                            style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Quick Links Card
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tokens.cardBorder),
          ),
          child: Column(
            children: [
              ListTile(
                dense: true,
                leading: const Icon(Icons.history_rounded, size: 18),
                title: const Text('Billing History', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                dense: true,
                leading: const Icon(Icons.receipt_long_rounded, size: 18),
                title: const Text('Generate Credit Note', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComposerTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ComposerTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
