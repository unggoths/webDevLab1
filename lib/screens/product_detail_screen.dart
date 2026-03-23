import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/add_to_cart_btn.dart';
import '../widgets/app_icon_button.dart'; // 👈 replaces _CircleIconButton
import '../widgets/color_picker.dart';
import '../widgets/product_image.dart';
import '../widgets/rating_row.dart';
import '../widgets/size_picker.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  void _onSizeSelected(String size) => debugPrint('Вибрано розмір: $size');
  void _onColorSelected(ProductColor color) => debugPrint('Вибрано колір: ${color.name}');
  void _onAddToCart() => debugPrint('Товар доданий у кошик: ${product.name}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductImage(imageUrl: product.imageUrl),
                  _buildInfoSection(context),
                ],
              ),
            ),
          ),
          AddToCartButton(onPressed: _onAddToCart),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      // ✅ Replaced _CircleIconButton with AppIconButton — same component as favorite
      leading: Padding(
        padding: const EdgeInsets.all(6),
        child: AppIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: AppIconButton(
            icon: Icons.share_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.brand.toUpperCase(), style: AppTheme.brandLabel),
          const SizedBox(height: 8),
          Text(product.name, style: AppTheme.productName),
          const SizedBox(height: 12),
          RatingRow(rating: product.rating, reviewCount: product.reviewCount),
          const SizedBox(height: 20),
          _buildPriceRow(),
          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 20),
          _buildSectionLabel('Розмір (EU)'),
          const SizedBox(height: 12),
          SizePicker(sizes: product.sizes, onSelected: _onSizeSelected),
          const SizedBox(height: 20),
          _buildSectionLabel('Колір'),
          const SizedBox(height: 12),
          ColorPicker(colors: product.colors, onSelected: _onColorSelected),
          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 20),
          _buildSectionLabel('Опис'),
          const SizedBox(height: 10),
          Text(product.description, style: AppTheme.bodyText),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPriceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ціна', style: AppTheme.priceLabel),
            const SizedBox(height: 2),
            Text('${product.price.toStringAsFixed(0)} ₴', style: AppTheme.price),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.accentLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '-15%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) =>
      Text(label.toUpperCase(), style: AppTheme.sectionTitle);

  Widget _buildDivider() =>
      const Divider(color: AppTheme.divider, height: 1);
}
