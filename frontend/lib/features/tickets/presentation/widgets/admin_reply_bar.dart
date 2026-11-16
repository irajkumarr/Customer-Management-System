import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';

class AdminReplyBar extends StatefulWidget {
  final bool isSending;
  final Future<bool> Function(String text) onSendReply;

  const AdminReplyBar({
    super.key,
    required this.isSending,
    required this.onSendReply,
  });

  @override
  State<AdminReplyBar> createState() => _AdminReplyBarState();
}

class _AdminReplyBarState extends State<AdminReplyBar> {
  final _controller = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _canSend) {
        setState(() {
          _canSend = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSend || widget.isSending) return;
    final text = _controller.text.trim();
    final success = await widget.onSendReply(text);
    if (success && mounted) {
      _controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          top: BorderSide(color: tokens.cardBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CallbackShortcuts(
                    bindings: <ShortcutActivator, VoidCallback>{
                      const SingleActivator(LogicalKeyboardKey.enter, control: true): _submit,
                      const SingleActivator(LogicalKeyboardKey.enter, meta: true): _submit,
                    },
                    child: TextField(
                      controller: _controller,
                      enabled: !widget.isSending,
                      maxLines: 5,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'Type your official reply to customer...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: tokens.subtleText,
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: (_canSend && !widget.isSending) ? _submit : null,
                  icon: widget.isSending
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 15),
                  label: const Text('Send & Email', style: TextStyle(fontSize: 12.5)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 13, color: tokens.subtleText),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Customer will receive this message as an outbound email via Mailgun.',
                    style: TextStyle(
                      fontSize: 11,
                      color: tokens.subtleText,
                    ),
                  ),
                ),
                Text(
                  'Ctrl+Enter to send',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: tokens.subtleText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
