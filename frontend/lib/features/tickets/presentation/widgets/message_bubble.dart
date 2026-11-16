import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  void _copyBody(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.body));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final isDark = theme.brightness == Brightness.dark;

    if (message.isFromAi) {
      return _buildAiBubble(context, theme, tokens, isDark);
    } else if (message.isFromAdmin) {
      return _buildAdminBubble(context, theme, tokens, isDark);
    } else {
      return _buildCustomerBubble(context, theme, tokens, isDark);
    }
  }

  Widget _buildCustomerBubble(
    BuildContext context,
    ThemeData theme,
    HelpdeskThemeTokens tokens,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.customerBubbleBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.customerBubbleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Customer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                DateFormatter.formatDateTime(message.createdAt),
                style: TextStyle(
                  color: tokens.subtleText,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 14),
                tooltip: 'Copy message',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                onPressed: () => _copyBody(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            message.body,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiBubble(
    BuildContext context,
    ThemeData theme,
    HelpdeskThemeTokens tokens,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.aiBubbleBg,
        borderRadius: BorderRadius.circular(10),
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
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color: tokens.statusAiProcessing,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AI Assistant',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tokens.statusAiProcessing.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'RAG Auto-Reply • Gemini 1.5',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: tokens.statusAiProcessing,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormatter.formatDateTime(message.createdAt),
                style: TextStyle(
                  color: tokens.subtleText,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 14),
                tooltip: 'Copy AI message',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                onPressed: () => _copyBody(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MarkdownBody(
            data: message.body,
            selectable: true,
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              p: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
              ),
              code: TextStyle(
                backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                fontFamily: 'monospace',
                fontSize: 12.5,
              ),
              codeblockDecoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: tokens.cardBorder,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminBubble(
    BuildContext context,
    ThemeData theme,
    HelpdeskThemeTokens tokens,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.adminBubbleBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tokens.adminBubbleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Support Agent (Human)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                ),
              ),
              const Spacer(),
              Text(
                DateFormatter.formatDateTime(message.createdAt),
                style: TextStyle(
                  color: tokens.subtleText,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 14),
                tooltip: 'Copy message',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                onPressed: () => _copyBody(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SelectableText(
            message.body,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 13,
                color: tokens.statusResolved,
              ),
              const SizedBox(width: 4),
              Text(
                'Emailed to customer via Mailgun API',
                style: TextStyle(
                  fontSize: 11,
                  color: tokens.statusResolved,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
