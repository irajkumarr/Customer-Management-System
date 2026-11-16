import 'dart:async';
import 'package:flutter/material.dart';

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
    if (oldWidget.initialQuery != widget.initialQuery && _controller.text != widget.initialQuery) {
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
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(query.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (query) {
          _debounceTimer?.cancel();
          widget.onSearch(query.trim());
        },
        decoration: InputDecoration(
          hintText: 'Search tickets by subject, customer, email...',
          prefixIcon: const Icon(Icons.search_rounded, size: 18),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  tooltip: 'Clear search',
                  onPressed: () {
                    _controller.clear();
                    _debounceTimer?.cancel();
                    widget.onSearch('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        onChanged: _onQueryChanged,
      ),
    );
  }
}
