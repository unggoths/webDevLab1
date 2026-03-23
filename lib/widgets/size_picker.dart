import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SizePicker extends StatefulWidget {
  final List<String> sizes;
  final ValueChanged<String> onSelected;

  const SizePicker({
    super.key,
    required this.sizes,
    required this.onSelected,
  });

  @override
  State<SizePicker> createState() => _SizePickerState();
}

class _SizePickerState extends State<SizePicker> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.sizes.length,
        itemBuilder: (context, index) {
          final size = widget.sizes[index];
          final isSelected = size == _selected;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
            ),
            child: _SizeChip(
              label: size,
              isSelected: isSelected,
              onTap: () {
                setState(() => _selected = size);
                widget.onSelected(size);
              },
            ),
          );
        },
      ),
    );
  }
}


class _SizeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SizeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.divider,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTheme.sizeLabel.copyWith(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}