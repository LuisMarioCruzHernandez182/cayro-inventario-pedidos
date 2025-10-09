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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isVerySmallScreen = screenSize.width < 320;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(screenSize.width * 0.03),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          // Campo de búsqueda
          Expanded(
            child: TextField(
              controller: widget.controller,
              onSubmitted: _onSubmitted,
              decoration: InputDecoration(
                hintText: isVerySmallScreen
                    ? 'Buscar productos...'
                    : 'Buscar productos, marcas, categorías...',
                hintStyle: TextStyle(
                  color: AppColors.gray500,
                  fontSize: isSmallScreen
                      ? screenSize.width * 0.035
                      : screenSize.width * 0.038,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.gray500,
                  size: isSmallScreen
                      ? screenSize.width * 0.045
                      : screenSize.width * 0.05,
                ),
                suffixIcon: _hasText
                    ? IconButton(
                        onPressed: _onClear,
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.gray500,
                          size: isSmallScreen
                              ? screenSize.width * 0.045
                              : screenSize.width * 0.05,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.04,
                  vertical: isSmallScreen
                      ? screenSize.height * 0.012
                      : screenSize.height * 0.014,
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
            margin: EdgeInsets.only(right: screenSize.width * 0.01),
            child: Material(
              color: widget.isLoading ? AppColors.gray400 : AppColors.blue500,
              borderRadius: BorderRadius.circular(screenSize.width * 0.02),
              child: InkWell(
                onTap: widget.onSearch,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Icon(Icons.search, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
