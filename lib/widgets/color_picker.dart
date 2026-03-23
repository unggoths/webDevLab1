import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

class ColorPicker extends StatefulWidget {
  final List<ProductColor> colors;
  final ValueChanged<ProductColor> onSelected;

  const ColorPicker({
    super.key,
    required this.colors,
    required this.onSelected,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.colors.length,
        itemBuilder: (context, index) {
          final color = widget.colors[index];
          final isSelected = index == _selectedIndex;

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 10),
            child: _ColorDot(
              color: color,
              isSelected: isSelected,
              onTap: () {
                setState(() => _selectedIndex = index);
                widget.onSelected(color);
              },
            ),
          );
        },
      ),
    );
  }
}


class _ColorDot extends StatelessWidget {
  final ProductColor color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            width: 2.5,
          ),
          color: Colors.transparent,
        ),
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(color.hexValue),
            boxShadow: [
              BoxShadow(
                color: Color(color.hexValue).withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}