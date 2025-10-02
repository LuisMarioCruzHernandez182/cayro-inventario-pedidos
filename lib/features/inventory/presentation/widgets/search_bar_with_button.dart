import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SearchBarWithButton extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback? onClear;
  final bool isLoading;

  const SearchBarWithButton({
    super.key,
    required this.controller,
    required this.onSearch,
    this.onClear,
    this.isLoading = false,
  });

  @override
  State<SearchBarWithButton> createState() => _SearchBarWithButtonState();
}

class _SearchBarWithButtonState extends State<SearchBarWithButton> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _onClear() {
    widget.controller.clear();
    widget.onClear?.call();
    // Trigger search with empty query
    widget.onSearch();
  }

  void _onSubmitted(String value) {
    widget.onSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              onSubmitted: _onSubmitted,
              decoration: InputDecoration(
                hintText: 'Buscar productos, marcas, categorías...',
                hintStyle: TextStyle(color: AppColors.gray500, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.gray500,
                  size: 20,
                ),
                suffixIcon: _hasText
                    ? IconButton(
                        onPressed: widget.isLoading ? null : _onClear,
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.gray500,
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontSize: 14, color: AppColors.gray900),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: Material(
              color: AppColors.blue500,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onSearch,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.search, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
