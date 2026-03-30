import 'package:flutter/material.dart';
import '../theme/weather_theme.dart';

class WeatherSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final WeatherTheme theme;
  final bool isLoading;
  final VoidCallback onSearch;

  const WeatherSearchBar({
    super.key,
    required this.controller,
    required this.theme,
    required this.isLoading,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          const Icon(Icons.search_rounded, color: Colors.white54, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 0.3,
              ),
              decoration: InputDecoration(
                hintText: 'Kyiv, London, Tokyo...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              cursorColor: theme.accentColor,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
            ),
          ),
          _SearchButton(theme: theme, isLoading: isLoading, onTap: onSearch),
        ],
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  final WeatherTheme theme;
  final bool isLoading;
  final VoidCallback onTap;

  const _SearchButton({
    required this.theme,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: theme.accentColor.withOpacity(0.2),
          border: Border.all(color: theme.accentColor.withOpacity(0.4)),
        ),
        child: isLoading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.accentColor,
          ),
        )
            : Icon(Icons.arrow_forward_rounded, color: theme.accentColor, size: 20),
      ),
    );
  }
}