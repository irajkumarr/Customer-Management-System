import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/helpdesk_theme_tokens.dart';

class TicketSearchBar extends StatefulWidget {
  final String initialQuery;
  final ValueChanged<String> onSearch;

  const TicketSearchBar({
    super.key,
    required this.initialQuery,
    required this.onSearch,
  });

  @override
  State<TicketSearchBar> createState() => _TicketSearchBarState();
}

class _TicketSearchBarState extends State<TicketSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void didUpdateWidget(TicketSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery &&
        _controller.text != widget.initialQuery) {
      _controller.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    setState(() {});
    _debounceTimer?.cancel();
    if (query.isEmpty) {
      widget.onSearch('');
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      widget.onSearch(query.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: tokens.cardBorder, width: 0.8),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onQueryChanged,
        style: TextStyle(
          fontSize: 12.5,
          color: isDark ? Colors.white : AppColors.neutral950,
        ),
        decoration: InputDecoration(
          hintText: 'Search tickets or customers...',
          hintStyle: TextStyle(
            fontSize: 12.5,
            color: tokens.subtleText,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 16,
            color: tokens.subtleText,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 14),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch('');
                    setState(() {});
                  },
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }
}
