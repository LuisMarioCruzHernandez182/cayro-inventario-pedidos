import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SearchBarWithButton extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback? onClear;

  const SearchBarWithButton({
    super.key,
    required this.controller,
    required this.onSearch,
    this.onClear,
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
    widget.onSearch();
  }

  void _onSubmitted(String value) {
    widget.onSearch();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    double scaleW(double v) => v * (width / 390);
    double scaleH(double v) => v * (height / 844);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(scaleW(12)),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Campo de búsqueda
          Expanded(
            child: TextField(
              controller: widget.controller,
              onSubmitted: _onSubmitted,
              style: TextStyle(fontSize: scaleW(14), color: AppColors.gray900),
              decoration: InputDecoration(
                hintText: 'Buscar productos, marcas, categorías...',
                hintStyle: TextStyle(
                  color: AppColors.gray500,
                  fontSize: scaleW(14),
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: scaleW(12), right: scaleW(8)),
                  child: Icon(
                    Icons.search,
                    color: AppColors.gray500,
                    size: scaleW(20),
                  ),
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: scaleW(32),
                  minHeight: scaleW(32),
                ),
                suffixIcon: _hasText
                    ? IconButton(
                        onPressed: _onClear,
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.gray500,
                          size: scaleW(20),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: scaleW(8),
                  vertical: scaleH(12),
                ),
                isDense: true,
              ),
              style: TextStyle(
                fontSize: isSmallScreen
                    ? screenSize.width * 0.038
                    : screenSize.width * 0.04,
                color: AppColors.gray900,
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.only(
              right: scaleW(4),
              top: scaleH(4),
              bottom: scaleH(4),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(scaleW(8)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue600.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: AppColors.blue600,
              borderRadius: BorderRadius.circular(scaleW(8)),
              child: InkWell(
                onTap: widget.onSearch,
                borderRadius: BorderRadius.circular(scaleW(8)),
                splashColor: Colors.white.withValues(alpha: 0.2),
                highlightColor: Colors.white.withValues(alpha: 0.1),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: scaleW(16),
                    vertical: scaleH(12),
                  ),
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: scaleW(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
