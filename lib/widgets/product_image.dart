import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_icon_button.dart';

class ProductImage extends StatefulWidget {
  final String imageUrl;
  const ProductImage({super.key, required this.imageUrl});

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    debugPrint(_isFavorite ? '❤️ Додано до обраного' : '🤍 Видалено з обраного');
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * (isLandscape ? 0.65 : 0.4),
            width: double.infinity,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) =>
              progress == null ? child : const _ImagePlaceholder(),
              errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 16,
          child: AppIconButton(
            icon: _isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            iconColor: _isFavorite ? AppTheme.accent : AppTheme.textSecondary,
            onTap: _toggleFavorite,
          ),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.divider,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      ),
    );
  }
}