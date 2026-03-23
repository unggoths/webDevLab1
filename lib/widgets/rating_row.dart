import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RatingRow extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const RatingRow({
    super.key,
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ..._buildStars(rating),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviewCount відгуків)',
          style: AppTheme.ratingCount,
        ),
      ],
    );
  }

  List<Widget> _buildStars(double rating) {
    return List.generate(5, (index) {
      final filled = index < rating.floor();
      final half = !filled && index < rating;
      return Icon(
        half ? Icons.star_half_rounded : Icons.star_rounded,
        color: filled || half ? AppTheme.starColor : AppTheme.divider,
        size: 18,
      );
    });
  }
}